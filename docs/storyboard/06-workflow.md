# Scene 6 — Workflow ("Dream it → Build it → Ship it")

Frames **f0471 – f0624** (t = 15.67 s → 20.77 s, 154 frames, 5.13 s). Scene time `t` = seconds since f0471.
This is the only light scene. It is entered and left by a circular wipe centred at (360,640).

Hand-off in: scene 5's lone dot at (360,640) flashes white at f0471.
Hand-off out: at f0624 the screen is black again with a glowing gold dot at (360,640) — scene 7 ("Everything connects") starts from it.

## Background (cream)

- Base vertical gradient: `#f5eeeb` (y=0) → `#f4e5d7` (y=640) → `#f5ece3` (y=1280).
- Warm blob: radial `#f6dcc9` → transparent, centre (360,1000), radius 260, blur 80, opacity 1 (sampled `#f6dcc9` at (360,1000)).
- Second faint blob: `#f7e4d2`, centre (360,330), radius 200, opacity .5.
- Ghost layer: the previous black scene (title text, arcs) survives as a blurred (blur 18), 6 %-opacity lighter smear — visible as a pale ring at the top and the title at y≈315 reading `#f4ede6` on `#f4e5d7`. Optional; implement as the title view at opacity .08 with blur 2.
- Title stays rendered (white) but is effectively invisible on cream; do **not** hide it, it must fade naturally when the black wipe returns.

## Elements

| Element | Geometry (design px, unscaled) | Colour / style |
|---|---|---|
| Seed dot | r 5 at (360,640) | `#180d04` |
| Pill "Dream it" | capsule 263×90 (radius 45) | fill `#1a1310`; label sans ≈36 px white `#f4f0ec`, left x = pillLeft+70; icon crescent 26 px at pillLeft+28, vertical gradient `#ffb347` → `#f0552a`; soft shadow (0,6) blur 14 `#c89070` @ .25 |
| Pill "Build it" | capsule 246×90 | same; icon `</>` 26 px, stroke 3, gradient `#f0552a` → `#ffb347` |
| Pill "Ship it" | capsule 240×90 | same; icon ↗ arrow 24 px `#da6641` |
| Curve 1 | cubic from Dream bottom-centre P0 to Build top-centre P3; C1 = P0 + (0, 0.45·Δy), C2 = P3 − (0, 0.45·Δy) (vertical tangents, S-curve) | 2 px; black `#1f0e00` while drawing; after a pulse has passed it is recoloured along its length pink `#e0405a` (start) → orange `#f0903a` (end) with glow blur 4 @ .4 |
| Curve 2 | same rule from Build bottom-centre to Ship top-centre | same |
| Pen dot | r 4 at the drawing tip | `#1f0e00` |
| Pulse | hot core r 5 `#e8fcca` + ring r 9 stroke 1.5 `#ff7a30` + bloom r 22 `#ff7a30` @ .55 (`.plusLighter`) | travels along a curve |
| Pop halo | capsule outline at 1.08× pill size, 1.5 px `#ffffff` @ .7 → 0 | shown for 0.25 s at each pill's "ignite" |
| Ignite sweep | orange `#f57626` → `#de4b26` fills the pill left→right (gradient edge ~40 px wide), then decays to the dark fill via `#8a2a10` | 0.23 s sweep, 0.8 s decay |

Layout (unscaled, relative to Dream centre D): Build centre = D + (224, 328); Ship centre = D + (10, 657).

### Group framing (camera)
The whole diagram is kept centred and fitted: `scale(t)` and the Dream-centre position are chosen so the bounding box of every placed pill *and* the live pen tip stays centred at (360,640) with a lag (critically damped, time constant 0.35 s), and `scale = min(1, 540 / unscaledBBoxHeight)`.
Measured keyframes to reproduce (Dream centre, scale): f0497 (362,642) 1.00 · f0520 (330,589) 0.98 · f0536 (250,477) 0.95 · f0547 (250,462) 0.95 · f0565 (265,430) 0.85 · f0600 (276,402) 0.72 · hold to f0612. Interpolate with easeInOut; implementers may use these keyframes directly instead of the camera rule.

## Timeline

| t (s) | frame | what happens | easing |
|---|---|---|---|
| 0.00 | 471 | dot at (360,640) turns white `#fff8e8` | — |
| 0.03–0.17 | 472–476 | cream circle wipe: r = 15, 45, 130, 270, 500, ≥800 (×≈2.1 per frame) | exponential |
| 0.17–0.40 | 476–483 | dark seed dot sits at (360,640), r 5 | — |
| 0.40–0.70 | 483–492 | seed → Dream pill: w 10→263, h 10→90, 1 px overshoot | backOut (s=1.3) |
| 0.57 | 488 | crescent icon fades in (0.15 s) | easeOut |
| 0.60–0.87 | 489–497 | "Dream it" blur-reveals left→right | easeOut |
| 0.93–1.17 | 499–506 | Dream ignites: pop (scale 1→1.06→1) + halo + orange sweep L→R | sweep linear, pop easeOut |
| 1.17–1.80 | 506–525 | Dream decays orange → `#8a2a10` (f512) → `#5a1a0a` (f520) → dark | easeOut |
| 1.27–1.73 | 509–523 | curve 1 draws from Dream bottom to Build position with pen dot; camera starts panning | easeInOut on trim |
| 1.73–1.93 | 523–529 | pen dot → Build pill (same backOut growth, 0.2 s) | backOut |
| 1.87–2.17 | 527–536 | `</>` icon + "Build it" blur-reveal | easeOut |
| 1.97–2.47 | 530–545 | pulse leaves Dream, travels curve 1 (0.5 s), recolouring the curve behind it | easeInOut |
| 2.47–2.70 | 545–552 | Build ignites (pop + halo + sweep) | as above |
| 2.60–3.13 | 549–565 | curve 2 draws Build → Ship; Build decays to dark meanwhile | easeInOut |
| 3.13–3.33 | 565–571 | pen dot → Ship pill; ↗ icon + "Ship it" reveal f0571–f0580 | backOut / easeOut |
| 3.40–3.87 | 573–587 | pulse travels curve 2 → Ship | easeInOut |
| 3.87–4.10 | 587–594 | Ship ignites; stays orange (`#ad3b1f` → `#e05225` gradient) until the end | sweep |
| 3.90–4.70 | 588–612 | continuous pulses: a new pulse leaves Dream every 0.43 s and runs the full path (curve 1 → through Build → curve 2 → Ship) at 1 curve / 0.5 s; two pulses per curve visible at f0600 | linear along path |
| 4.53–4.67 | 607–611 | all labels + icons blur-dissolve | easeIn |
| 4.70–4.83 | 612–616 | pills collapse width → 10 (Dream first, Build last), curves fade | easeIn |
| 4.87 | 617 | three dots merge into one at (360,640) | easeIn |
| 4.90 | 618 | dot becomes gold-white `#fafded` with cream halo r 20 | — |
| 4.93–5.10 | 619–624 | black circle wipe from (360,640): r = 15, 45, 100, 190, 400, ≥800 | exponential |
| 5.13 | 624 | black; glowing dot remains → scene 7 | — |

## Motion detail (t → value)

```
wipeR(k)       = 15 * 2.1^k      (k = frames since wipe start; cover when r ≥ 820)
pillSize(u)    = (w, h) = (10 + (W-10)·backOut(u), 10 + 80·backOut(u)),  u = local/0.30
ignite(u)      : sweepEdge = pillLeft - 40 + (W + 80)·u   (u over 0.23 s); fill = orange left of edge, dark right
decay(v)       : color = mix(#de4b26, #1a1310, easeOut(v)) via #8a2a10 at v≈0.3   (v over 0.8 s)
pop(u)         : scale = 1 + 0.06·sin(π·clamp(u))  (u over 0.25 s); halo opacity = 0.7·(1-u)
curveDraw(u)   : trim(from: 0, to: easeInOut(u)), pen at point(easeInOut(u))   (u over 0.47 s)
pulse(s)       : point along curve at arc-length fraction easeInOut(s), s over 0.5 s per curve;
                 curve colour behind the pulse = gradient(pink→orange) masked by trim(0…s)
labelReveal    : as in 04-details (per-glyph blur 10→0 / opacity 0→1 over 0.15 s, start stagger 0.27 s·i/n)
```

Pulse path through a pill: the pulse disappears at the pill's top edge and re-emerges at its bottom edge 0.1 s later (the pill is the conduit).

## Implementation notes
- Design the diagram in unscaled coordinates with Dream at the origin, then apply `scaleEffect(scale(t))` + `offset` for the camera. Pills are `Capsule` views; curves are `Path` built from the pill anchor points and drawn with `.trim(from:to:)` for the pen reveal and a second trimmed, gradient-stroked copy for the post-pulse colour.
- Pulse: position via `path.trimmedPath(from: s-0.001, to: s).currentPoint` (or sample the cubic directly). Bloom = circle `.blur(10)` `.blendMode(.plusLighter)`.
- Ignite sweep: the pill's fill is a `LinearGradient` with 3 stops [orange, orange, dark] whose locations move with `sweepEdge`; decay then animates the orange stop colour toward dark.
- Wipes: a `Circle` of the target colour (cream in, black out) scaled from the dot; everything of the previous scene stays rendered beneath until covered.
- Light-scene shadow under pills: `.shadow(color: #c89070 @ .25, radius: 14, y: 6)`.
- Keep the title view alive at normal opacity; it simply becomes invisible on cream.

## Key frames to match
f0474 (wipe r≈270), f0486 (pill growing), f0497 (label revealed), f0501 (ignite sweep mid), f0520 (curve drawn, Dream dark red), f0536 (pulse mid-curve, Build label revealing), f0547 (Build ignite sweep), f0565 (Ship pill forming), f0600 (3 pills, 2 pulses per curve, Ship orange), f0614 (pills collapsing), f0621 (black wipe r≈100).
