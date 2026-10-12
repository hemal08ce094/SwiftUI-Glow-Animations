#!/usr/bin/env bash
# Records one scene (or the whole reel) from the demo app on an iOS simulator and
# extracts 720x1280 frames at 30 fps, aligned so f0001 is program time t = 0.
#
# Usage: tools/record.sh <scene|reel> <seconds> [udid]
#   scene    spark grow shape details rhythm workflow connects flow outro, or reel
#   seconds  how much program time to capture
#   udid     simulator to use; defaults to iPhone 17e (booted through devlock if needed)
#
# Output: tools/out/<scene>/capture.mp4, app.log, alignment.txt, f0001.png ...
# Env:    SKIP_BUILD=1 reuses the last build in $DERIVED (default /tmp/glow-dd).
#
# Alignment: in chromeless mode the app draws a binary frame clock (TimecodeStrip in
# PlayerScreen.swift) in the top letterbox bar, outside the 9:16 crop, on every display
# frame: the program time of that very frame in 1/120 s. Every presented video frame is
# decoded, its clock read, and frame n = 1 + round(30 t) is taken from the video frame whose
# clock is closest to t = (n - 1) / 30. alignment.txt lists the mapping and the error per
# frame; the run fails if a 30 fps slot has no video frame within a frame of it.
# The green lead-in only warms the pipeline now; GLOW_T0 is logged for diagnostics.
# Crop: the chromeless player fills the screen and letterboxes a centred 9:16 stage, so the
# crop is the largest centred 9:16 rect of the video. GLOW_STAGE_RECT in app.log records
# the rect in points, GLOW_TIMECODE_RECT the clock strip in pixels.
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
WORK="$(mktemp -d /tmp/glow-frames.XXXXXX)"
trap 'rm -rf "$LOCK" "$WORK"' EXIT INT TERM

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

# Wait for the recorder before launching so t = 0 is on tape.
python3 - "$REC_LOG" <<'PY'
import sys, time
deadline = time.time() + 15
while time.time() < deadline:
    if "Recording started" in open(sys.argv[1]).read():
        sys.exit()
    time.sleep(0.005)
sys.exit("recorder did not start")
PY
xcrun simctl launch --stderr="$APP_LOG" "$UDID" "$BUNDLE_ID" "${APP_ARGS[@]}" >/dev/null

# Cover the 1 s green lead-in after GLOW_T0 is logged, the requested time and a margin.
python3 - "$APP_LOG" "$SECONDS_TO_RECORD" <<'PY'
import sys, time
deadline = time.time() + 20
while time.time() < deadline and "GLOW_T0" not in open(sys.argv[1]).read():
    time.sleep(0.01)
time.sleep(1.0 + float(sys.argv[2]) + 0.7)
PY
kill -INT "$REC_PID"
wait "$REC_PID" || true
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true

grep GLOW_ "$APP_LOG" || true

read -r VW VH < <(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$VIDEO" | tr ',' ' ')
read -r CROP CROP_Y < <(python3 -c "
w, h = $VW, $VH
if h / w > 16 / 9:
    cw, ch = w, round(w * 16 / 9)
else:
    cw, ch = round(h * 9 / 16), h
print(f'{cw}:{ch}:{(w - cw) // 2}:{(h - ch) // 2}', (h - ch) // 2)
")
echo "video ${VW}x${VH}, crop $CROP"

read -r TX TY TW TH < <(grep GLOW_TIMECODE_RECT "$APP_LOG" | tail -1 | awk '{print $2, $3, $4, $5}')
if [[ -z "${TH:-}" ]]; then
  echo "record.sh: no GLOW_TIMECODE_RECT in app.log (old build? rebuild without SKIP_BUILD)" >&2; exit 1
fi
if (( TY + TH > CROP_Y )); then
  echo "record.sh: timecode strip (y $TY..$((TY + TH))) overlaps the stage crop (y $CROP_Y)" >&2; exit 1
fi

# Read the clock of every presented frame: inset the strip, average each cell to one pixel.
CELLS=24
ffmpeg -v error -y -i "$VIDEO" -fps_mode passthrough \
  -vf "crop=${TW}:$((TH - 8)):${TX}:$((TY + 4)),scale=${CELLS}:1:flags=area" \
  -f rawvideo -pix_fmt gray "$WORK/strip.raw"

FRAMES="$(python3 -c "print(round($SECONDS_TO_RECORD * 30))")"
# Writes plan.txt (one "k n" line per output frame: selected-video-frame ordinal k → f{n}),
# select.txt (ffmpeg select expression) and alignment.txt (n, video frame, clock, error).
python3 - "$WORK" "$FRAMES" "$CELLS" "$OUT/alignment.txt" <<'PY'
import sys
work, frames, cells, report = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
raw = open(f"{work}/strip.raw", "rb").read()
total = len(raw) // cells
clocks = {}
for i in range(total):
    px = raw[i * cells:(i + 1) * cells]
    bits = [p > 128 for p in px]
    if not (bits[0] and not bits[1] and bits[-1]):
        continue
    data = bits[2:-2]
    if (sum(data) % 2 == 1) != bits[-2]:
        continue
    ticks = int("".join("1" if b else "0" for b in data), 2)
    clocks[i] = ticks / 120.0
if not clocks:
    sys.exit("record.sh: no valid timecode frames found")
first = min(clocks)
plan, chosen, worst, late = [], {}, 0.0, []
with open(report, "w") as out:
    out.write("# n video_frame clock error_ms\n")
    for n in range(1, frames + 1):
        target = (n - 1) / 30
        i, t = min(clocks.items(), key=lambda kv: abs(kv[1] - target))
        err = t - target
        worst = max(worst, abs(err))
        if abs(err) > 1 / 90:
            late.append((n, err))
        chosen.setdefault(i, []).append(n)
        out.write(f"{n} {i} {t:.4f} {err * 1000:+.1f}\n")
indices = sorted(chosen)
for k, i in enumerate(indices, 1):
    for n in chosen[i]:
        plan.append(f"{k} {n}")
open(f"{work}/plan.txt", "w").write("\n".join(plan) + "\n")
open(f"{work}/select.txt", "w").write("+".join(f"eq(n\\,{i})" for i in indices))
print(f"timecode: {len(clocks)} of {total} video frames carry a clock; "
      f"first clock at video frame {first} = t {clocks[first]:.3f}; "
      f"worst error {worst * 1000:.1f} ms; {len(late)} frames off by more than 11 ms")
if late[:10]:
    print("  off-grid frames:", ", ".join(f"f{n:04d} {e * 1000:+.0f} ms" for n, e in late[:10]))
if worst > 1 / 30:
    sys.exit(f"record.sh: a 30 fps slot had no video frame within a frame of it ({worst * 1000:.1f} ms)")
PY

# Extract only the selected video frames, cropped to the stage and scaled to design units.
ffmpeg -v error -y -i "$VIDEO" -fps_mode passthrough \
  -vf "select='$(cat "$WORK/select.txt")',crop=$CROP,scale=720:1280:flags=lanczos,setsar=1" \
  "$WORK/s%05d.png"
while read -r k n; do
  cp "$WORK/$(printf 's%05d.png' "$k")" "$OUT/$(printf 'f%04d.png' "$n")"
done < "$WORK/plan.txt"
echo "wrote $FRAMES frames to $OUT"
