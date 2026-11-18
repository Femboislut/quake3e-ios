#!/bin/bash
# Fetch the device-only MoltenVK static XCFramework used by the iOS target.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
VER=1.4.2
TMP="$ROOT/build/moltenvk-ios-dl"
DEST="$ROOT/vendor/moltenvk-ios/MoltenVK/MoltenVK"
mkdir -p "$TMP" "$ROOT/vendor/moltenvk-ios"
rm -rf "$TMP"/*
echo "== downloading MoltenVK iOS $VER"
curl -fL --retry 3 -o "$TMP/MoltenVK-ios.tar" \
  "https://github.com/KhronosGroup/MoltenVK/releases/download/v$VER/MoltenVK-ios.tar"
mkdir -p "$TMP/extracted"
tar xf "$TMP/MoltenVK-ios.tar" -C "$TMP/extracted"
XC=$(find "$TMP/extracted" -type d -path '*/static/MoltenVK.xcframework' -print -quit)
INC=$(find "$TMP/extracted" -type d -path '*/MoltenVK/include' -print -quit)
[ -n "$XC" ] && [ -d "$XC" ] || { echo "FATAL: static MoltenVK.xcframework not found in iOS archive"; find "$TMP/extracted" -maxdepth 6 -print | head -100; exit 1; }
[ -n "$INC" ] && [ -d "$INC" ] || { echo "FATAL: MoltenVK headers not found in iOS archive"; exit 1; }
rm -rf "$DEST"
mkdir -p "$DEST/static"
cp -R "$INC" "$DEST/include"
cp -R "$XC" "$DEST/static/MoltenVK.xcframework"
[ -f "$DEST/static/MoltenVK.xcframework/ios-arm64/libMoltenVK.a" ] || {
  echo "FATAL: iOS arm64 MoltenVK slice missing"; find "$DEST/static/MoltenVK.xcframework" -maxdepth 3 -type f | head -60; exit 1;
}
echo "MOLTENVK IOS OK: $DEST (v$VER)"
