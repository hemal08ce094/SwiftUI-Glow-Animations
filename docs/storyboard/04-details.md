# Scene 4 — "Details" card

Frames **f0244 – f0316** (t = 8.10 s → 10.50 s, 73 frames, 2.43 s). Scene time `t` below is seconds since f0244.
Canvas 720×1280, black `#000000`. Title "Opus 5.5 is actually cooking" stays at y≈315 (see 00-common.md).

Hand-off in: scene 3's asterisk + "Give it shape" blur out f0240–f0245 while the pill is already appearing (0.1 s overlap).
Hand-off out: at f0317 the card is a vertical glowing line at x=360, y 530→750 — scene 5 takes it from there.

## Elements

| Element | Geometry (design px) | Colour / style |
|---|---|---|
| Pill (initial) | capsule, centre (360,640), grows to 360×36 | horizontal gradient `#fd7884` → `#f07e44` → `#db8428`; outer bloom r≈40, colour of nearest edge, opacity ≈0.5 |
| Card (final) | 590×230, corner radius 28, centre (360,640) | diagonal gradient TL `#fc7486` → TR `#cf7724`, BL `#fe6062` → BR `#bf702e` (pink left → amber right, ~6 % darker at bottom). 1 px inner rim slightly lighter. Bloom: 2 layers — soft (blur 36, opacity .55, card edge colour) + tight red rim (blur 6, `#ff3a3a`, opacity .45, becomes dominant when tilted) |
| Reflection | flipped copy of card, 8 px below, mask opacity .20 → 0 over 70 px, blur 6 | sample at y=800 `#270f07`, y=830 `#1c0a05` |
| Asterisk icon | 6-spoke rounded asterisk, 52 px, centre (130,645), stroke 7 | white `#ffffff` |
| Title | "Details", sans regular ≈44 px (cap height ≈32), left x=190, baseline y≈650 | white |
| Subtitle | "make it " sans ≈24 px + "real" serif italic ≈26 px, left x=192, baseline y≈680 | white @ 90 % |
| Sheen | band 120 px wide, rotated 25° from vertical (top-right → bottom-left "/"), soft edges blur 30 | `#ffd080` @ 45 %, clipped to card |

## Timeline

| t (s) | frame | what happens | easing |
|---|---|---|---|
| 0.00 | 244 | pill appears at centre, w≈40, h 36 | — |
| 0.00–0.17 | 244–249 | pill width 40 → 360 (symmetric about centre); bloom fades in | easeOut (cubic) |
| 0.17–0.27 | 249–252 | hold 360×36 | — |
| 0.27–0.50 | 252–259 | pill → card: w 360→590, h 36→230, radius 18→28 | easeOut with ~4 % overshoot at f258 (h≈238) |
| 0.47 | 258 | card acquires 3-D yaw ≈ -10° (left edge nearer, 230 px tall; right edge 207 px) | easeInOut over 0.3 s |
| 0.53–0.60 | 260–262 | reflection fades in | linear |
| 0.60–0.87 | 262–270 | asterisk fades in (blur 12→0); "Details" blur-reveals left→right | easeOut |
| 0.97–1.30 | 273–283 | "make it real" blur-reveals left→right | easeOut |
| 1.33–1.73 | 284–296 | sheen sweeps across card: band centre x from card-left − 200 to card-right + 200 | linear |
| 1.73–2.20 | 296–310 | hold; yaw drifts −10° → −6° → −10° (tiny idle) | sinusoidal |
| 2.20–2.43 | 310–317 | yaw −10° → −90° (edge-on); text and reflection fade with the face; red rim glow brightens to opacity .9 | easeIn (quad) |
| 2.43 | 317 | face is a line: x=360, y 530→750, 3 px, `#e8c070`, bloom 10 | — |

## Motion detail (t → value)

```
pillWidth(t)  = 40 + 320 * easeOutCubic(clamp(t/0.17))                     t < 0.27
cardW(t)      = 360 + 230 * backOut(clamp((t-0.27)/0.23), s=1.2)           t ≥ 0.27
cardH(t)      = 36  + 194 * backOut(clamp((t-0.27)/0.23), s=1.2)
cornerR(t)    = min(cardH/2, 18 + 10 * (cardH-36)/194)
yawDeg(t)     = -10 * easeInOut(clamp((t-0.47)/0.30))                       0.47 ≤ t < 2.20
              + 4 * sin(2π (t-1.73)/1.4) * (t>1.73 ? 1 : 0)   (idle wobble, amplitude 4°)
yawDeg(t)     = lerp(-10, -90, easeInQuad((t-2.20)/0.23))                   2.20 ≤ t ≤ 2.43
sheenX(t)     = lerp(-200, 790, (t-1.33)/0.40)   (relative to card left; card-local coords)
textReveal: character i of n visible when t_reveal > 0.27 * i/n, with blur = 10*(1-u), opacity u, u = easeOut(local 0.15 s)
```

Perspective: `rotation3DEffect(.degrees(yaw), axis: (0,1,0), anchor: .center, perspective: 0.6)`.
Edge-on slab: when |yaw| > 70° draw an 8 px thick side face in `#c0453a` so the card reads as a slab, not a paper.

## Implementation notes
- Build the card as one `RoundedRectangle` with `LinearGradient(start .topLeading → .bottomTrailing)` using the 4 corner colours; overlay text; then `.rotation3DEffect` with perspective. Keep bloom as two copies of the same shape under it: `.blur(36).opacity(0.55)` and `.blur(6).opacity(rim)`, blend `.plusLighter`.
- Reflection: same view `.scaleEffect(y: -1)` offset below, masked with a `LinearGradient(white.opacity(0.2) → clear)` and `.blur(6)`.
- Sheen: a `Rectangle` 120 wide, `.rotationEffect(25°)`, `.blur(30)`, `.blendMode(.plusLighter)`, `.offset(x: sheenX)`, clipped by the card shape (`.clipShape` on a ZStack of card+sheen *before* the 3-D rotation).
- Text reveal: per-character `opacity`/`blur` driven by t (the reel blurs each glyph in, not a typewriter).
- Pill→card growth is one shape with animatable width/height/radius: compute all three from t, no implicit animations.

## Key frames to match
f0247 (thin pill), f0255 (mid growth), f0262 (card + first glyphs), f0280 (both lines readable), f0290 (sheen at centre), f0300 (settled, tilt visible), f0312 (yaw ≈ −35°), f0315 (yaw ≈ −80°, red rim), f0317 (line).
