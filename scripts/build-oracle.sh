#!/bin/bash
# build-oracle.sh — sync overlay, then build both macOS oracle flavors from it.
#
# Two separate BUILD_DIRs because darwin builds are static-renderer
# (USE_RENDERER_DLOPEN=0): mixing RENDERER_DEFAULT values in one object dir
# would silently mix objects compiled under different feature defines.
# The engine binary's exit code is meaningless (it exits 0 on fatal errors),
# so this script asserts on produced artifacts, and runners assert on log
# content.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)

./scripts/sync-overlay.sh

HOST_ARCH=$(uname -m)
case "$HOST_ARCH" in
  arm64|aarch64) ORACLE_ARCH=aarch64 ;;
  *)
    echo "FATAL: iOS oracle build requires an Apple Silicon runner (arm64); got $HOST_ARCH"
    echo "Use runs-on: macos-26, not macos-26-intel."
    exit 1
    ;;
esac

JOBS=$(sysctl -n hw.ncpu)
for R in gl vk; do
  case $R in
    gl) RD=opengl ;;
    vk) RD=vulkan ;;
  esac
  echo "== building oracle-$R (RENDERER_DEFAULT=$RD)"
  # HEADER DEPENDENCIES. The Makefile compiles with -MMD and then includes
  #   D_FILES=$(shell find . -name '*.d')
  # which is relative to the SOURCE directory — and our BUILD_DIR is outside it,
  # so that find matches nothing and every header dependency is silently lost.
  # A header-only change then relinks stale objects built against the OLD struct
  # layouts, and the result is a binary that segfaults on the first rendered
  # frame while every compile step reported success. Feed the variable the real
  # list (a command-line assignment overrides the Makefile's).
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
