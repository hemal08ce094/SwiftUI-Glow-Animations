# Architecture

## Package: `GlowAnimations` (Sources/GlowAnimations)

- `Stage/GlowScene.swift`: the nine scenes in reel order (`spark` ... `outro`), each with an
  English `displayName` and a `duration` in seconds. `reelStart`, `reelDuration` and
  `locate(reelTime:)` map reel time to a scene and its local time.
  `GlowSceneView(scene:t:)` switches to the scene view; `GlowReelView(t:)` plays the reel.
- `Stage/GlowStage.swift`: draws content in a fixed 720 x 1280 design space, scales it
  uniformly to fit the frame it is given, centres it, letterboxes the rest in black and
  clips. `onStageRect` reports the visible stage rect in global points.
- `Stage/GlowPlayer.swift`: `GlowPlayer(.scene(x) | .reel, loop:, startOffset:)`, or
  `GlowPlayer(scene:)`. A `TimelineView(.animation)` turns the display clock into program
  time, measured from when the player appears plus `startOffset`; it wraps when looping
  and clamps otherwise. `onStart` hands back the wall-clock date of t = 0.
- `Scenes/<Name>Scene.swift`: one `public struct XScene: View { var t: Double }` per scene.
  Every scene must be a pure function of `t`: no `withAnimation`, no `@State` timers.
  Each one currently renders `SceneStub` (a blooming gold dot, the scene name, a t readout).
- `Core/`
  - `Easing.swift`: `Ease.clamp01`, `remap`, `progress`, `lerp`, `easeIn/Out/InOut`,
    `smoothstep`, `easeOutBack(overshoot:)`, `spring(damping:frequency:)`.
  - `Bloom.swift`: `.bloom(color:radius:intensity:)`, which is the content plus three blurred
    copies blended `.plusLighter` inside a `compositingGroup`.
  - `GlowTheme.swift`: palette constants (only black is final) and `Color(hex:)`.
  - `GlowFonts.swift`: registers the bundled fonts with `CTFontManagerRegisterFontsForURL`
    once per process. `sans(weight:size:)` and `serifItalic(size:)` fall back to system
    fonts if registration failed.
  - `CaptionText.swift`: "Start with a *spark*" captions (Outfit lead, gold Instrument
    Serif italic accent), sized in design units.
- `Resources/Fonts`: Outfit Light/Regular/Medium (static TTFs from Outfitio/Outfit-Fonts)
  and Instrument Serif Regular/Italic (google/fonts), each with its OFL licence file.
  PostScript names: `Outfit-Light`, `Outfit-Regular`, `Outfit-Medium`,
  `InstrumentSerif-Regular`, `InstrumentSerif-Italic`.

## Demo app (Demo/GlowAnimationsDemo.xcodeproj)

The app target uses a synchronised folder and the local package at `..`; it targets iOS 17
on iPhone and iPad. A scene list opens a full-screen black player, and tapping the player
shows close, restart and loop controls. Strings live in `Localizable.xcstrings` (en,
en-GB, en-AU, en-CA, es-MX). Launch arguments:

- `-glow-scene <case>` opens one scene; `-glow-reel` opens the full reel.
- `-glow-chromeless` hides overlays, the status bar and the home indicator, waits 0.8 s for
  the launch transition, then starts the player and writes `GLOW_T0`, `GLOW_STAGE_RECT`
  and `GLOW_FONT` lines to stderr.

## Harness (tools/)

- `record.sh <scene|reel> <seconds> [udid]` builds through devlock, records the simulator
  with `simctl io recordVideo`, crops the centred 9:16 stage and writes 30 fps 720 x 1280
  frames to `tools/out/<scene>/f%04d.png`. Alignment comes from a 24-cell binary timecode
  the chromeless player draws in the top letterbox bar (`TimecodeStrip`, outside the crop)
  on every display frame; the script decodes it from every presented video frame and takes
  each 30 fps slot from the frame whose clock is closest, writing `alignment.txt` with the
  per-frame error. `seconds` must not exceed the program duration (the player loops).
- `side-by-side.sh [dir]` turns a full-reel take into `samples/`: our reel as mp4, a
  side-by-side mp4 against `reference/reel.mp4`, a key-frame sheet and four stills.
- `compare.sh <scene> <refStart> <ourStart> <count>` writes `tools/out/<scene>/compare.png`,
  with one [reference | ours] row for every 5th frame.
- `compare-sheet.sh <scene> "<ref frames>" "<our frames>"` builds the same sheet from
  chosen key frames.

Reference frames (`reference/frames30`, 30 fps, 720 x 1280) are gitignored.
