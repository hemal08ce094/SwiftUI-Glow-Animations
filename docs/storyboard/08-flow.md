# Scene 8 — "Stay in flow" (sphere → metaballs → sphere)

Design space 720×1280. Scene time `t` = seconds since **f0736** (first frame the collapsed dot starts growing into the sphere). Black background throughout; title stays at y≈315.

| | Frames | Video time | Scene t |
|---|---|---|---|
| Scene range | **f0736 – f0855** | 24.50 s – 28.47 s | 0.00 – 4.00 s |
| Hand-in | f0735: white-hot dot r≈8 at (360,640) from scene 7 | | |
| Hand-off | f0855: orange ball r≈32 at (360,640) → scene 9 sprouts the asterisk | | |

## Elements

### E1 Sphere (rest state, f0748–f0756 and f0836–f0848)
- Centre **(360, 640)**, radius **117 px** (edge measured 528→749 on x=360 at f0745; 504→752 at f0840 incl. soft edge).
- Soft edge: brightness falls from 100 % to 10 % over **≈ 14 px** (f0840 row 640: x 240→254), then an outer glow to ≈ 35 px at ≤ 4 %. Model: `blur(8)` on the disc + a second copy `blur(28)` at 25 %.
- Shading = lit from the upper-left, warm-to-gold top-to-bottom. Samples (f0840):
  - top (360,545) `#FB6D33`, top-left rim (272,575) `#FD9665` (pale highlight band), (285,565) `#FF8A53`
  - top-right (420,570) `#FD7430`
  - centre-left (280,600) `#FF8334`, left edge (250,640) `#ED8530`
  - centre (358,660) `#F5A342`, (358,700) `#FDA13B`
  - bottom-left (300,700) `#FB9730`, bottom-right (420,700) `#E5842B`
  - right rim (470,640) `#BE5914`, bottom rim (360,740) `#AA5D1F`
- Recipe: fill disc with a vertical `LinearGradient` `#F85F30` (top) → `#FDA044` (55 %) → `#FBB246` (bottom); multiply/overlay a `RadialGradient` centred at (−0.3, −0.35) of the disc (upper-left) from white @ 35 % → clear @ 60 % radius → `#8A3A10` @ 45 % at the rim (right/bottom darkening). Inner edge blur 8 px.

### E2 Caption "Stay in flow"
- Centred on the sphere at **(360, 640)**; bounding box x 253–467 (214 px), cap-top y 625, baseline y ≈ 652 → sans ≈ **38 px**, white `#FAEECE`-ish (cream white). "flow" is **italic serif, also white** (not gold — differs from the other captions). Typography in 00-common.md.
- Reveal: left-to-right blur wipe **f0758 → f0770** (edge moves ≈16 px/frame; "Stay" by f0762, "in" by f0766, "flow" by f0770).
- Out: left-to-right wipe **f0841 → f0847**.
- Text is drawn **above** the blob and does not deform with it.

### E3 Metaball system (f0754–f0836)
Render the union of 3–4 soft circles with one global fill: vertical gradient **red at top → orange → gold at bottom** (`#F4502E` at y=450, `#FD8A3A` at y=560, `#FDA44A` at y=660, `#FFC24C` at y=800) so a lobe's colour comes from its height on screen. Sampled: red ball core `#FC6848` / rim `#FE8660` (f0792 @448,470 / 455,455), red merging lobe `#FF774C` (f0812 @370,500), orange lobe `#FF9A51` (f0792 @230,570), gold lobe `#FFB857` (f0792 @437,750), `#FFBD5E` (f0812 @327,777). Each lobe keeps the sphere's upper-left highlight / lower-right rim shading (E1 recipe applied per circle before union).

Keyframes (centre x, y, radius). Interpolate with Catmull-Rom; the union is rendered as metaballs (see implementation notes). Coordinates are approximate (±8 px); the character of the motion matters more than exact numbers.

| frame | t | A (upper lobe) | B (core lobe) | G (gold lobe) | R (red ball) | note |
|---|---|---|---|---|---|---|
| 752 | 0.53 | (360,640,117) | — | — | — | sphere |
| 760 | 0.80 | (395,585,82) | (345,690,95) | — | — | egg tilted ~35°, point up-right |
| 770 | 1.13 | (360,560,80) | (300,700,85) | (440,640,70) | — | lumpy triangle |
| 778 | 1.40 | (360,600,85) | (300,690,80) | (437,766,60) | (402,493,44) | R budding at top, attached by a neck |
| 786 | 1.67 | (234,612,70) | (374,668,75) | (486,780,62) | (437,472,38) | R detached; body stretches ↘ |
| 792 | 1.87 | (230,570,68) | (350,623,78) | (437,750,66) | (453,460,38) | maximum spread (ref z0792) |
| 800 | 2.13 | (276,570,72) | (360,660,78) | (444,808,55) | (437,472,38) | |
| 806 | 2.33 | (330,520,75) | (380,640,80) | (360,794,46) | (423,472,38) | R touches top-right; G hangs below on a neck |
| 812 | 2.53 | (370,520,85) | (420,620,80) | (327,777,55) | absorbed | body now red-topped |
| 820 | 2.80 | (374,500,80) | (330,640,85) | (290,766,55) | — | G swings to bottom-left, merging |
| 826 | 3.00 | (430,530,85) | (330,690,90) | absorbed | — | tilted egg, point up-right |
| 834 | 3.27 | (350,620,105) | (370,660,100) | — | — | nearly round |
| 840 | 3.47 | (360,640,117) | — | — | — | sphere |

### E4 Shrink and hand-off
- Sphere radius: f0848 117 → f0850 108 → f0852 76 → f0854 47 → f0855 ≈ 34, ease-in. Colour stays orange; the ball at f0855 is `#FDA24A` with a 20 px glow. Scene 9 takes it from here.

## Timeline (t from f0736)

| t (s) | frame | what happens | easing |
|---|---|---|---|
| 0.00–0.43 | 736–748 | Sphere grows from r≈8 to 117 at (360,640). r(f): 736→34(incl. glow) / 738→60 / 740→80 / 742→97 / 745→111 / 748→117. | ease-out (r = 117·(1−(1−u)^2.5)) |
| 0.43–0.60 | 748–754 | Rest. | — |
| 0.60–1.13 | 754–770 | Sphere deforms into a tilted egg, then a lumpy three-bump blob. | smooth |
| 0.73–1.13 | 758–770 | Caption wipes in over the blob. | linear wipe, 8 px blur |
| 1.13–1.67 | 770–786 | Red ball buds at top-right and detaches; gold lobe grows at bottom; body stretches ↘. | smooth |
| 1.67–2.13 | 786–800 | Max spread; red ball floats near (440,470), body long diagonal. | slow drift |
| 2.13–2.53 | 800–812 | Red ball drifts back and merges at the top. | ease-in |
| 2.33–2.80 | 806–820 | Gold lobe detaches briefly below, swings to bottom-left, merges. | smooth |
| 2.80–3.47 | 820–840 | Blob rounds back into the sphere (tilt rotates from ↘ to ↙ on the way). | ease-out |
| 3.47–3.50 | 840–841 | Rest sphere with caption. | — |
| 3.50–3.70 | 841–847 | Caption wipes out. | linear |
| 3.73–4.00 | 848–855 | Sphere shrinks to r≈34. | ease-in (quadratic) |

Overall period of the blob dance ≈ 2.9 s; each lobe moves on a smooth closed-ish arc; nothing is linear.

## Implementation notes
- `TimelineView(.animation)` driving a `Canvas`. Draw each circle into a layer with the shading recipe, then union them with a **metaball filter**: `context.addFilter(.alphaThreshold(min: 0.5, color: .white))` over `context.addFilter(.blur(radius: 22))` applied to a layer where each circle is drawn as a solid disc — this gives the fused silhouette; use that silhouette as a mask (`context.clipToLayer`) for the gradient fill + per-lobe highlights drawn on top. Then `blur(8)` the result for the soft edge and add the 25 % `blur(28)` glow copy. Keep ~0.5 threshold and 20–24 px blur so necks form/snap like the reference (f0778, f0806).
- Alternative without filters: draw the circles with `blendMode(.plusLighter)` on radial-gradient fills and accept a softer union (less faithful necks).
- The caption is a `Text` with an `AttributedString` run (serif italic), fixed at the centre, outside the blob layer, with the blur-wipe mask.
- Keep all keyframe arrays as `[CGFloat]` and interpolate per frame; hold a `scenePhase` guard so the heavy canvas only animates while on screen.

## Key frames to match
f0740 (sphere growing), f0748 (rest sphere), f0762 (egg + "Stay in" reveal), f0770 (lumpy blob, caption complete), f0778 (red bud + gold lobe), f0792 (max spread), f0806 (red returning, gold hanging), f0820 (gold merging bottom-left), f0840 (sphere + caption), f0852 (shrinking).
