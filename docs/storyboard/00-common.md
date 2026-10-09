# 00 — Common facts (scenes 1–3 analysis)

Source: `reference/frames30/fNNNN.png`, 720×1280, 30 fps, frame n ↔ t = (n−1)/30 s.
**All numbers below are in 720×1280 design px.** Measurements via luma bounding boxes (threshold noted) and 3×3 pixel averages; ±2 px, ±1 frame.

## Background
- Dark scenes: `#010101` (effectively black). Stays black except during the scene-1 flash (see 01-spark).
- Light (cream) scenes appear later (scene 5+, out of this doc's scope).

## Title — "Opus 5.5 is actually cooking"
- Present on every frame from f0001, unchanged through f0247 (and on).
- Bounding box (luma>60): x 88–631 (w 544), y 297–339 (h 43). Centre x 360 (centred), baseline ≈ y 329, descender of "g/y" to y 339.
- Cap height ("O" 297→329) = 33 px → **font size ≈ 46 px** (cap-height ≈ 0.72 em for this family).
- Weight: Regular/400 (stroke ≈ 3 px at 46 px). Colour `#ffffff`, no glow, no letterspacing beyond default. Single line, no fade-in observed at f0001 (already fully opaque).
- Typeface: geometric sans with a **single-storey "a"**, round "O", "g" single-storey with open tail, "k" with straight diagonals meeting the stem, "y" straight tail, "t" with slanted cut. Compared against candidates:
  - **Outfit — best match (high confidence ~85%)**: single-storey a, geometric round bowls, the "5" with a flat top and open bowl, low x-height-ish proportions and the "ki" spacing all match Outfit Regular.
  - Jost: also single-storey a but "t" and "g" differ (Jost "g" has a tighter hook), and Jost's "s" is narrower. Second choice.
  - Sora/Urbanist: double-storey "a" in both → excluded.
- SwiftUI: bundle `Outfit-Regular.ttf` (OFL). Fallback `.system(size: 46, weight: .regular, design: .rounded)` is visibly different; don't ship it as "exact".

## Caption — "<sans words> <italic serif word>"
Example "Start with a *spark*" at f0085 (fully in):
- Full bbox (luma>40): x 171–553 (w 383), y 490–559; cap "S" 500→549 → cap height 50 px? No — the "S" box includes the glow bleed; the clean sans cap height (f0066, no glow) is 507→545 = ~38 px → **sans size ≈ 52 px**, weight Regular, colour `#ffffff`. Slight warm tint at f0085 is the sun glow, not the type colour.
- Italic serif word "spark": bbox x 415–534 (w 120), y 495–549; x-height ≈ 26 px, ascender 495; **size ≈ 52 px** (same em as the sans), colour peak `#fff4a0`-ish under glow; in the clean frame f0066 the word is `#e8a84a`-class gold — **use `#E9A94C`** (sampled gold, see 02/03 for confirmation samples `#eaa64b`, `#e7a447`).
- Serif italic family: high-contrast transitional italic with a looped "p" descender, flat-topped "a", ball-less "k", narrow set width — matches **Instrument Serif Italic** (confidence ~75%). Alternatives considered: Playfair Display Italic (too high contrast, swash "k"), Cormorant Italic (too light/narrow). Bundle `InstrumentSerif-Italic.ttf` (OFL).
- Layout: one line, baseline ≈ y 545, whole line centred at x 360. Word gap between sans and serif is the normal space of the sans font.

### Caption type-in (measured on "Start with a spark", f0036–f0051)
- Nothing at f0036. f0039: "Start" visible sharp, "with" present but **blurred ~6 px** and dim; f0042: "Start with" sharp, "a" blurring in; f0045: "…a" sharp, "spark" blurred/dim; f0048: all words readable, "spark" still soft; f0051: fully sharp.
- So each word appears **sequentially, left to right, ≈3 frames (0.10 s) apart**, and each word transitions over ≈6 frames (0.20 s) from `blur 8 px + opacity 0` → `blur 0 + opacity 1`, ease-out. Words do not move (no y-offset). Formula: for word i (0-based), start = T0 + 0.10·i s, u = clamp((t−start)/0.20), opacity = u, blur = 8·(1−u).
- Caption centre stays fixed (line is pre-laid-out at final width; words fade in place).

### Caption blur-out
- f0096 → f0100: words dissolve **right-to-left** ("spark" is the last to be visible at f0098 but it is fading at the same time as the rest). Measured: f0094 full; f0096 "Start" gone, "with a spark" dim; f0098 only remnants of "spark"; f0100 nothing. Total ≈ 5 frames (0.17 s), each word blur 0→8 px with opacity 1→0, staggered 1 frame per word from the left. Treat as reverse of type-in with 0.03 s stagger and 0.13 s per-word duration.

## Bloom / glow recipe (observed on spark, sun, nodes)
Three concentric layers, all additive on black:
1. **Core**: white-hot `#ffffff`/`#fffefb` disc.
2. **Inner halo**: saturated gold `#ffd36a`→`#f0a030`, radius ≈ 2× core radius, soft edge.
3. **Outer halo**: amber falling to black, radius ≈ 5–8× core radius, very low alpha. Sampled falloff on the sun (core r≈45): r=80 `#c48b40`, r=150 `#86541d`, r=220 `#59330d` → roughly exponential, alpha ∝ e^(−r/110).

SwiftUI: `ZStack { Circle().fill(amber).frame(r*8).blur(r*2.2).opacity(0.55); Circle().fill(gold).frame(r*2.5).blur(r*0.6); Circle().fill(white).frame(r*2) }.blendMode(.plusLighter)` inside a black-backed `.drawingGroup()`; or `Canvas` with `RadialGradient` stops white→gold(0.25)→amber(0.5, α0.35)→clear(1). Use `.plusLighter` so overlapping nodes/rings add light like the reference.

## Units & rendering convention
- Design canvas 720×1280; implementer scales uniformly to fit, centred. Every element is a pure function of scene-local time `t` (seconds).
- Easings referenced in the scene docs: `linear`, `easeOut` (cubic), `easeInOut` (cubic), `spring(overshoot)`.
