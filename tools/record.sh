#!/usr/bin/env bash
# Records one scene (or the whole reel) from the demo app on an iOS simulator and
# extracts 720x1280 frames at 30 fps, aligned so f0001 is program time t = 0.
#
# Usage: tools/record.sh <scene|reel> <seconds> [udid]
#   scene    spark grow shape details rhythm workflow connects flow outro, or reel
#   seconds  how much program time to capture
#   udid     simulator to use; defaults to the first booted iPhone, else boots iPhone 17e
#
# Output: tools/out/<scene>/capture.mp4, app.log, f0001.png ...
# Env:    SKIP_BUILD=1 reuses the last build in $DERIVED (default /tmp/glow-dd).
#
# Alignment: the recorder's "Recording started" line and the app's GLOW_T0 line
# (wall clock at the player's first frame) share the Mac clock; their difference
# is trimmed from the start of the video. Crop: the chromeless player fills the
# screen and letterboxes a centred 9:16 stage, so the crop is the largest centred
# 9:16 rect of the video. GLOW_STAGE_RECT in app.log records the rect in points.
set -euo pipefail

SCENE="${1:?usage: record.sh <scene|reel> <seconds> [udid]}"
SECONDS_TO_RECORD="${2:?usage: record.sh <scene|reel> <seconds> [udid]}"
UDID="${3:-}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEVLOCK="$HOME/.claude/bin/devlock"
DERIVED="${DERIVED:-/tmp/glow-dd}"
BUNDLE_ID="com.hemalmodi.GlowAnimationsDemo"
FALLBACK_UDID="CB91E8C4-291C-4B73-8431-4DB9B26D9D79"
OUT="$ROOT/tools/out/$SCENE"

UDID="${UDID:-$FALLBACK_UDID}"
if ! xcrun simctl list devices booted | grep -q "$UDID"; then
  "$DEVLOCK" run xcrun simctl boot "$UDID"
fi
echo "simulator: $UDID"

# One recording at a time per simulator: install + launch + capture must not interleave.
LOCK="/tmp/glow-record-$UDID.lock"
until mkdir "$LOCK" 2>/dev/null; do
  if [[ -f "$LOCK/pid" ]] && ! kill -0 "$(cat "$LOCK/pid")" 2>/dev/null; then rm -rf "$LOCK"; continue; fi
  echo "record.sh: simulator busy, waiting..." >&2; sleep 10
done
echo $$ > "$LOCK/pid"
trap 'rm -rf "$LOCK"' EXIT INT TERM

if [[ "$SCENE" == "reel" ]]; then
  APP_ARGS=(-glow-reel -glow-chromeless)
else
  APP_ARGS=(-glow-scene "$SCENE" -glow-chromeless)
fi

if [[ "${SKIP_BUILD:-0}" != "1" ]]; then
  "$DEVLOCK" run xcodebuild -project "$ROOT/Demo/GlowAnimationsDemo.xcodeproj" \
    -scheme GlowAnimationsDemo \
    -destination "platform=iOS Simulator,id=$UDID" \
    -derivedDataPath "$DERIVED" -quiet build
fi
APP="$DERIVED/Build/Products/Debug-iphonesimulator/GlowAnimationsDemo.app"
xcrun simctl install "$UDID" "$APP"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true

rm -rf "$OUT"
mkdir -p "$OUT"
VIDEO="$OUT/capture.mp4"
REC_LOG="$OUT/recorder.log"
APP_LOG="$OUT/app.log"

xcrun simctl io "$UDID" recordVideo --codec h264 --force "$VIDEO" 2>"$REC_LOG" &
REC_PID=$!

# Wait for the recorder, note the wall clock, then launch so t = 0 is on tape.
REC_START="$(python3 - "$REC_LOG" <<'PY'
import sys, time
deadline = time.time() + 15
while time.time() < deadline:
    if "Recording started" in open(sys.argv[1]).read():
        print(f"{time.time():.4f}"); sys.exit()
    time.sleep(0.005)
sys.exit("recorder did not start")
PY
)"
xcrun simctl launch --stderr="$APP_LOG" "$UDID" "$BUNDLE_ID" "${APP_ARGS[@]}" >/dev/null

python3 - "$APP_LOG" "$SECONDS_TO_RECORD" <<'PY'
import sys, time
deadline = time.time() + 20
while time.time() < deadline and "GLOW_T0" not in open(sys.argv[1]).read():
    time.sleep(0.01)
time.sleep(float(sys.argv[2]) + 0.5)
PY
kill -INT "$REC_PID"
wait "$REC_PID" || true
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true

T0="$(grep -m1 GLOW_T0 "$APP_LOG" | awk '{print $2}')"
[[ -n "$T0" ]] || { echo "no GLOW_T0 in $APP_LOG" >&2; exit 1; }
OFFSET="$(python3 -c "print(max(0.0, $T0 - $REC_START))")"
echo "t0 offset in video: ${OFFSET}s"
grep GLOW_ "$APP_LOG" | grep -v GLOW_T0 || true

read -r VW VH < <(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$VIDEO" | tr ',' ' ')
CROP="$(python3 -c "
w, h = $VW, $VH
if h / w > 16 / 9:
    cw, ch = w, round(w * 16 / 9)
else:
    cw, ch = round(h * 9 / 16), h
print(f'{cw}:{ch}:{(w - cw) // 2}:{(h - ch) // 2}')
")"
echo "video ${VW}x${VH}, crop $CROP"

FRAMES="$(python3 -c "print(round($SECONDS_TO_RECORD * 30))")"
ffmpeg -v error -y -ss "$OFFSET" -i "$VIDEO" \
  -vf "fps=30,crop=$CROP,scale=720:1280:flags=lanczos,setsar=1" \
  -frames:v "$FRAMES" "$OUT/f%04d.png"
echo "wrote $(ls "$OUT"/f*.png | wc -l | tr -d ' ') frames to $OUT"
