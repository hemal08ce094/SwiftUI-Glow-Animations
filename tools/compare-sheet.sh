#!/usr/bin/env bash
# Contact sheet of arbitrary key-frame pairs: row i is [reference frame i | our frame i].
#
# Usage: tools/compare-sheet.sh <scene> "<ref frames>" "<our frames>" [output.png]
#   ref frames  space-separated 1-based numbers in reference/frames30
#   our frames  space-separated 1-based numbers in tools/out/<scene>; same count
#   output      defaults to tools/out/<scene>/compare.png
#
# Example: tools/compare-sheet.sh spark "1 30 61" "1 30 61"
# Each frame is scaled to 360x640; left column is the reference. Frame labels are
# drawn when this ffmpeg build has the drawtext filter (needs libfreetype).
set -euo pipefail

SCENE="${1:?usage: compare-sheet.sh <scene> \"<ref frames>\" \"<our frames>\" [output]}"
read -r -a REFS <<< "${2:?}"
read -r -a OURS <<< "${3:?}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REF_DIR="$ROOT/reference/frames30"
OUR_DIR="$ROOT/tools/out/$SCENE"
OUTPUT="${4:-$OUR_DIR/compare.png}"

[[ ${#REFS[@]} -eq ${#OURS[@]} ]] || { echo "frame lists differ in length" >&2; exit 1; }
N=${#REFS[@]}

FONT=""
if [[ "$(ffmpeg -hide_banner -filters 2>/dev/null)" == *" drawtext "* ]]; then
  for f in /System/Library/Fonts/Supplemental/Arial.ttf /System/Library/Fonts/Helvetica.ttc; do
    [[ -f "$f" ]] && { FONT="$f"; break; }
  done
fi

INPUTS=()
FILTER=""
for ((i = 0; i < N; i++)); do
  R="$(printf '%s/f%04d.png' "$REF_DIR" "${REFS[$i]}")"
  O="$(printf '%s/f%04d.png' "$OUR_DIR" "${OURS[$i]}")"
  for f in "$R" "$O"; do [[ -f "$f" ]] || { echo "missing $f" >&2; exit 1; }; done
  INPUTS+=(-i "$R" -i "$O")
  for side in 0 1; do
    idx=$((2 * i + side))
    if [[ $side -eq 0 ]]; then label="ref ${REFS[$i]}"; else label="ours ${OURS[$i]}"; fi
    text=""
    [[ -n "$FONT" ]] && text=",drawtext=fontfile=$FONT:text='$label':x=12:y=12:fontsize=22:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6"
    FILTER+="[$idx:v]scale=360:640,setsar=1,format=rgb24$text[v$idx];"
  done
  FILTER+="[v$((2 * i))][v$((2 * i + 1))]hstack=inputs=2[row$i];"
done

if [[ $N -eq 1 ]]; then
  FILTER+="[row0]null[out]"
else
  for ((i = 0; i < N; i++)); do FILTER+="[row$i]"; done
  FILTER+="vstack=inputs=$N[out]"
fi

mkdir -p "$(dirname "$OUTPUT")"
ffmpeg -v error -y "${INPUTS[@]}" -filter_complex "$FILTER" -map "[out]" -frames:v 1 "$OUTPUT"
echo "wrote $OUTPUT"
