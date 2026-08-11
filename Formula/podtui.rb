class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.4.0/podtui-darwin-arm64.tar.gz"
    sha256 "a2944da147977cc6f2b82246067c040e9ba2aad09208c6aee272bb196afd40c5"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.4.0/podtui-darwin-x64.tar.gz"
    sha256 "3ba2924559551fd1004307dddcf7a49311340067d6a5df708cf8cda746bcdd4d"
  end

  depends_on "mpv"

  def install
    # Newer tarballs ship PodTui.app (compiled binary + bundled mpv + icon).
    # The `podtui` entry point MUST point at the app's binary so the bundled,
    # bundle-signed mpv is used — that's what makes macOS Now Playing show
    # the PodTui icon/name instead of a blank placeholder. Older tarballs
    # fall back to the plain binary + sibling dylibs layout.
    sub = Dir["podtui-darwin-*"].find { |d| File.directory?(d) } || "."
    app = "#{sub}/PodTui.app"
    if File.directory?(app)
      libexec.install app
      bin.install_symlink libexec / "PodTui.app" / "Contents" / "MacOS" / "podtui"
    else
      libexec.install "#{sub}/podtui"
      libexec.install Dir["#{sub}/lib*.dylib"]
      bin.install_symlink libexec / "podtui"
    end
  end

  test do
    assert_match "PodTUI version", shell_output("#{bin}/podtui --version")
  end
end
