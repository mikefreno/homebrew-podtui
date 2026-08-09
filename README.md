# Homebrew tap: `podtui`

Homebrew tap providing the **PodTUI** keyboard-first terminal podcast client.

## Install

```sh
brew tap mikefreno/tap
brew install podtui
```

> Requires `mpv` for full playback/seek support — `brew install mpv` if you
> don't have it (the formula pulls it in automatically).

The formula installs the standalone binary plus its two native FFI libraries
(`libopentui.dylib`, `libcavacore.dylib`) **side by side** under `libexec`
(the loaders resolve them relative to the executable), and exposes only a
`podtui` symlink on your `PATH`.

## Updating after a release

After you push a new `vX.Y.Z` release tag on the main
[PodTUI](https://github.com/mikefreno/podtui) repo:

```sh
./scripts/sync-formula.sh X.Y.Z
git add Formula/podtui.rb && git commit -m "podtui X.Y.Z" && git push
```

This re-downloads the two darwin tarballs, recomputes their sha256, and bumps
the formula's `version`, URLs and hashes. (Requires `gh` authenticated with
read access to the release assets.)

## Layout

- `Formula/podtui.rb` — the Homebrew formula (arch-aware: picks the arm64 or
  x64 macOS tarball automatically).
- `scripts/sync-formula.sh` — helper to refresh `version`/`sha256` on each tag.