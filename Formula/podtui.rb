class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"
  version "0.1.0"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.1.0/podtui-darwin-arm64.tar.gz"
    sha256 "efdf246808ba6ea2ce942c8a0e177db3e04f7f10d20741aa5afde236630c8faf"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.1.0/podtui-darwin-x64.tar.gz"
    sha256 "27395948027276778476623fd1ccec96dae9e5169b6a5d32eef57591be5d6f47"
  end

  depends_on "mpv"

  def install
    sub = "podtui-darwin-#{Hardware::CPU.arm? ? "arm64" : "x64"}"
    # The binary and its two FFI libs (libopentui.dylib, libcavacore.dylib)
    # must stay SIBLINGS: the loaders resolve them relative to
    # dirname(execPath). Keep everything under libexec and expose only a
    # `podtui` symlink on PATH.
    libexec.install "#{sub}/podtui"
    libexec.install Dir["#{sub}/lib*.dylib"]
    bin.install_symlink libexec/"podtui"
  end

  test do
    assert_match "PodTUI version 0.1.0", shell_output("#{bin}/podtui --version")
  end
end