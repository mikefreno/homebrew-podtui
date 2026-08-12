class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.5.2/podtui-darwin-arm64.tar.gz"
    sha256 "dc236f8e4532d18cc55d90daf307c1a4620dd2c5e693a5f7900569a935d48422"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.5.2/podtui-darwin-x64.tar.gz"
    sha256 "1ff0b448e25ef982b159fd97384971a3f8820303318cc2d0c5fc26c7d1068698"
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
