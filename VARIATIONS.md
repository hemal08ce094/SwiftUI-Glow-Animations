# Animation Variations Gallery

This document showcases the different variations and customizations available in the GlowAnimations library.

## 1. Glow Buttons

### Variation 1: Pink-to-Orange (Default)
```swift
GlowButton(
    title: "Details",
    icon: "✨",
    gradient: LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1, green: 0.4, blue: 0.6),
            Color(red: 1, green: 0.6, blue: 0.2)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    ),
    action: {}
)
```
- **Colors**: Pink (#FF6699) → Orange (#FF9933)
- **Glow**: Warm orange shadow (60% opacity)
- **Animation**: 1.5s pulse effect

### Variation 2: Red-to-Orange (Sunset)
```swift
GlowButton(
    title: "Build it",
    icon: "</> ",
    gradient: LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1, green: 0.5, blue: 0.3),
            Color(red: 1, green: 0.7, blue: 0.4)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    ),
    action: {}
)
```
- **Colors**: Red (#FF8080) → Orange (#FFBB66)
- **Glow**: Warm sunset tone
- **Use Case**: Call-to-action buttons

### Variation 3: Cyan-to-Teal (Cool)
```swift
GlowButton(
    title: "Explore",
    icon: "🔍",
    gradient: LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.8, blue: 1),
            Color(red: 0.3, green: 1, blue: 0.8)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    ),
    action: {}
)
```
- **Colors**: Cyan (#66CCFF) → Teal (#4EFFCC)
- **Glow**: Cool blue-green shadow
- **Use Case**: Secondary actions, exploratory buttons

## 2. Glow Flame Variations

### Warm Yellow Flame
```swift
GlowFlame(
    color: Color(red: 1, green: 0.7, blue: 0.2),
    size: 80
)
```
- **Dominant Color**: Golden Yellow
- **Inner Gradient**: More opaque center
- **Outer Glow**: Soft fade to transparent
- **Animation**: Scales 1.0 → 1.3 continuously

### Pink Flame
```swift
GlowFlame(
    color: Color(red: 1, green: 0.3, blue: 0.5),
    size: 80
)
```
- **Dominant Color**: Hot Pink
- **Effect**: Romantic, energetic feel
- **Use Case**: Feature highlights, celebrations

### Cool Blue Flame
```swift
GlowFlame(
    color: Color(red: 0.3, green: 0.8, blue: 1),
    size: 80
)
```
- **Dominant Color**: Ice Blue
- **Effect**: Calm, technical feel
- **Use Case**: Loading states, processing

### Size Variations
- **Small** (40): Compact indicator
- **Medium** (80): Default, balanced
- **Large** (150): Prominent focal point

## 3. Glow Star Variations

### Warm Golden Star
```swift
GlowStar(
    color: Color(red: 1, green: 0.8, blue: 0.2),
    size: 80
)
```
- **Point Count**: 6 points
- **Rotation**: 360° every 3 seconds
- **Bloom Radius**: 1.5x the size
- **Pulse**: 1.0 → 1.1 scale

### Pink Star
```swift
GlowStar(
    color: Color(red: 1, green: 0.4, blue: 0.6),
    size: 60
)
```
- **Effect**: Playful, energetic
- **Animation**: Continuous gentle pulse

### Cyan Star
```swift
GlowStar(
    color: Color(red: 0.4, green: 0.8, blue: 1),
    size: 100
)
```
- **Effect**: Large, prominent
- **Blur**: Soft glow radius
- **Use Case**: Success states, achievements

## 4. Text Reveal Animations

### Pink-to-Orange Reveal
```swift
TextReveal(
    text: "Opus 5.5 is cooking",
    colors: [
        Color(red: 1, green: 0.4, blue: 0.6),
        Color(red: 1, green: 0.7, blue: 0.2)
    ]
)
```
- **Animation Type**: Left-to-right reveal
- **Duration**: 2.5 seconds
- **Repeat**: Infinite with autoreverses
- **Font Size**: 32pt, light weight

### Cool Gradient Reveal
```swift
TextReveal(
    text: "Build it",
    colors: [
        Color(red: 0.4, green: 0.8, blue: 1),
        Color(red: 0.3, green: 1, blue: 0.8)
    ]
)
```
- **Colors**: Cyan to Teal
- **Effect**: Modern, tech-forward
- **Contrast**: High on dark backgrounds

## 5. Character Reveal Variations

### Standard Character Reveal
```swift
CharacterReveal(
    text: "Cooking",
    duration: 2.0
)
```
- **Timing**: Each character appears sequentially
- **Delay**: Duration / character count
- **Animation**: 0.3s ease-out per character
- **Default Gradient**: Warm pink-orange

### Custom Duration
```swift
CharacterReveal(
    text: "Amazing",
    duration: 2.5,
    gradient: LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1, green: 0.5, blue: 0.3),
            Color(red: 1, green: 0.7, blue: 0.4)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
)
```
- **Duration**: Adjustable (slower = 3.0s, faster = 1.0s)
- **Custom Gradient**: Full color control
- **Font**: 28pt, semibold

### Fast Reveal
```swift
CharacterReveal(
    text: "Done!",
    duration: 1.0
)
```
- **Speed**: Quick, punchy reveal
- **Use Case**: Completion states, confirmations

## 6. Background Variations

### Dark Theme
```swift
AnimatedBackground(isDark: true, duration: 3)
```
- **Start Color**: Pure black (#000000)
- **End Color**: Dark navy (#1A1A26)
- **Gradient Direction**: Top-left to bottom-right
- **Animation**: Subtle color shifts every 3s

### Light Theme
```swift
AnimatedBackground(isDark: false, duration: 3)
```
- **Start Color**: Off-white (#F7F3EA)
- **End Color**: Warm beige (#F0E8DF)
- **Effect**: Subtle, sophisticated
- **Use Case**: Daytime mode, premium feel

### Custom Duration
```swift
AnimatedBackground(isDark: true, duration: 5)
```
- **Slower**: 5s duration = calming, meditative
- **Faster**: 2s duration = energetic, dynamic

## 7. Advanced Combinations

### Cooking Scene
```swift
ZStack {
    AnimatedBackground(isDark: true)
    
    VStack(spacing: 30) {
        TextReveal(text: "Opus 5.5 is cooking")
        GlowFlame(color: Color(red: 1, green: 0.7, blue: 0.2), size: 100)
    }
}
```
- **Concept**: "Something is being prepared"
- **Mood**: Warm, anticipatory
- **Colors**: Unified warm palette

### Action Panel
```swift
VStack(spacing: 20) {
    HStack(spacing: 20) {
        GlowButton(
            title: "Build",
            icon: "</> ",
            gradient: buildGradient,
            action: {}
        )
        GlowButton(
            title: "Deploy",
            icon: "🚀",
            gradient: deployGradient,
            action: {}
        )
    }
}
```
- **Layout**: Side-by-side buttons
- **Colors**: Distinct but harmonious
- **Use Case**: Multi-action screens

### Feature Highlight
```swift
ZStack {
    AnimatedBackground(isDark: false)
    
    VStack(spacing: 40) {
        GlowStar(color: Color(red: 1, green: 0.8, blue: 0.2), size: 120)
        
        CharacterReveal(text: "Premium")
        
        GlowButton(title: "Get Started", icon: "⭐")
    }
}
```
- **Hierarchy**: Star → Text → Button
- **Theme**: Premium, exclusive feel
- **Background**: Light for contrast

## Color Reference

### Warm Palette
- Pink: `Color(red: 1, green: 0.4, blue: 0.6)` #FF6699
- Coral: `Color(red: 1, green: 0.5, blue: 0.3)` #FF8050
- Orange: `Color(red: 1, green: 0.6, blue: 0.2)` #FF9933
- Gold: `Color(red: 1, green: 0.8, blue: 0.2)` #FFCC33

### Cool Palette
- Cyan: `Color(red: 0.4, green: 0.8, blue: 1)` #66CCFF
- Teal: `Color(red: 0.3, green: 1, blue: 0.8)` #4DFFCC
- Sky: `Color(red: 0.3, green: 0.8, blue: 1)` #4DCCFF

### Background
- Black: `Color.black` #000000
- Dark Navy: `Color(red: 0.1, green: 0.1, blue: 0.15)` #191826
- Off-white: `Color(red: 0.97, green: 0.95, blue: 0.92)` #F7F3EA
- Warm Beige: `Color(red: 0.95, green: 0.92, blue: 0.88)` #F0E8DF

## Animation Timing

| Component | Duration | Repeat | Effect |
|-----------|----------|--------|--------|
| GlowButton | 1.5s | Yes | Pulse glow |
| GlowFlame | 1.5s | Yes | Scale breathe |
| GlowStar | 3.0s rotation + 1.5s scale | Yes | Spin & pulse |
| TextReveal | 2.5s | Yes | Left to right |
| CharacterReveal | Custom | Yes | Sequential |
| Background | 3.0s | Yes | Subtle shift |

## Responsive Sizing

### iPhone SE / 8 (Small)
- Button: 56pt height
- Flame: 60pt diameter
- Star: 50pt diameter
- Text: 24pt

### iPhone 15 (Medium) - Default
- Button: 56pt height
- Flame: 80pt diameter
- Star: 60pt diameter
- Text: 32pt

### iPad (Large)
- Button: 64pt height
- Flame: 120pt diameter
- Star: 100pt diameter
- Text: 48pt

## Usage Examples by Scene

### Loading Screen
- Background: Dark animated
- Element: GlowFlame (blue)
- Text: "Loading..."

### Success State
- Background: Light animated
- Element: GlowStar (gold)
- Text: CharacterReveal "Success!"

### Feature Launch
- Background: Dark animated
- Elements: TextReveal + GlowButton + GlowStar
- Layout: Centered vertical stack

### Multi-Action Screen
- Background: Solid color
- Elements: Multiple GlowButtons side-by-side
- Organization: Grid or list layout
