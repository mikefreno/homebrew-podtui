class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.3.0/podtui-darwin-arm64.tar.gz"
    sha256 "942f9532cb094d96a40a2583df1486dc472078109f644c1f060ae7241e16082c"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.3.0/podtui-darwin-x64.tar.gz"
    sha256 "e7443acdcffb250023fc7734e4d42f4fd7714f8c7025d103eb62d90335520a7a"
  end

  depends_on "mpv"

  def install
    # Homebrew flattens a tarball's single top-level dir into the build CWD, so
    # the binary + libs land directly at buildpath. Handle both stagings.
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
