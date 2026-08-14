class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.7.0/podtui-darwin-arm64.tar.gz"
    sha256 "38cca5451f049de565f5b2c3f0e7f0d20cfaed47deca93f8315e8900da0666f5"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.7.0/podtui-darwin-x64.tar.gz"
    sha256 "54d292d5aebf210a84a0ecf12814950bddc9e260e6feee91159a490a83ad36c7"
  end

  depends_on "mpv"

  # The app bundle ships dylibs (libopentui, libcavacore) with @rpath IDs and
  # no headerpad. Keep them: brew's post-install linkage fix rewrites dylib
  # IDs to absolute opt paths, which doesn't fit their load-commands header
  # ("needs to be relinked, possibly with -headerpad").
  preserve_rpath

  def install
    # The binary and its two FFI libs (libopentui, libcavacore) must stay
    # SIBLINGS: the loaders resolve them relative to dirname(execPath). Keep
    # everything under libexec and expose only a `podtui` symlink on PATH.
    sub = Dir["podtui-darwin-*"].find { |d| File.directory?(d) } || "."
    libexec.install "#{sub}/podtui"
    libexec.install Dir["#{sub}/lib*.dylib"]
    bin.install_symlink libexec / "podtui"
  end

  test do
    assert_match "PodTUI version", shell_output("#{bin}/podtui --version")
  end
end
