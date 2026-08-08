class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.2.1/podtui-darwin-arm64.tar.gz"
    sha256 "db15225039d61163058817775f1a94652e71c1928a53d7c85722e42f60975e8f"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.2.1/podtui-darwin-x64.tar.gz"
    sha256 "e314daa9b582d73eb97a4c3f863a093b1cc631809f57f4d83050c5509373934a"
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
