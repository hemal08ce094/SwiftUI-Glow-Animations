# Scene 7 — "Everything connects" (lemniscate comet)

Design space 720×1280, origin top-left. Scene time `t` = seconds since **f0624** (first fully black frame after the cream iris closes; the glowing dot is already on screen during the iris, frames 618–623, carried over from scene 6).

| | Frames | Video time | Scene t |
|---|---|---|---|
| Scene range | **f0624 – f0735** | 20.77 s – 24.47 s | 0.00 – 3.70 s |
| Hand-off | f0735 dot → scene 8 sphere grows from f0736 | | |

Preceding transition (owned by scene 6, noted for continuity): cream background is wiped by a black **circular iris** centred on the dot (360, 640) that opens from r≈0 at f0617 to r≈1500 (covers the frame) at f0624, ease-in; the title "Opus 5.5 is actually cooking" fades from cream-tinted to white as the iris passes it.

## Elements

### E1 Idle dot (f0624–f0639)
- Centre **(360, 640)**. Core radius ≈ 6 px, colour `#FFF8C1` (f0636 @350,630), edge `#F8DB84`; bloom radius ≈ 25 px, sampled `#7D501F` at 20 px off-centre. Static. Slight breathing (±5 % radius, ~1.2 s) is acceptable but not required.

### E2 Lemniscate path
- Centre **(360, 640)**. Horizontal half-extent **a = 258** (x: 102 → 618), vertical half-extent **≈ 120** (y: 520 → 760).
- Use a Bernoulli lemniscate with a vertical stretch:
  `x(θ) = 360 + a·cosθ / (1 + sin²θ)`
  `y(θ) = 640 + ky·a·sinθ·cosθ / (1 + sin²θ)` with `a = 258`, **`ky = 1.30`** (tune 1.2–1.35 so the lobe height is 240 px; crossing angle then ≈ 105°).
- Direction of travel from the crossing: θ = π/2 → π (up-left to far-left), π → 3π/2 (down to bottom-left and back to the crossing), 3π/2 → 2π (up-right to far-right), 2π → 5π/2 (bottom-right back to crossing).
- Stroke: ~3 px core + 10–12 px soft halo (blur ≈ 6 px) when lit.
- **Colour by position** (sampled on the fully lit f0720): far-left `#CF436A`, top-left `#D05254`, bottom-left `#BE4646`, near-crossing left `#FF7A48` (orange), crossing `#F8FEFB` (white-hot), near-crossing right `#FFD27A`, top-right `#D6C36A`, bottom-right `#B7A55F`, far-right `#C9B466`. Model as a gradient over θ: pink/magenta at θ=π, blending through orange to white at the crossing, through yellow to gold at θ=2π.

### E3 Comet
- Head: core radius ≈ 7 px, colour `#FCFDFE` (white-hot), bloom radius ≈ 28 px (`#F8DB84` falling to transparent). Rendered with additive blending so the head reads as hotter than the path.
- Trail: the path segment behind the head, length **≈ 0.35 of the full perimeter**, drawn with the position colour of E2 but fading to the persistent-line opacity. Alpha along the trail (s = 0 at head → 1 at tail): `alpha = 0.08 + 0.92·(1 − s)^2.2`; width tapers 3 px → 1.5 px. Just behind the head the trail is white (`#FCE9D0` at 10 px back) before taking the path colour (≈40 px back).
- Persistent line: once the head has passed, the path stays at **≈ 8 % opacity** (f0700 @ right lobe `#0A0704`, top-right `#19120C`), 1.5 px wide. The left lobe (passed more recently on the second pass) reads a bit brighter (~12 %).

### E4 Caption "Everything connects"
- Baseline band centred at **y ≈ 865**, horizontally centred (text spans x≈190–530). "Everything" white sans, "connects" italic serif, warm gold `#E6A24C` (see 00-common.md for faces/sizes and the blur-wipe reveal recipe).
- Reveal: left-to-right blur wipe, "Everything" f0644–f0652, "connects" f0652–f0663. Out: same wipe f0726–f0732.

## Timeline (t from f0624)

| t (s) | frame | what happens | easing |
|---|---|---|---|
| 0.00 | 624 | Black. Idle dot at centre. | — |
| 0.53 | 640 | Comet departs the crossing heading up-left; trail begins. | velocity ramps in over ~4 frames (ease-in 0.13 s) then constant parameter speed |
| 0.67–0.93 | 644–652 | "Everything" wipes in. | linear wipe, 8 px blur |
| 0.93–1.30 | 652–663 | "connects" wipes in. | linear wipe |
| 1.30 | 663 | Comet reaches bottom-left (θ≈5π/4). | — |
| 1.57 | 671 | Comet passes the crossing (θ=3π/2) into the right lobe. | — |
| 2.07 | 686 | One full loop done (θ=5π/2); comet continues into the left lobe again. | constant |
| 2.93 | 712 | Comet arrives at the crossing (θ=7π/2) and **stops**. Head flares (bloom ×1.6 for 3 frames). | ease-out over last 0.15 s |
| 2.93–3.13 | 712–718 | **Ignite**: the whole lemniscate lights up, spreading from the crossing outward along both lobes (reaches the far ends last). | ease-out |
| 3.13–3.40 | 718–726 | Hold: full lemniscate, white crossing dot, faint 1.5 s pulse of halo (±10 %). | — |
| 3.40–3.60 | 726–732 | Caption wipes out. | linear |
| 3.53–3.70 | 730–735 | **Collapse**: lemniscate scales about the centre to 0 (both lobes shrink inward; line brightness held), leaving the white-hot dot (r≈8, bloom 30). | ease-in (cubic) |
| 3.70 | 735 | Dot only → hand off to scene 8. | — |

### Motion formulas
- Comet parameter: `θ(t) = π/2 + 2π·(t − 0.53)/1.53` for `0.53 ≤ t ≤ 2.93` (1.5 loops; **0.65 loops/s**; constant parameter speed, which naturally makes the head faster through the crossing and slower at the lobe tips — matches the reference). Clamp at 7π/2.
- Ignite: `lit(θ, t)` = 1 where the path distance from the crossing (along either direction) < `(t − 2.93)/0.20 · (perimeter/2)`, with a 60 px soft edge.
- Collapse: `scale(t) = 1 − easeInCubic((t − 3.53)/0.17)`.

## Implementation notes
- `TimelineView(.animation)` + `Canvas`. Build the lemniscate once as a `Path` of ~400 line segments (θ sampled uniformly), keep the cumulative arc length so "fraction of perimeter" is cheap.
- Trail: draw the sub-path for `[θ_head − Δ, θ_head]` in ~40 segments, each with its own colour/alpha/width (per-segment `stroke` in Canvas); then draw the head as two radial-gradient circles. Use `context.blendMode = .plusLighter` for head and trail so overlaps glow.
- Persistent path: full path stroked at 8 % opacity, 1.5 px — only the portion already visited (`θ < θ_head`).
- Ignite/full: stroke the full path with an `AngularGradient`-like per-segment colour (E2 table), width 3, plus the same path blurred (`context.addFilter(.blur(radius: 6))` in a separate layer) at 70 % for the halo; white crossing dot on top.
- Collapse: wrap the drawing in `context.scaleBy` about (360,640).
- Caption: `Text` with `AttributedString` (serif italic run); reveal via a mask that slides + a `blur` modifier keyed to progress (recipe in 00-common.md).

## Key frames to match
f0636 (idle dot), f0648 (comet departing, text starting), f0660 (bottom-left, trail back to crossing), f0675 (right lobe, persistent faint left lobe), f0700 (second pass bottom-left), f0712 (head stopped at crossing), f0716 (ignite half-spread), f0720 (full lemniscate), f0732 (mid-collapse), f0735 (dot).
