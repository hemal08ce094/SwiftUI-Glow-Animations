# Scene 9 — Outro (asterisk, credit, ring)

Design space 720×1280. Scene time `t` = seconds since **f0856** (orange ball starts sprouting arms). Black background; title stays at y≈315.

| | Frames | Video time | Scene t |
|---|---|---|---|
| Scene range | **f0856 – f0950** (end of reel) | 28.50 s – 31.63 s | 0.00 – 3.13 s |
| Hand-in | f0855: orange ball r≈34, `#FDA24A`, 20 px glow at (360,640) | | |

## Elements

### E1 Asterisk
- Six rounded arms at 60° spacing, **tip-to-tip 74 px** (vertical extent 602→674 at f0862 with a vertical arm; L ≈ 37 from centre), arm width ≈ 16 px at the hub tapering to ≈ 12 px with **round caps** (the arms read as slightly petal-like, see z0866: faint widening before the cap). A small hub radius ≈ 10 px fills the centre.
- Colour: solid yellow `#FDFB4D` at the centre, `#F7DF37` toward the tips, rim `#F0A030`; glow halo out to ≈ 40 px beyond the tips in `#C8781A` (sampled `#783A0D` at 35 px, `#422107` at 52 px). Rendered additive: arms `blur(1.5)`, halo = arms `blur(16)` @ 70 % + `blur(34)` @ 35 %.
- Orientation: at f0862–f0870 one arm points straight up (90°). The bright-pixel tip angle drifts 28° → 23° → 19° (mod 60) over f0862/870/880, i.e. a **slow clockwise rotation ≈ 15°/s** from scene start. Treat as `rotation(t) = −15°·t`; stop or keep going after f0900 — not measurable once the credit shares the frame (ambiguous, see summary).
- Position: centre **(360, 639)** until f0872, then rises to **(359, 595)** by f0882 (ease-out; 599 at f0876, 594 at f0880, 592 at f0884), settles at ≈ (358, 597). The rise makes room for the credit so the asterisk+credit group is centred on the old sphere centre.
- Pulse: faint breathing of the halo (±8 %, period ≈ 1.6 s).

### E2 Credit "louisraille.fr"
- Baseline **y ≈ 700**, ascender top y ≈ 682 → sans ≈ **25 px**; x-extent **267 → 452** (185 px), centred at x≈360. "louisraille" off-white `#E8E4E0`; ".fr" muted gold `#C9A26E` (sampled `#BC9A71` on the f). Typography in 00-common.md.
- Reveal: left-to-right blur wipe **f0881 → f0897** (edge x ≈ 267 + 15·(f − 881)): f0884 →313, f0888 →374, f0892 →420, f0896 →448. No out.

### E3 Hairline
- Very faint horizontal line at **y ≈ 810**, x ≈ 255 → 440 (≈ 190 px, gradient fading to nothing at both ends, brightest at centre), peak ≈ 3–4 % luminance, warm (`#FF8A3A` @ 4 %). Fades in with the credit (≈ f0888 → f0900). It is barely visible; ship it at 4–5 % opacity, 1 px.

### E4 Ring pulse (single)
- Thin circle centred on the asterisk (358, 597), **1 px**, colour warm gold `#C9A36A` (sampled `#98754E` at f0900, `#564330` at f0906 as it fades).
- Radius: f0898 ≈ 45 → f0900 60 → f0902 76 → f0904 89 → f0906 100 → f0908 108 → f0910 115 → f0912 121 → f0914 125 → gone by f0916.
  `r(t) = 45 + 85·(1 − (1 − u)^2)`, `u = (t − 1.40)/0.53`, for `1.40 ≤ t ≤ 1.93`.
- Opacity: 0.48 at f0900 → 0.33 (902) → 0.28 (906) → 0.16 (910) → 0.12 (914) → 0: `alpha = 0.5·(1 − u)^1.5`.
- Only one pulse was measured (f0898–f0915); frames 916–950 show no ring outside the glow.

### E5 Hold
- f0916–f0950: asterisk (with its slow rotation/pulse), credit and hairline static. Reel ends on f0950.

## Timeline (t from f0856)

| t (s) | frame | what happens | easing |
|---|---|---|---|
| 0.00–0.17 | 856–861 | Ball (r 34, orange) sprouts six arms: arms grow from 0 to L=37 while the hub shrinks to r 10 and the colour shifts orange `#FDA24A` → yellow `#FDFB4D`. Vertical arm first visible f0857. | ease-out |
| 0.17–0.53 | 861–872 | Asterisk hold at (360,639); slow rotation begins. | — |
| 0.53–0.87 | 872–882 | Asterisk rises 639 → 595. | ease-out (cubic) |
| 0.83–1.37 | 881–897 | Credit wipes in; hairline fades in beneath (888–900). | linear wipe |
| 1.40–1.93 | 898–914 | Ring pulse expands 45 → 125 px and fades. | ease-out radius, ease-in fade |
| 1.93–3.13 | 914–950 | Hold. | — |

## Implementation notes
- Asterisk as a `Shape`: six capsules (`RoundedRectangle` with full corner radius) rotated by 60° steps around the centre, unioned; `animatableData` = arm length so the sprout from the ball is a morph of the same shape (arm length 0 + hub radius 34 → arm 37 + hub 10). Draw it three times in a `ZStack`: sharp, `blur(16)` @ 70 %, `blur(34)` @ 35 %, all `.blendMode(.plusLighter)` on black.
- Rotation via `rotationEffect(.degrees(-15 * t))`.
- Credit: `Text` with an `AttributedString` (`.fr` run coloured), blur-wipe mask shared with the other captions.
- Ring: `Circle().stroke(lineWidth: 1)` scaled by `r(t)` and faded; or draw in the same `Canvas` as the asterisk.
- Hairline: 1 px `Rectangle` with a horizontal `LinearGradient` clear → `#FF8A3A` → clear, `opacity(0.05)`.
- Everything is a pure function of `t`; the whole scene is cheap, so no `drawingGroup` needed.

## Key frames to match
f0856 (ball), f0858 (arms half-grown), f0866 (asterisk at 639, vertical arm), f0878 (rising), f0888 (credit half-revealed), f0896 (credit complete), f0902 (ring r≈76, bright), f0910 (ring r≈115, faint), f0930 (hold).
