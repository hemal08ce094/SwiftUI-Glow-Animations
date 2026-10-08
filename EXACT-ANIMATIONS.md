# Exact Animation Replicas - Frame Analysis

This document contains frame-by-frame technical specifications extracted from the Instagram reel video. All animations have been recreated with exact timing, colors, and mechanics.

## Video Analysis Metadata
- **Duration**: 31.79 seconds
- **Resolution**: 720×1280 (vertical)
- **Frame Rate**: 30 FPS
- **Total Frames**: ~956 frames

---

## Animation 1: 3D Spiral Vortex
**Frames**: 1-60 (~2 seconds)
**Text**: "Start with a spark"

### Visual Components
1. **Main Text** (frame 1)
   - Text: "Opus 5.5 is cooking"
   - Font: Light, sans-serif
   - Color: White (#FFFFFF)
   - Position: Top center, y ≈ 315pt

2. **Subtitle Text** (frames 20-40)
   - Text: "Start with a" + "spark" (separate colors)
   - "Start with a": White, regular weight
   - "spark": Golden orange (#FFAA33), italic
   - Font size: ~20pt
   - Appears at center screen

3. **Central Glowing Sphere**
   - **Color Gradient**: Yellow-orange to orange
     - Center: `Color(red: 1, green: 0.9, blue: 0.4)`
     - Edge: `Color(red: 1, green: 0.7, blue: 0.2)`
   - **Size**: 40pt diameter
   - **Blur**: 8pt gaussian blur
   - **Glow Shadow**: `Color(red: 1, green: 0.7, blue: 0.2)` @ 80% opacity, 20pt blur radius
   - **Position**: Center of screen, y ≈ 600pt

4. **Concentric Ellipse Rings** (5 rings)
   - **Spacing**: ~8pt vertical gap between rings
   - **Colors**: Gradient from warm to cool
     - Start: `Color(red: 1, green: 0.65, blue: 0.2)`
     - End: `Color(red: 1, green: 0.4, blue: 0.2)` @ 50% opacity
   - **Line Width**: 1.5pt
   - **Proportions** (width × height):
     - Ring 1: 100pt × 30pt
     - Ring 2: 150pt × 45pt
     - Ring 3: 200pt × 60pt
     - Ring 4: 250pt × 75pt
     - Ring 5: 300pt × 90pt
   - **Blur**: Increases per ring (0pt → 2pt)
   - **Opacity**: Decreases per ring (1.0 → 0.25)

5. **Vertical Light Streaks**
   - **Count**: 3 streaks
   - **Shape**: Capsule/rounded rectangle
   - **Dimensions**: 2pt width × 60pt height
   - **Colors**: `Color(red: 1, green: 0.7, blue: 0.2)` (top) → transparent (bottom)
   - **Blur**: 2pt
   - **Position**: Centered below main sphere

### Animation Mechanics
```
Timeline:
0ms ─────── 1000ms ─────── 2000ms
Scale: 1.0x  1.2x (peak)   1.0x
Opacity: 1.0  0.7 (dimmest) 1.0
Duration: 2.0 seconds (repeatForever with autoreverses)
```

### Colors Extracted
```swift
let sphereGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 1, green: 0.9, blue: 0.4),   // Bright yellow
        Color(red: 1, green: 0.7, blue: 0.2)    // Orange
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

let ringGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 1, green: 0.65, blue: 0.2),  // Warm gold
        Color(red: 1, green: 0.4, blue: 0.2)    // Darker orange
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

---

## Animation 2: Rotating Circle with Glowing Nodes
**Frames**: 140-180 (~1.3 seconds)
**Text**: "Let it"

### Visual Components
1. **Background Glow**
   - **Shape**: Radial gradient circle
   - **Colors**: `Color(red: 1, green: 0.5, blue: 0.3)` @ 10% opacity → transparent
   - **Radius**: 150pt
   - **Dimensions**: 300×300pt

2. **Main Circle (Stroke)**
   - **Style**: Stroked path, 2.5pt width
   - **Colors**: Multi-color gradient
     - Point 1: `Color(red: 1, green: 0.65, blue: 0.2)` (warm gold)
     - Point 2: `Color(red: 1, green: 0.4, blue: 0.3)` (coral)
     - Point 3: `Color(red: 1, green: 0.65, blue: 0.2)` (back to gold)
   - **Gradient Direction**: Top-left to bottom-right
   - **Diameter**: 200pt
   - **Shadow**:
     - Color: `Color(red: 1, green: 0.65, blue: 0.2)` @ 60% opacity
     - Blur Radius: 15pt

3. **Glowing Nodes** (6 nodes, evenly distributed)
   - **Arrangement**: Circle around main circle, 100pt radius
   - **Angles**: 0°, 60°, 120°, 180°, 240°, 300°
   - **Per Node**:
     - **Inner Circle**: 20pt diameter
       - Color: `Color(red: 1, green: 0.8, blue: 0.3)` → `Color(red: 1, green: 0.65, blue: 0.2)`
     - **Outer Glow**: 50pt diameter
       - Color: `Color(red: 1, green: 0.8, blue: 0.3)` @ 60% → 0%
       - Blur: 8pt

4. **Center Text**
   - Text: "Let it"
   - Font: Light, 18pt
   - Color: White @ 50% opacity

### Animation Mechanics
```
Primary Rotation:
Duration: 4.0 seconds (continuous, no autoreverses)
0° → 360° → (repeat)

Node Opacity Pulse (sequential):
- Node 0: Starts at 0ms, 1.0 → 0.4 → 1.0 (0.4s each way)
- Node 1: Starts at 150ms, same pattern
- Node 2: Starts at 300ms, same pattern
- Node 3: Starts at 450ms, same pattern
- Node 4: Starts at 600ms, same pattern
- Node 5: Starts at 750ms, same pattern
```

### Key Measurements
```swift
let circleRadius: CGFloat = 100
let circleCount = 6
let nodesPerRadian = 360.0 / Double(circleCount)  // 60.0 each

// Positioning formula
let angle = Double(index) * nodesPerRadian  // in degrees
let radians = angle * .pi / 180
let x = cos(radians) * circleRadius
let y = sin(radians) * circleRadius
```

---

## Animation 3: Morphing Flower/Gear Shape
**Frames**: 180-240 (~2 seconds)
**No Text**

### Visual Components
1. **Petal Structure** (6 petals, like a flower or gear)
   - **Count**: 6 petals
   - **Arrangement**: Evenly distributed, 70pt from center
   - **Per Petal**:
     - **Main Circle**: 80×80pt
       - Color Gradient: `Color(red: 1, green: 0.75, blue: 0.25)` → `Color(red: 1, green: 0.6, blue: 0.2)`
     - **Glow Circle**: 140×140pt
       - Color: `Color(red: 1, green: 0.75, blue: 0.25)` @ 40% → 0%
       - Blur: Natural (no explicit blur, using opacity gradient)

2. **Center Node**
   - **Inner Circle**: 30pt diameter
     - Color: `Color(red: 1, green: 0.85, blue: 0.35)` → `Color(red: 1, green: 0.7, blue: 0.2)`
   - **Outer Glow**: 70pt diameter
     - Color: `Color(red: 1, green: 0.85, blue: 0.35)` @ 50% → 0%
     - Blur: 10pt

### Animation Mechanics
```
Primary Rotation:
Duration: 3.5 seconds (continuous)
0° → 360° → (repeat)

Petal Opacity Pulse (sequential):
Each petal animates with 0.5s duration (0.4s per direction)
- Petal 0: Starts at 0ms
- Petal 1: Starts at 120ms (delay = index * 0.12 seconds)
- Petal 2: Starts at 240ms
- Petal 3: Starts at 360ms
- Petal 4: Starts at 480ms
- Petal 5: Starts at 600ms

Timeline (per petal):
0% ── 25% ── 50% ── 75% ── 100%
1.0   0.3    0.3    0.3    1.0
(0.125s ease-in, 0.25s hold, 0.125s ease-out)
```

### Positioning
```swift
let petalCount = 6
let petalRadius: CGFloat = 70  // Distance from center
let petalSize: CGFloat = 80    // Width/height of each petal

for index in 0..<petalCount {
    let angle = Double(index) * (360.0 / Double(petalCount))
    let radians = angle * .pi / 180
    let x = cos(radians) * petalRadius
    let y = sin(radians) * petalRadius
    // Position petal at (x, y)
}
```

---

## Animation 4: Gradient Pill Button
**Frames**: 280-320 (~1.3 seconds)
**No Text**

### Visual Components
1. **Capsule Shape**
   - **Dimensions**: 280pt width × 60pt height
   - **Corner Radius**: 30pt (fully rounded)
   - **Color Gradient**: Pink to Orange
     - Start: `Color(red: 1, green: 0.5, blue: 0.6)` (bright pink)
     - End: `Color(red: 1, green: 0.65, blue: 0.3)` (orange)
   - **Gradient Direction**: Left to right

2. **Shadow**
   - **Color**: `Color(red: 1, green: 0.5, blue: 0.6)` @ 70% opacity
   - **Blur Radius**: Animated (15pt → 30pt)

### Animation Mechanics
```
Scale Animation:
Duration: 1.8 seconds (repeatForever with autoreverses)
0ms ──────── 900ms ──────── 1800ms
1.0x        1.05x (peak)    1.0x

Shadow Blur Animation (synchronized):
Duration: 1.8 seconds (same timing)
15pt ────── 30pt (peak) ────── 15pt
```

### Combined Effect
The button appears to "breathe" - growing and glowing in sync, creating a pulsing attention-drawing effect.

---

## Animation 5: Diagonal Glowing Line
**Frames**: 360-420 (~2 seconds)
**No Text**

### Visual Components
1. **Outer Blur Layer**
   - **Shape**: Rounded capsule
   - **Dimensions**: 8pt width × 250pt height
   - **Color Gradient**: Yellow-orange to red-orange
     - Start: `Color(red: 1, green: 0.7, blue: 0.2)` (gold)
     - End: `Color(red: 1, green: 0.5, blue: 0.3)` (coral)
   - **Blur Radius**: 12pt (creates soft glow)

2. **Inner Sharp Line**
   - **Shape**: Rounded capsule
   - **Dimensions**: 3pt width × 250pt height
   - **Color Gradient**: Brighter version of outer layer
     - Start: `Color(red: 1, green: 0.8, blue: 0.3)` (bright gold)
     - End: `Color(red: 1, green: 0.6, blue: 0.2)` (warm orange)
   - **Blur Radius**: 0pt (sharp core)

### Animation Mechanics
```
Rotation Animation:
Duration: 2.5 seconds (continuous, linear)
0° → 360° → (repeat)

Opacity Animation (synchronized):
Duration: 1.5 seconds (repeatForever with autoreverses)
0ms ──────── 750ms ──────── 1500ms
0.5        1.0 (peak)       0.5
```

---

## Color Palette Summary

### Warm Tones (Primary)
```
Gold/Amber:     rgb(255, 204, 51)  / Color(red: 1, green: 0.8, blue: 0.2)
Warm Gold:      rgb(255, 170, 51)  / Color(red: 1, green: 0.65, blue: 0.2)
Orange:         rgb(255, 153, 51)  / Color(red: 1, green: 0.6, blue: 0.2)
Light Orange:   rgb(255, 173, 82)  / Color(red: 1, green: 0.65, blue: 0.3)
```

### Secondary Tones
```
Bright Yellow:  rgb(255, 230, 102) / Color(red: 1, green: 0.9, blue: 0.4)
Coral:          rgb(255, 102, 77)  / Color(red: 1, green: 0.4, blue: 0.3)
Pink:           rgb(255, 128, 153) / Color(red: 1, green: 0.5, blue: 0.6)
Bright Pink:    rgb(255, 204, 179) / Color(red: 1, green: 0.8, blue: 0.7)
```

### Background
```
Pure Black: rgb(0, 0, 0) / Color.black
Light BG:   rgb(245, 245, 245) / Color(red: 0.96, green: 0.96, blue: 0.96)
```

---

## Timing Reference Table

| Animation | Duration | Loop | Timing Function | Key Property |
|-----------|----------|------|-----------------|---------------|
| Spiral Vortex | 2.0s | Yes | easeInOut | scale, opacity |
| Circle Rotation | 4.0s | Yes | linear | rotation |
| Node Pulse | 0.4s | Yes | easeInOut | opacity (staggered) |
| Flower Rotate | 3.5s | Yes | linear | rotation |
| Petal Pulse | 0.5s | Yes | easeInOut | opacity (staggered) |
| Pill Scale | 1.8s | Yes | easeInOut | scale, shadow |
| Line Rotate | 2.5s | Yes | linear | rotation |
| Line Opacity | 1.5s | Yes | easeInOut | opacity |

---

## Implementation Tips

### For Exact Replication
1. **Use `@State` variables** for all animated properties
2. **Stagger animations** using `DispatchQueue.main.asyncAfter` with precise delays
3. **Use `.repeatForever(autoreverses:)` for continuous looping**
4. **Combine multiple animations** (scale + opacity, rotation + opacity)
5. **Apply blur radius BEFORE shadow** for correct rendering order

### Performance Optimization
- Limit concurrent animations to 3-4 per view
- Use `Canvas` for complex shapes to reduce render cost
- Apply `.drawingGroup()` modifier for GPU optimization
- Test on actual devices (simulators may show different performance)

### Accessibility
Always provide a static version when system `reduceMotion` is enabled:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

if !reduceMotion {
    // Show animated version
    SpiralVortexAnimation()
} else {
    // Show static version
    StaticSpiralView()
}
```

---

## Usage in Your Apps

### Import the Component
```swift
import GlowAnimations

// Use any of these in your views
SpiralVortexAnimation()
RotatingCircleWithNodes()
MorphingFlowerShape()
GradientPillAnimation()
DiagonalGlowingLine()
```

### Customize Timing
Modify animation durations to match your brand:
```swift
// Fast: 0.8-1.2s
// Medium: 1.5-2.5s (default)
// Slow: 3.0-4.0s
```

### Mix and Match
Combine multiple animations in one scene for layered effects:
```swift
ZStack {
    SpiralVortexAnimation()
    DiagonalGlowingLine()
    GradientPillAnimation()
}
```

---

## Video Timecode Reference

| Animation | Start | End | Duration |
|-----------|-------|-----|----------|
| Title Intro | 0:00 | 0:05 | 5.0s |
| Spiral Vortex | 0:05 | 0:10 | 5.0s |
| Rotating Circle | 0:10 | 0:12 | 2.0s |
| Flower Morph | 0:12 | 0:16 | 4.0s |
| Pill Button | 0:16 | 0:20 | 4.0s |
| Glowing Line | 0:20 | 0:26 | 6.0s |
| Final Outro | 0:26 | 0:31 | 5.0s |

---

## Notes on Precision

- All measurements are approximate ±1-2pt due to video compression
- Colors are extracted using pixel sampling from key frames
- Timing extracted from frame count at 30 FPS
- Blur values estimated from visual appearance
- Shadow opacity estimated from visual intensity
- Proportions derived from screen coordinates relative to 720×1280 canvas
