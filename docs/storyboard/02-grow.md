# 02 — Scene "Grow" — "Let it grow"

**Frames f0105–f0190 · scene-local t = 0.000–2.833 s · absolute 3.467–6.300 s.**
Starts from scene 1's end state (white-gold dot at (360, 640)); ends holding a solid glowing 6-arm asterisk at (360, 640), which scene 3 picks up.
Design units 720×1280 px. Background `#010101`. Title fixed (00-common). All angles below are **screen angles**: degrees clockwise from +x, y down.

## Elements

| id | element | geometry / colour |
|---|---|---|
| P | Centre dot | from scene 1: core r 7 white, gold halo. At t = 0 it flares (glow bbox luma>150 grows 42 → 68 px for ~2 frames) and launches the ring; it then fades out by t ≈ 0.3 s |
| O | Ring | circle, centre (360, 640), stroke **2 px** + 4 px soft glow. Colour is an angular gradient (see "Ring highlight"): cream `#f4e6d2` base with a hot 120° segment yellow→orange→pink that **rotates clockwise at ≈270°/s** |
| N | Nodes | **6**, 60° apart, on the ring. Core r 5 white `#fefcfd`; halo r ≈ 16, colour `#b57e38` at +10 px (00-common bloom). They fly out from the centre with a comet tail, then ride the ring (and later sit on the petal tips) while the whole set rotates clockwise at **22.5°/s** |
| C | Caption | "Let it " sans **≈ 40 px** (cap 29 px, white `#ffffff`) + "*grow*" serif italic gold `#E9A94C`; centred (361, 645), bbox x 272–450 (w 179), baseline ≈ y 655; drawn **inside** the ring |
| L | Flower | the ring morphs into a 6-petal outline = **union of 6 circles** (radius ρ, centres at distance d, angles φ+60k) — outline only, same stroke/gradient as O. Nodes sit on the petal tips |
| A | Asterisk | end state: solid 6-arm star, arm tip radius 29 px, arm width ≈ 7 px (rounded, slightly tapered), tips at angles 45°+60k, fill gradient centre `#fcfc49` → mid `#f2cd4d` → tip `#e5a930`; glow halo r ≈ 80 low alpha (see 03 for colour samples) |

## Timeline (t scene-local; frame = 105 + 30·t)

| t | frame | what happens | easing |
|---|---|---|---|
| 0.000 | 105 | Dot **P** flares (×1.6 glow for 0.07 s) and **ring O** is emitted from it | — |
| 0.00–1.00 | 105–135 | **O radius**: 7 → 164 with overshoot: r = 57 (f106), 100 (f108), 135 (f110), 160 (f112), 174 (f114), 179 (f116), **180 (f118, max)**, 178 (f120), 174 (f122), ≈ 170 (f126), 164 (f135 on). Model: `spring(response: 0.45, dampingFraction: 0.62)` from 7 to 164, or easeOutBack(overshoot 1.1) 0.45 s then settle | spring |
| 0.033 | 106 | **Node N1** launches at angle −83° (≈ straight up). Each node k = 0…5 launches at `t_k = 0.033 + 0.060·k` at angle `−83° + 60·k` (clockwise order: −83, −23, 37, 97, 157, 217). Flight: r = 0 → ring radius in **0.23 s**, easeOut (N1: r 36, 64, 93, 118, 140, 154, 162, 165 at f106…f113). Comet tail behind each node: length ≈ 0.6·r, width 2 px, gradient node colour → clear, alpha 0.7; tail gone 0.1 s after arrival | easeOutQuad |
| 0.0–2.83 | all | **Node phase** `φ(t) = −85° + 22.5·t` (deg). Node k sits at angle φ + 60k on the ring/petal tip. Measured: −14.7°(+60k) at f120, +0.5° at f140, +19° at f165 | linear |
| 0.0–2.83 | all | **Ring highlight** hot-segment centre `ψ(t) = −165° + 270·t` deg (= 15° at f125, 150° at f140). Angular gradient relative to ψ: at ψ−30° `#ffc9b4`, ψ `#ff9a74`, ψ+45° `#ffd690`, ψ+75° `#fff89e`, ψ+105° `#ffffee`, elsewhere `#f4e6d2`; stroke alpha 1.0 in the hot half, 0.65 at ψ+180°±30° | linear rotation |
| 0.433 | 118 | Caption **C** type-in: "Let" f118, "it" f122, "grow" f124→f128 sharp (word stagger 0.10 s, 0.20 s blur-in each — see 00-common). Fully in at t = 0.77 s | easeOut |
| 0.30 | 114 | Dot P fully faded | linear |
| 1.50 | 150 | **Morph O → L begins.** Progress `p = easeInOut((t − 1.50)/0.87)`, done at f176 (t = 2.37). Union-of-circles params: `d = 115·p`, `ρ = 164 − 82·p` (p = 0 → circle r 164; p = 1 → tips 197, valleys 158). Petal phase = node phase φ(t) (tips carry the nodes). Measured tip/valley radii: f165 199/161, f170 208/176 (slight breathing: multiply all radii by `1 + 0.05·sin(π·p)`), f176 197/157 | easeInOut |
| 2.133 | 169 | Caption **C** blur-out (left to right): "Let" gone f170, "it" f172, "grow" f174 | easeIn |
| 2.367 | 176 | **Shrink + collapse to asterisk**: whole flower scales about (360, 640): glow bbox 412 → 368 (f178) → 238 (f180) → 136 (f182) → 78 (f184) → 64 (f186) px, i.e. scale `s = 1 → 0.155` over 0.33 s, easeInCubic. During f176–f182 the petals narrow (`ρ → 0.45·ρ`, d unchanged in pre-scale units) so the outline reads as a thin 6-arm "asterisk outline" (bright `#fffff1`, 1.5 px). f182–f186 the outline fills to a solid star and the stroke glow rises | easeInCubic |
| 2.367–2.50 | 176–180 | Nodes N fade out (alpha 1 → 0, size → 0) | easeIn |
| 2.70–2.833 | 186–190 | **Asterisk A** holds at (360, 640): glow bbox (luma>150) 57×56 px, tip radius 29, colour as above. **End state for scene 3.** | — |

## Motion details
- Ring overshoot is real (180 px max vs 164 rest); do not clamp.
- Node launch is sequential clockwise (one every ≈ 0.06 s); the last node (217°) arrives at the ring at ≈ t 0.57 s (f122). Nodes arrive slightly ahead of the still-expanding ring and then ride it.
- Node brightness twinkles ±15 % at ≈ 3 Hz, deterministic per node (`0.85 + 0.15·sin(2π·3·t + k)`).
- The flower's lobes are circular arcs with cusped valleys (not a smooth cosine); union-of-circles reproduces that. Approx equivalent polar check at p = 1: r(θ) sampled every 10° from a tip: 197, 192, 177, 157 (valley), 176, 191, 197.
- Caption sits inside the ring and is never occluded by nodes (nodes are at r ≥ 160, caption half-width 90).

## Transition
- In: continuous from scene 1 (same dot).
- Out: asterisk A at (360, 640) is handed to scene 3 unchanged.

## Implementation notes (SwiftUI)
- `Canvas` + `TimelineView`. Ring/flower: build a `Path` from the union-of-circles outline (iterate 360 samples: for each angle θ take `r(θ) = max_k rayCircleIntersection(centre_k, ρ, θ)`; close path). Give the path `animatableData` if you prefer `Shape`, but Canvas with explicit `t` is simpler and deterministic.
- Stroke the outline with `AngularGradient(gradient:, center: .center, angle: .degrees(ψ))`; add a blurred copy (blur 4, alpha 0.6) in `.plusLighter`.
- Nodes: radial-gradient discs (00-common recipe). Tails: `Path` line from node toward centre, stroked with `LinearGradient` node→clear, `lineCap .round`.
- Asterisk: 6 rounded capsules (`RoundedRectangle` 7×29, corner 3.5) rotated 45°+60k about centre, filled with radial gradient `#fcfc49 → #e5a930`, plus halo. During f176–f186 crossfade outline-stroke → filled-capsules (opacity swap over 0.13 s) rather than attempting a true topological morph.
- Caption: fixed-frame two-run `Text`, per-word blur/opacity from `t`.

## Key frames to match (side-by-side)
f0107 (first node in flight with tail, ring r≈80), f0110 (3 nodes, ring r 135), f0118 (ring overshoot 180, caption "Let" appearing), f0125 (hot segment at ≈15°, "grow" blurred), f0140 (ring at rest 164, caption full), f0165 (mid-morph, tips 199/valleys 161), f0176 (full flower, caption gone), f0180 (asterisk outline at 0.58 scale), f0188 (solid asterisk).
