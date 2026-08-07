#!/usr/bin/env bash
#
# sync-formula.sh <version>   e.g.  sync-formula.sh 0.2.0
#
# After you cut a new PodTUI release (push a vX.Y.Z tag), run this from the
# tap repo to bump version + sha256 in Formula/podtui.rb. It downloads the two
# darwin tarballs from the release, recomputes their sha256, and rewrites the
# formula (version, both /v<old>/... URLs, and both sha256 lines).
#
# Requires: gh (authenticated), shasum, python3.

set -euo pipefail

VERSION="${1:?usage: sync-formula.sh <version, e.g. 0.2.0>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FORMULA="$ROOT/Formula/podtui.rb"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ ! -f "$FORMULA" ]; then
  echo "error: $FORMULA not found" >&2
  exit 1
fi

echo "Fetching asset hashes for v$VERSION..."
for arch in arm64 x64; do
  asset="podtui-darwin-$arch.tar.gz"
  gh release download "v$VERSION" -p "$asset" -D "$TMP" --clobber >/dev/null
  sha=$(shasum -a 256 "$TMP/$asset" | awk '{ print $1 }')
  echo "  $asset -> $sha"
  export "SHA_${arch^^}"="$sha"   # SHA_ARM64, SHA_X64
done

python3 - "$FORMULA" "$VERSION" "$SHA_ARM64" "$SHA_X64" <<'PY'
import re, sys

path, version, sha_arm64, sha_x64 = sys.argv[1:5]
src = open(path).read()

src = re.sub(r'version "\d+\.\d+\.\d+"', f'version "{version}"', src, count=1)
src = re.sub(r'(podtui-darwin-arm64\.tar\.gz")\n\s*sha256 "[0-9a-f]{64}"',
             f'\\1\n    sha256 "{sha_arm64}"', src, count=1)
src = re.sub(r'(podtui-darwin-x64\.tar\.gz")\n\s*sha256 "[0-9a-f]{64}"',
             f'\\1\n    sha256 "{sha_x64}"', src, count=1)
# rewrite the /vX.Y.Z/ segment in both release URLs
src = re.sub(r'/releases/download/v[\d.]+/', f'/releases/download/v{version}/', src)

open(path, "w").write(src)
print(f"Updated {path}")
print(f"  version -> {version}")
print(f"  sha256 arm64 -> {sha_arm64}")
print(f"  sha256 x64   -> {sha_x64}")
print("Run: brew audit --strict --online Formula/podtui.rb && brew test Formula/podtui.rb")
PY