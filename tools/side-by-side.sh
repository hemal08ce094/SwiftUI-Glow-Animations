#!/usr/bin/env bash
# Builds the sample media from a full-reel take: our reel as an mp4, a side-by-side
# [reference | ours] mp4 and a 3x3 contact sheet of key frames.
#
# Usage: tools/side-by-side.sh [out dir]      (default samples/)
# Needs: tools/out/reel/f%04d.png (tools/record.sh reel 31.7) and reference/reel.mp4.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/samples}"
OURS="$ROOT/tools/out/reel"
REF="$ROOT/reference/reel.mp4"
mkdir -p "$OUT"

COUNT="$(ls "$OURS"/f*.png | wc -l | tr -d ' ')"
echo "our reel: $COUNT frames"

ffmpeg -v error -y -framerate 30 -i "$OURS/f%04d.png" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 -movflags +faststart "$OUT/reel.mp4"

ffmpeg -v error -y -i "$REF" -framerate 30 -i "$OURS/f%04d.png" \
  -filter_complex "[0:v]trim=end_frame=$COUNT,setpts=PTS-STARTPTS,scale=540:960[a];[1:v]scale=540:960[b];[a][b]hstack=inputs=2" \
  -an -c:v libx264 -pix_fmt yuv420p -crf 18 -movflags +faststart "$OUT/side-by-side.mp4"

# One still per scene, reference above ours, nine columns.
KEY=(60 140 214 290 420 560 700 800 930)
STARTS=(1 105 191 246 317 471 624 736 856)
inputs=()
filter=""
for i in "${!KEY[@]}"; do
  f="${KEY[$i]}"
  inputs+=(-i "$ROOT/reference/frames30/$(printf 'f%04d.png' "$f")" -i "$OURS/$(printf 'f%04d.png' "$f")")
  filter+="[$((2*i)):v]scale=240:427[r$i];[$((2*i+1)):v]scale=240:427[o$i];"
done
refs=""; ours=""
for i in "${!KEY[@]}"; do refs+="[r$i]"; ours+="[o$i]"; done
filter+="${refs}hstack=inputs=9[top];${ours}hstack=inputs=9[bottom];[top][bottom]vstack=inputs=2"
ffmpeg -v error -y "${inputs[@]}" -filter_complex "$filter" -frames:v 1 "$OUT/key-frames.png"

for f in 60 290 700 930; do
  ffmpeg -v error -y -i "$REF" -framerate 30 -i "$OURS/f%04d.png" \
    -filter_complex "[0:v]select=eq(n\,$((f-1)))[a];[1:v]select=eq(n\,$((f-1)))[b];[a][b]hstack=inputs=2" \
    -frames:v 1 "$OUT/compare-f$(printf '%04d' "$f").png"
done
ls -la "$OUT"
