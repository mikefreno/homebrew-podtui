class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.3.1/podtui-darwin-arm64.tar.gz"
    sha256 "d64efe9b0f3b0543afa6e5431ec603d014a63db060b38bd6d1819f33248eac8e"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.3.1/podtui-darwin-x64.tar.gz"
    sha256 "65b4e8b54822eda24c16e2265b6fdc0cfee8ff91e3d5da132e1a561f016b462c"
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
