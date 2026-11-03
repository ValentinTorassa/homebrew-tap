#!/bin/bash
# Sets the version and the SHA-256 of Casks/blackice.rb for a blackice release.
#
# usage: scripts/update-cask.sh VERSION [SHA256]
#   VERSION: the release, like 0.1.0 (the tag is v0.1.0).
#   SHA256:  the SHA-256 of Blackice-VERSION.zip. Without it, the script reads it from
#            Blackice-VERSION.zip.sha256 on the GitHub release, as macos/scripts/package.sh writes it.
# Then check the cask with `ruby -c Casks/blackice.rb` (and `brew style --cask Casks/blackice.rb`
# where Homebrew is installed), and commit.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CASK="$ROOT/Casks/blackice.rb"
die() { echo "update-cask: $*" >&2; exit 1; }

[[ $# -eq 1 || $# -eq 2 ]] || { sed -n 4,7p "$0" >&2; exit 64; }
VERSION=$1
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "VERSION must look like 0.1.0, not '$VERSION'"

if [[ $# -eq 2 ]]; then
    SHA=$2
else
    url="https://github.com/ValentinTorassa/blackice/releases/download/v$VERSION/Blackice-$VERSION.zip.sha256"
    line=$(curl -fsSL --proto '=https' "$url") || die "could not download $url"
    # shasum's format: the hash, two spaces, the file name.
    read -r SHA name <<<"$line"
    [[ "$name" == "Blackice-$VERSION.zip" ]] || die "$url names '$name', not Blackice-$VERSION.zip"
fi
SHA=$(printf '%s' "$SHA" | tr 'A-F' 'a-f')
[[ "$SHA" =~ ^[0-9a-f]{64}$ ]] || die "SHA256 must be 64 hexadecimal digits"

[[ -f "$CASK" ]] || die "no cask at $CASK"
[[ $(grep -c '^  version "' "$CASK") -eq 1 && $(grep -c '^  sha256 "' "$CASK") -eq 1 ]] \
    || die "$CASK should have one version line and one sha256 line"
tmp=$(mktemp "$CASK.XXXXXX")
trap 'rm -f "$tmp"' EXIT
sed -e "s/^  version \"[^\"]*\"/  version \"$VERSION\"/" \
    -e "s/^  sha256 \"[0-9a-fA-F]*\"/  sha256 \"$SHA\"/" "$CASK" > "$tmp"
grep -q "^  version \"$VERSION\"$" "$tmp" || die "the version line was not updated"
grep -q "^  sha256 \"$SHA\"" "$tmp" || die "the sha256 line was not updated"
cat "$tmp" > "$CASK"
ruby -c "$CASK" > /dev/null
echo "Casks/blackice.rb: version $VERSION, sha256 $SHA"
