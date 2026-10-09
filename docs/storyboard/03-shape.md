# 03 — Scene "Shape" — "Give it shape"

**Frames f0191–f0245 · scene-local t = 0.000–1.800 s · absolute 6.333–8.133 s.**
Starts from scene 2's end state (solid glowing asterisk at (360, 640)); ends as the asterisk dissolves into a pink→orange gradient pill at (360, 640) — scene 4 ("Details" card) starts at f0246 (abs 8.167 s) with the pill already 234–303 px wide (handoff only; scene 4 is out of scope here).
Design units 720×1280 px. Background `#010101`. Title fixed (00-common). Angles: screen degrees, clockwise from +x.

## Elements

| id | element | geometry / colour |
|---|---|---|
| A | Asterisk | solid 6-arm star. Tip radius **29 px**, valley radius ≈ 18 px, arm width ≈ 7 px (rounded, slightly tapered, faintly hand-drawn/curved), tips at **45° + 60k**. Fill: centre `#fcfc49`, mid (r 15) `#f2cd4d`, tip `#e5a930`, outer edge `#b86110`. Bloom: inner halo gold, outer halo to r ≈ 80 (luma>30 bbox 160 px) |
| K | Ring pulse | one thin circle centred on A, stroke 1–1.5 px, colour `#f0a060` at alpha ≈ 0.35 (sampled `#5d4a37` on black at f0225); bright (luma>150, near `#ffd27a`) while small, dimming as it expands |
| C | Caption | "Give it " sans ≈ 40 px white `#ffffff` + "*shape*" serif italic gold `#E9A94C` (edge sample `#e2cf9f` under glow); line centred x 361, bbox x 250–472 (w 223), glyph box y 612–659, baseline ≈ y 648. Sits **below** the asterisk |
| B | Pill (handoff) | capsule height **38 px**, centre (360, 640), horizontal gradient left `#fd7b80` → mid `#f07e46` → right `#de802d`, soft outer glow; width grows 234 (f245) → 303 (f246) → 338 → 356 → 369 (f250) … (continues in scene 4) |

## Timeline (t scene-local; frame = 191 + 30·t)

| t | frame | what happens | easing |
|---|---|---|---|
| 0.000 | 191 | A at (360, 640) | — |
| 0.00–0.30 | 191–200 | **A rises** to (360, 564): y = 640 (f190), 600 (f192), 579 (f194), 570 (f196), 566 (f198), 565 (f200), 564 (f204+). `y = 640 − 76·easeOutQuart(t/0.30)` | easeOutQuart |
| 0.30–1.63 | 200–240 | A holds at (360, 564); glow breathes ±10 % at ≈ 1 Hz | — |
| 0.37 | 202 | Caption **C** type-in: "Give" f202, "it" f206, "shape" f210→f214 sharp (word stagger 0.10–0.13 s, 0.20 s blur-in each; 00-common). Fully in at t ≈ 0.77 s (f214) | easeOut |
| 0.50 | 206 | **Ring pulse K** emitted from A: radius `r = 35 + 85·(1 − e^(−τ/0.45))`, τ = t − 0.50 (r = 48 f208, 57 f211, 69 f214, 78 f217, 85 f220, 92 f223, 97 f226, 102 f229, 107 f232, 110 f235). Alpha: 0.9 at τ = 0 → 0.35 by τ = 0.5 → fades to 0 over f235–f238 (τ 0.97–1.07) | exp ease-out, linear fade |
| 1.63 | 240 | **A dissolves into the pill**: A moves down (cy 568 f240 → 585 f242) and shrinks (bbox h 54 → 29) while its arms are absorbed into a horizontal capsule forming at y 640: f243 small bright blob ≈ (400, 640); f244 capsule core x 311–471 with two small yellow wisps (last arm tips) above its top edge at x ≈ 345–380; f245 capsule x 243–476 (w 234, h 54 incl. glow); f246 x 209–511 (w 303, h 38 clean) | easeIn (collapse) / easeOut (pill width) |
| 1.67 | 241 | Caption **C** blur-out, left to right: "Give" gone f242, "it" f244, "shape" still visible behind the forming pill at f245, gone by f247 | easeIn |
| 1.80 | 245 | Scene ends. **Handoff**: pill B width 234 → scene 4 continues the width growth (303 at f246, 338, 356, 369 …, asymptote ≈ 420 by f256) at centre (360, 640), h 38, no asterisk left | — |

## Motion details
- The asterisk is upright-static (no rotation) during the hold; its arm tips stay at 45°+60k (radial luma peaks at 29 px every 60°, valleys 18 px).
- The ring pulse starts bright and near the asterisk's halo colour, so for its first ~0.3 s it reads as a second, larger glow (luma>150 bbox 96–98 px at f212–f216); only after r ≈ 70 does it read as a thin dim ring.
- Caption and asterisk are vertically stacked: asterisk centre y 564, caption centre y ≈ 636; gap between asterisk tip (593) and cap top (≈ 618) ≈ 25 px.
- Pill birth: the capsule appears to grow outward from the asterisk's collapse point, widthwise, with fully rounded ends from the first frame (not a square growing into a capsule).

## Transition
- In: continuous from scene 2 (asterisk identical, then rises).
- Out: pill B at (360, 640), w ≈ 234–303, h 38, gradient as above; title unchanged; caption gone.

## Implementation notes (SwiftUI)
- Asterisk: 6 capsules (`Capsule().frame(width: 7, height: 29)` offset so the inner end sits at r ≈ 4, rotated 45°+60k), filled with a `RadialGradient` from the asterisk centre (`#fcfc49` 0 → `#f2cd4d` 0.5 → `#e5a930` 0.9 → `#b86110` 1.0). Add two blurred copies: blur 6 (alpha 0.8) and blur 30 (alpha 0.45, scaled 2.5×) in `.plusLighter`.
- Ring pulse: `Circle().stroke(lineWidth: 1.2)` with `.blur(1)`; colour/opacity from τ.
- Dissolve: scale the asterisk to 0 about its centre while translating to (360, 640) over 0.17 s (easeIn), and crossfade in the capsule (`Capsule().fill(LinearGradient(colors: [#fd7b80, #f07e46, #de802d], .leading→.trailing))`) whose width animates 0 → 234 over the same 0.17 s (easeOut) — then hand width to scene 4. Add `.shadow(color: #ff6b5a.opacity(0.6), radius: 24)` for the pill's bloom (00-common pill glow is a warm pink-red, not gold).
- Caption: same two-run `Text` component as scenes 1–2 (sizes: sans 40 px here, same as scene 2).

## Key frames to match (side-by-side)
f0194 (asterisk mid-rise, y 579), f0204 (asterisk at rest, "Give" appearing), f0214 (caption full, ring r 69 bright), f0225 (ring r ≈ 95 dim), f0236 (ring fading, r 110), f0242 (asterisk collapsing, "Give" gone), f0244 (capsule core + wisps), f0246 (pill w 303 — handoff frame).
