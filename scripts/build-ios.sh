#!/bin/bash
# build-spike.sh — compile Quake3e engine for iphoneos/arm64, link and package app.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
OVERLAY=$ROOT/build/src-overlay
SPIKE=$ROOT/ios
OBJDIR=$ROOT/build/ios/obj
LIBOUT=$ROOT/build/ios/libq3e.a
HOST_ARCH=$(uname -m)
case "$HOST_ARCH" in
  arm64|aarch64) ORACLE_ARCH=aarch64 ;;
  x86_64) ORACLE_ARCH=x86_64 ;;
  *) echo "FATAL: unsupported macOS runner architecture: $HOST_ARCH"; exit 1 ;;
esac
REF=$ROOT/build/oracle-vk/release-darwin-$ORACLE_ARCH

[ -d "$OVERLAY/code" ] || { echo "FATAL: overlay missing — run scripts/sync-overlay.sh"; exit 1; }
[ -d "$REF/client" ] || { echo "FATAL: reference macOS vk build missing — run scripts/build-oracle.sh"; exit 1; }

if [ -z "${Q3E_DEV_DEFS+x}" ]; then
  case "$(plutil -extract CFBundleShortVersionString raw "$SPIKE/Info.plist")" in
    *.*.*.*) export Q3E_DEV_DEFS='$(inherited) Q3E_DEV_BUILD=1' ;;
    *) export Q3E_DEV_DEFS="" ;;
  esac
fi

SDKPATH=$(xcrun --sdk iphoneos --show-sdk-path)
CLANG=$(xcrun --sdk iphoneos -f clang)
if command -v ccache >/dev/null 2>&1; then
  CC="ccache $CLANG"
else
  CC="$CLANG"
fi
BASEFLAGS="-isysroot $SDKPATH -arch arm64 -miphoneos-version-min=16.0 -O2 -DNDEBUG -fvisibility=hidden -pipe -Wno-implicit-function-declaration"
DEFS="-DNO_VM_COMPILED -DUSE_VULKAN_API -DUSE_OGG_VORBIS -DMACOS_X -DUSE_CURL -DQ3E_MVK_BRIDGE"
INCS="-I$ROOT/build/ios-deps/prefix/include -I$OVERLAY/code/libogg/include -I$OVERLAY/code/libvorbis/include -I$OVERLAY/code/libvorbis/lib"
EXCLUDE="unix_main linux_signals sdl_glimp sdl_input sdl_snd sdl_gamma snd_mix_mmx snd_mix_sse snd_mix_x86_64 vm_x86 vm_aarch64 vm_armv7l vm_powerpc"

resolve() {
  local b=$1; shift
  local matches n
  matches=$(for d in "$@"; do find "$OVERLAY/code/$d" -maxdepth 2 -name "$b.c" 2>/dev/null; done | sort -u)
  n=$(echo "$matches" | grep -c . || true)
  if [ "$n" != 1 ]; then
    echo "FATAL: source resolve for '$b' matched $n candidates:" >&2
    echo "$matches" >&2
    exit 1
  fi
  echo "$matches"
}

srcs=()
for o in "$REF"/client/*.o; do
  b=$(basename "$o" .o)
  case " $EXCLUDE " in *" $b "*) continue ;; esac
  srcs+=("$(resolve "$b" client qcommon server botlib unix sdl)")
done
for o in "$REF"/client/jpeg/*.o; do srcs+=("$(resolve "$(basename "$o" .o)" libjpeg)"); done
for o in "$REF"/client/ogg/*.o; do srcs+=("$(resolve "$(basename "$o" .o)" libogg/src)"); done
for o in "$REF"/client/vorbis/*.o; do srcs+=("$(resolve "$(basename "$o" .o)" libvorbis/lib)"); done
for o in "$REF"/client/qvm/*.o; do
  b=$(basename "$o" .o)
  case " $EXCLUDE " in *" $b "*) continue ;; esac
  srcs+=("$(resolve "$b" qcommon)")
done
for o in "$REF"/rendv/*.o; do srcs+=("$(resolve "$(basename "$o" .o)" renderervk renderercommon)"); done

echo "== compiling ${#srcs[@]} engine sources for iphoneos/arm64"
mkdir -p "$OBJDIR"
rm -f "$OBJDIR"/*.o

GEN="$ROOT/build/ios/gen"
mkdir -p "$GEN"
STAMP="$(grep '^commit' "$ROOT/upstream.pin" | awk '{print substr($3,1,8)}')+p$(ls "$ROOT"/patches/*.patch 2>/dev/null | wc -l | tr -d ' ') $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
printf 'const char *q3e_ios_stamp = "%s";\n' "$STAMP" > "$GEN/ios_stamp.c"
srcs+=("$GEN/ios_stamp.c")
echo "== stamp: $STAMP"
for s in "${srcs[@]}"; do
  b=$(basename "$s" .c)
  extra=""
  case "$s" in */botlib/*) extra="-DBOTLIB" ;; esac
  $CC $BASEFLAGS $DEFS $INCS $extra -c "$s" -o "$OBJDIR/$b.o" \
    || { echo "FATAL: compile failed: $s"; exit 1; }
done
count=$(ls "$OBJDIR"/*.o | wc -l | tr -d ' ')
[ "$count" = "${#srcs[@]}" ] || { echo "FATAL: produced $count of ${#srcs[@]} objects"; exit 1; }

libtool -static -o "$LIBOUT" "$OBJDIR"/*.o
echo "== libq3e.a: $(du -h "$LIBOUT" | cut -f1) ($count objects)"

ICON_SRC="$SPIKE/icon/q3_icon_big.png"
ICONSET="$SPIKE/Assets.xcassets/AppIcon.appiconset"
[ -f "$ICON_SRC" ] || { echo "FATAL: icon master missing at $ICON_SRC"; exit 1; }
[ -f "$ICONSET/Contents.json" ] || { echo "FATAL: appiconset Contents.json missing at $ICONSET"; exit 1; }
sips -z 120 120 "$ICON_SRC" --out "$ICONSET/AppIcon60x60@2x.png" > /dev/null
sips -z 180 180 "$ICON_SRC" --out "$ICONSET/AppIcon60x60@3x.png" > /dev/null
sips -z 152 152 "$ICON_SRC" --out "$ICONSET/AppIcon76x76@2x.png" > /dev/null
sips -z 167 167 "$ICON_SRC" --out "$ICONSET/AppIcon83.5x83.5@2x.png" > /dev/null
sips -z 1024 1024 "$ICON_SRC" --out "$ICONSET/AppIcon1024.png" > /dev/null

(cd "$SPIKE" && xcodegen generate --quiet)
APP="$ROOT/build/ios/xcode/Release-iphoneos/Quake3e.app"
rm -f "$APP/Quake3e"
xcodebuild -project "$SPIKE/Quake3e.xcodeproj" -target Quake3e -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' ONLY_ACTIVE_ARCH=NO ENABLE_BITCODE=NO \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  ${Q3E_DEV_DEFS:+GCC_PREPROCESSOR_DEFINITIONS="$Q3E_DEV_DEFS"} \
  SYMROOT="$ROOT/build/ios/xcode" build > "$ROOT/build/ios/xcodebuild.log" 2>&1 \
  || { echo "FATAL: xcodebuild failed — tail:"; tail -30 "$ROOT/build/ios/xcodebuild.log"; exit 1; }

grep -q "BUILD SUCCEEDED" "$ROOT/build/ios/xcodebuild.log" \
  || { echo "FATAL: xcodebuild did not report BUILD SUCCEEDED — tail:"; tail -30 "$ROOT/build/ios/xcodebuild.log"; exit 1; }

[ -d "$APP" ] || { echo "FATAL: app bundle not produced"; exit 1; }
n=$(strings "$APP/Quake3e" | grep -cF "$STAMP" || true)
[ "${n:-0}" -gt 0 ] \
  || { echo "FATAL: fresh stamp not in app binary (stale/failed link): $STAMP"; exit 1; }
echo "SPIKE APP OK: $APP (stamp verified in binary)"
