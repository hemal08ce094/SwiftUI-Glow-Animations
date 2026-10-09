# Scene 5 — "Find your rhythm" (pendulum wave)

Frames **f0317 – f0471** (t = 10.53 s → 15.67 s, 155 frames, 5.17 s). Scene time `t` = seconds since f0317.
Black canvas, title fixed at y≈315.

Hand-off in: the "Details" card, seen edge-on, is a vertical glowing line at x=360, y 530→750.
Hand-off out: a single glowing dot at (360,640); at f0471 it flashes white and scene 6's cream circle wipes out from it.

## Elements

| Element | Geometry (design px) | Colour / style |
|---|---|---|
| Line → baseline | starts 3 px × 220 vertical at (360,640); ends 1.5 px × 576 horizontal from (72,785) to (648,785) | glowing `#e8c070` (bloom 10) while rotating; settles to dim `#a08050` 1 px with endpoint dots r 3 `#f6fae7` |
| Arcs | 8 concentric semicircles above the baseline, centre (360,785), radii r_i = 40 + 35.4·i (i=0 inner … 7 outer: 40, 75, 111, 146, 182, 217, 252, 288); stroke 1.5 | per-ring colour, inner→outer: `#f0e0a0 #f7d060 #f0b040 #ee9a3c #ea7a3a #e6603f #e24a50 #e03868`; glow copy blur 3 @ 50 % |
| Dots | 8, one per arc, core r 6 + bloom r 18 @ .6 | inner→outer `#fcfefe #fff7b3 #f7e96f #e2b63a #f7e064 #e09e3b #ee8f6a #ff7ca2` (sampled f0352) |
| Caption | "Find your " sans ≈34 px white + "rhythm" serif italic ≈36 px gold `#e9a24a`, centred x=360, baseline y≈885 | blur-reveal / blur-dissolve like other captions |

## Timeline

| t (s) | frame | what happens | easing |
|---|---|---|---|
| 0.00 | 317 | vertical line, length 220, centre (360,640) | — |
| 0.03–0.50 | 318–332 | line rotates 90°→0° (top end swings LEFT, i.e. counter-clockwise), length 220→576, centre y 640→785 (y moves mostly in the second half) | rotation easeInOut; length easeOut; y easeIn→Out |
| 0.50–0.57 | 332–334 | line dims to baseline colour, endpoint dots pop in | easeOut 0.1 s |
| 0.57–1.00 | 334–347 | dots spawn at (360,785), one every 1.7 frames (0.057 s), inner first; each slides left to its home x = 360 − r_i over 0.27 s | easeOutCubic |
| 0.77–1.23 | 340–354 | arcs fade in 0 → 35 % (inner first, 0.04 s stagger) | linear |
| 1.23–1.33 | 354–357 | arcs flash to 100 % (quick brighten over 3 frames) | easeOut |
| 1.33 | 357 | pendulum starts: all dots at left end (angle 180°) | — |
| 1.50–2.27 | 362–385 | caption blur-reveals left→right | easeOut |
| 1.33–4.50 | 357–452 | pendulum wave runs (see below) | sinusoidal |
| 4.50–4.70 | 452–458 | caption blur-dissolves left→right | easeIn |
| 4.63–4.83 | 456–462 | arcs' radii → 0, dots converge to (360,785), baseline shrinks to a point | easeIn (quad) |
| 4.83–4.97 | 462–466 | the single dot rises (360,785) → (360,640) | easeOut |
| 4.97–5.13 | 466–471 | dot holds, bloom breathes (r 14→22) | sin |
| 5.13 | 471 | dot flashes white `#fff8e8` → scene 6 | — |

## Motion detail (t → value)

```
// line → baseline (0.03 ≤ t ≤ 0.50), u = (t-0.03)/0.47
angleDeg(u)  = 90 * (1 - easeInOut(u))          // 90 = vertical, 0 = horizontal
length(u)    = 220 + 356 * easeOutCubic(u)
centreY(u)   = 640 + 145 * easeInOutQuad(max(0, (u-0.35)/0.65))
glow(u)      = 1 - u                              // bloom fades as it flattens

// dot entry, dot i (0 = inner)
spawn_i      = 0.57 + 0.057 * i
x_i(t)       = 360 - r_i * easeOutCubic(clamp((t - spawn_i) / 0.27)),  y = 785

// pendulum, T0 = 1.33, i = 0 inner … 7 outer
halfPeriod_i = 0.60 + 0.2386 * i        // inner 0.60 s, outer 2.27 s (measured: inner reaches right at f375, outer at f425)
p_i(t)       = 0.5 - 0.5 * cos(π (t - T0) / halfPeriod_i)   // 0 = left end, 1 = right end
theta_i      = π * (1 - p_i)                                 // radians, measured from +x
pos_i        = (360 + r_i cos(theta_i), 785 - r_i sin(theta_i))

// collapse (4.63 ≤ t ≤ 4.83), v = easeInQuad((t-4.63)/0.20)
r_i(t)       = r_i * (1 - v);  baselineHalfWidth = 288 * (1 - v);  dots use r_i(t)
```

Note the half-period spacing gives the classic "lines → chaos → lines" pendulum-wave look within the 3.2 s it runs; the dots are never re-synchronised in the reel (it collapses mid-pattern around f0452).

## Implementation notes
- Draw everything in one `Canvas` inside `TimelineView(.animation)`: arcs with `Path.addArc(center:radius:startAngle:180°, endAngle:0°, clockwise:true)`, dots as filled circles plus a second pass with `context.addFilter(.blur(radius: 10))` and `.blendMode(.plusLighter)` for bloom.
- The rotating line is the same `Path` as the baseline (a 2-point line) with transform `rotation(angle) × translation(centre)`; its length and centre are functions of t, so there is no separate "line" object.
- Arc glow: stroke twice — 1.5 px crisp, then 4 px at 35 % blurred 3.
- Caption uses the shared caption style from 00-common.md (sans + serif-italic accent).
- Keep dot colours fixed per index; they do not change along the arc.

## Key frames to match
f0317 (vertical line), f0325 (≈45° rotating, descending), f0332 (baseline), f0341 (4 dots sliding), f0352 (8 dots lined up, arcs faint), f0357 (arcs bright, dots leaving), f0375 (inner dot at right end), f0400 (mid-wave + caption), f0425 (outer dot at right), f0459 (collapse), f0468 (single dot at centre).
