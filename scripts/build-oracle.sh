#!/bin/bash
# Build the two native macOS reference renderers used to derive the iOS source set.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
./scripts/sync-overlay.sh

HOST_ARCH=$(uname -m)
case "$HOST_ARCH" in
  arm64|aarch64) ORACLE_ARCH=aarch64 ;;
  x86_64) ORACLE_ARCH=x86_64 ;;
  *) echo "FATAL: unsupported macOS runner architecture: $HOST_ARCH"; exit 1 ;;
esac
echo "== oracle host architecture: $HOST_ARCH -> $ORACLE_ARCH"
JOBS=$(sysctl -n hw.ncpu)
for R in gl vk; do
  case $R in gl) RD=opengl ;; vk) RD=vulkan ;; esac
  echo "== building oracle-$R (RENDERER_DEFAULT=$RD)"
  DEPS=""
  if [ -d "$ROOT/build/oracle-$R" ]; then
    DEPS=$(find "$ROOT/build/oracle-$R" -name '*.d' | tr '\n' ' ')
  fi
  make -C build/src-overlay release BUILD_DIR="$ROOT/build/oracle-$R" RENDERER_DEFAULT=$RD D_FILES="$DEPS" -j"$JOBS" > "$ROOT/build/oracle-$R-make.log" 2>&1 \
    || { echo "FATAL: make failed for oracle-$R — tail of log:"; tail -30 "$ROOT/build/oracle-$R-make.log"; exit 1; }
  BIN="$ROOT/build/oracle-$R/release-darwin-$ORACLE_ARCH/quake3e.$ORACLE_ARCH"
  [ -x "$BIN" ] || { echo "FATAL: $BIN not produced"; exit 1; }
  echo "   $BIN sha256=$(shasum -a 256 "$BIN" | cut -c1-12)"
done
echo "ORACLE BUILDS OK"
