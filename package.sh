#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
bash build.sh
VERSION="$(cat VERSION)"
mkdir -p dist
ARCHIVE="ChatGPT-Chime-$VERSION-macOS-universal.zip"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent 'build/ChatGPT Chime.app' "dist/$ARCHIVE"
(cd dist && /usr/bin/shasum -a 256 "$ARCHIVE" > SHA256SUMS.txt)
echo "Release files are in dist/"
