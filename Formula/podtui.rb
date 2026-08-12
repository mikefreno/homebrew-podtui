class Podtui < Formula
  desc "Keyboard-first terminal podcast client (yazi-style, OpenTUI)"
  homepage "https://github.com/mikefreno/podtui"

  # PodTUI ships per-arch macOS tarballs. `Hardware::CPU.arm?` selects the
  # matching asset at formula-resolve time, so `brew install` works on both
  # Apple Silicon and Intel Macs.
  if Hardware::CPU.arm?
    url "https://github.com/mikefreno/podtui/releases/download/v0.5.0/podtui-darwin-arm64.tar.gz"
    sha256 "d4523d7562d144ece93c788ced6b3adc35e2cb8e144662d091cf3ee112a5c764"
  else
    url "https://github.com/mikefreno/podtui/releases/download/v0.5.0/podtui-darwin-x64.tar.gz"
    sha256 "4dfa95a131922830877e7124a4f62b3bec09745c4145cf047e73a18f6160f68a"
  end

  depends_on "mpv"

  # The app bundle ships dylibs (libopentui, libcavacore) with @rpath IDs and
  # no headerpad. Keep them: brew's post-install linkage fix rewrites dylib
  # IDs to absolute opt paths, which doesn't fit their load-commands header
  # ("needs to be relinked, possibly with -headerpad").
  preserve_rpath

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
