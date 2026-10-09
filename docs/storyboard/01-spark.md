# 01 — Scene "Spark" — "Start with a spark"

**Frames f0001–f0104 · t = 0.000–3.433 s (scene-local = absolute)**. Scene ends holding a small white-gold dot at (360, 640); scene 2 starts from that exact state at f0105.
Design units 720×1280 px, origin top-left, y down. Background `#010101`. Title fixed (see 00-common).

## Elements

| id | element | geometry / colour |
|---|---|---|
| T | Title | as 00-common, static, opacity 1 from f0001 |
| S | Spark | capsule, core white `#fffefb`, bloom per 00-common (core r 7 → halo r ≈ 27 at rest). Width 13 px; length stretches with speed (see timeline) |
| W | Splash beam | vertical capsule at x 360, bottom fixed at y 800, width 13 px core (40 px with glow), top rises to y 734 then collapses |
| D | Splash droplets | 6 small dots (r ≈ 3, white-gold) on an ellipse a≈70, b≈15 around (360, 790), visible f0036–f0046, rotating ~1 turn during their life |
| R | Ripple rings | 5 concentric ellipses, centre (360, 824), **b/a = 0.22**, stroke 1.5 px, colour gold `#c9923a` → inner rings brighter `#ffd27a`; outer ring alpha 0.55, inner 0.9. Radius fractions of the outer: `[1.00, 0.76, 0.49, 0.34, 0.19]` |
| C | Caption | "Start with a" (sans ≈ 46 px, cap 31 px, white) + "*spark*" (serif italic, gold `#E9A94C`), baseline y ≈ 541, line centred x 360 (bbox x 201–519) |
| U | Sun | disc, core white `#fefefe` r 22 → r 42 at peak; halo (gold `#ffd36a` → amber) r ≈ 3.5× core; see 00-common bloom |
| F | Horizontal flare | 1 px-core horizontal line through the sun centre y 639, full width, gold `#f0b050`, soft 6 px glow, alpha fades to 0 at x = 0 / 720 |
| X | Reflection | 8 horizontal bars under the sun on the ring plane: y = 700 + 12·i, height 3, widths 90·(1−i/9) ±10 % jitter per frame, colour `#f0a030`, alpha 0.8·(1−i/8) |
| G | Flash | full-screen radial glow centred on the sun: colour `#e9b265` → `#6c411c` at r 450 → 0 at r 650 |

## Timeline (t in s, frame = 30·t + 1)

| t | frame | what happens | easing |
|---|---|---|---|
| 0.000 | 1 | Title visible. Nothing else. | — |
| 0.133 | 5 | Spark **S** pops in at (360, 373): diameter 6 → 24 px (glow bbox) by f0010 (0.30 s) | easeOut 0.17 s |
| 0.30–0.57 | 10–18 | S holds at (360, 373), gentle flicker ±8 % brightness | — |
| 0.567 | 18 | S starts to fall: `y = 373 + 2350·τ²` (τ = t − 0.567), i.e. constant acceleration 4700 px/s². Length of the capsule tail = 22 + 110·τ px (22 → 47 px at f0030), brightest end downward | accelerate (quadratic) |
| 1.00 | 31 | **Impact** at y = 824 (ring-plane centre). S is removed. | — |
| 1.03 | 32 | Rings **R** start: outer half-width `a(τ) = 285·(1 − e^(−τ/0.42))`, τ = t − 1.03 (a = 80 @ f36, 127 @ f40, 185 @ f46, 251 @ f60, 280 @ f80); b = 0.22·a; inner rings scale with fixed fractions | exponential ease-out |
| 1.10 | 34 | Splash beam **W** appears: top rises 776 → 756 (f36) → 742 (f38) → 734 (f40) | easeOut 0.2 s |
| 1.30–1.43 | 40–44 | W collapses: width 40 → 13 → 6 px, top falls back; becomes a dot at (360, 756) at f44, (360, 784) at f46, gone at f48 | easeIn 0.2 s |
| 1.17–1.50 | 36–46 | Droplets **D** visible (fade in 0.1 s, out 0.1 s) | — |
| 1.20 | 37 | Caption **C** type-in begins (per 00-common: words "Start/with/a/spark" at +0, +0.10, +0.20, +0.30 s, each 0.20 s blur-in). Fully sharp at f0051 (1.67 s) | easeOut per word |
| 1.90 | 58 | Sun **U** begins rising from below the ring plane: `y_sun = 835 − 196·easeOutCubic((t − 1.90)/0.93)`, clipped by a horizontal mask at y = 800 while y_sun > 760 (the disc emerges as a dome through the rings, rings drawn on top of the sun) | easeOutCubic 0.93 s |
| 2.37 | 72 | U clear of the plane (centre y 721). Core r = 15 → 22 by f0082 | easeOut |
| 2.50 | 76 | Reflection **X** fades in under the sun (alpha 0 → 1 over 0.2 s) | easeOut |
| 2.77 | 84 | Flare **F** fades in (0 → 1 over 0.13 s) | easeOut |
| 2.83 | 86 | U reaches y 639 and swells: core r 25 → 42 by f0088 (0.07 s) | easeIn |
| 2.90 | 88 | **Flash G**: full-screen glow at peak for 1 frame (far-corner luminance ≈ `#6c411c`), then alpha `e^(−(t−2.90)/0.10)` → gone by f0096. Rings R fade out over the same 0.27 s. Reflection X and flare F fade out f0088–f0094 | spike + exp decay |
| 2.97 | 90 | U collapse begins: core r 42 → 7 by f0098 (0.27 s). Halo collapses with it | easeInCubic |
| 3.13 | 95 | Caption **C** blur-out (right-to-left remnants, done by f0100, per 00-common) | easeIn |
| 3.23–3.43 | 98–104 | Dot holds at (360, 640): core r 7 `#fafffe`, halo r ≈ 20 gold. **End state for scene 2.** | — |

## Motion details
- Spark fall: 376 px in 0.433 s with v₀ = 0 → acceleration 4700 px/s². The visual tail is a motion-blur capsule, not a particle trail; keep the bright end at the leading (lower) tip.
- Ring plane: ellipses are concentric at (360, 824) at this ratio; no visible perspective drift (far/near edges symmetric within 2 px for the outer two rings). Innermost ring is mostly hidden by the beam/sun bloom.
- Ring expansion is a single growth law for all rings (no successive emission): measured outer half-widths 54, 80, 104, 127, 148, 168, 185, 213, 237, 251, 261, 268, 274, 280 at f34…f80.
- Sun rise path (core centre y): 721 (f72), 707 (f74), 688 (f76), 671 (f78), 657 (f80), 646 (f82), 642 (f84), 639 (f86+).
- Sun halo at rest (f0080): visible radius ≈ 160 px (luma > 60) around a 45 px core → ratio 3.5. At the flash frame the halo bbox is 573 px wide.
- Flash is additive over everything including the title (title stays white; the dark bg lifts to brown).

## Transition
- In: hard start (title already present).
- Out: everything except the title and the centre dot is gone by f0100; the dot persists unchanged into scene 2.

## Implementation notes (SwiftUI)
- Drive the whole scene from one `TimelineView(.animation)` → `t`; draw in a `Canvas` sized 720×1280 (scaled) with `context.blendMode = .plusLighter` for glows on a black `Rectangle`.
- Spark/sun/droplets: `fill(Path(ellipseIn:), with: .radialGradient(...))` stops white → `#ffd36a`@0.3 → `#f0a030`α0.4@0.6 → clear@1.0.
- Rings: `Path(ellipseIn: CGRect(x: 360−a, y: 824−b, w: 2a, h: 2b))` stroked 1.5 px; add a second stroke with `blur` 3 px at 50 % alpha for the soft look (use `context.addFilter(.blur(radius:))` in a nested layer).
- Flash: `.radialGradient` covering the frame, opacity curve above.
- Horizontal mask for the rising sun: clip the sun layer to `CGRect(y: 0, h: 800)` until it is clear.
- Reflection bars: deterministic jitter via `sin(t·37 + i)` so previews are stable.
- Caption: `Text` with two runs (sans + italic serif), per-word `.blur(radius:)`+`.opacity` driven by `t` (see 00-common); keep the line pre-laid-out (fixed frame) so words don't reflow.

## Key frames to match (side-by-side)
f0010 (spark at rest), f0028 (spark stretched mid-fall), f0040 (beam + droplets + rings a≈127), f0060 (rings a≈251, dome emerging, caption full), f0080 (sun at y 657 with reflection), f0088 (flash peak), f0094 (collapse mid-way), f0102 (dot hold).
