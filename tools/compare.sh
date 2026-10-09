#!/usr/bin/env bash
# Builds a side-by-side contact sheet: each row is [reference | ours] for one frame,
# stepping every 5th frame.
#
# Usage: tools/compare.sh <scene> <refFrameStart> <ourFrameStart> <count>
#   refFrameStart  1-based frame in reference/frames30 (f0001.png ...)
#   ourFrameStart  1-based frame in tools/out/<scene> (from record.sh)
#   count          number of rows; row i uses ref start+5i and ours start+5i
#
# Output: tools/out/<scene>/compare.png (rows at 360x640 per frame).
# For arbitrary key frames use tools/compare-sheet.sh.
set -euo pipefail

SCENE="${1:?usage: compare.sh <scene> <refFrameStart> <ourFrameStart> <count>}"
REF_START="${2:?}"
OUR_START="${3:?}"
COUNT="${4:?}"

REFS=""
OURS=""
for ((i = 0; i < COUNT; i++)); do
  REFS+="$((REF_START + 5 * i)) "
  OURS+="$((OUR_START + 5 * i)) "
done

exec "$(dirname "$0")/compare-sheet.sh" "$SCENE" "$REFS" "$OURS"
