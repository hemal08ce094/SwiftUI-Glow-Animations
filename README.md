# SwiftUI Glow Animations

A collection of beautiful, modern glow and gradient animations for SwiftUI, inspired by the latest motion design trends.

## Features

### 🎨 Components

- **GlowButton** - Gradient buttons with dynamic glow effects
- **GlowFlame** - Animated flame/glow particles with radial gradients
- **GlowStar** - Rotating star with bloom effect
- **TextReveal** - Gradient text reveal animations
- **CharacterReveal** - Character-by-character text animation
- **ConnectorLine** - Animated connecting lines with gradients
- **AnimatedBackground** - Smooth gradient background transitions
- **PulseBackground** - Background with pulsing effect

### ✨ Effects

- Warm gradient colors (pink → orange → yellow)
- Dynamic glow shadows that pulse
- Smooth easing animations
- Repeating autoreverses
- Multiple variations per component

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/hemal08ce094/SwiftUI-Glow-Animations", from: "1.0.0")
```

Or add to your Xcode project via:
1. File → Add Packages...
2. Enter: `https://github.com/hemal08ce094/SwiftUI-Glow-Animations`

## Usage

### Basic Button

```swift
import SwiftUI
import GlowAnimations

struct ContentView: View {
    var body: some View {
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
            action: { print("Tapped") }
        )
        .padding()
    }
}
```

### Flame Animation

```swift
ZStack {
    AnimatedBackground(isDark: true)
    
    GlowFlame(
        color: Color(red: 1, green: 0.7, blue: 0.2),
        size: 80
    )
}
```

### Star Animation

```swift
GlowStar(
    color: Color(red: 1, green: 0.8, blue: 0.2),
    size: 60
)
```

### Text Animations

```swift
VStack {
    TextReveal(
        text: "Opus 5.5 is cooking",
        colors: [
            Color(red: 1, green: 0.4, blue: 0.6),
            Color(red: 1, green: 0.7, blue: 0.2)
        ]
    )
    
    CharacterReveal(
        text: "Build it",
        duration: 2.0
    )
}
```

### Combined Layout

```swift
ZStack {
    AnimatedBackground(isDark: true)
    
    VStack(spacing: 20) {
        TextReveal(text: "Opus 5.5 is cooking")
        
        GlowButton(
            title: "Build",
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
        .padding()
        
        GlowStar(
            color: Color(red: 1, green: 0.8, blue: 0.2),
            size: 60
        )
    }
    .padding()
}
```

## Color Presets

### Warm (Default)
- Pink: `Color(red: 1, green: 0.4, blue: 0.6)`
- Orange: `Color(red: 1, green: 0.6, blue: 0.2)`
- Yellow: `Color(red: 1, green: 0.8, blue: 0.2)`

### Cool
- Cyan: `Color(red: 0.3, green: 0.8, blue: 1)`
- Teal: `Color(red: 0.3, green: 1, blue: 0.8)`

### Sunset
- Red: `Color(red: 1, green: 0.5, blue: 0.3)`
- Orange: `Color(red: 1, green: 0.7, blue: 0.4)`

## Customization

### Custom Gradient

```swift
let customGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 0.5, green: 0.2, blue: 0.9),
        Color(red: 0.2, green: 0.8, blue: 0.9)
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Adjust Animation Speed

All animations use standard SwiftUI animation durations that can be modified:
- GlowButton: ~1.5s pulse
- GlowFlame: 1.5s scale animation
- GlowStar: 3s rotation + 1.5s scale
- TextReveal: 2.5s total duration

## Demo App

Run the included demo to see all variations:

```swift
DemoView()
```

Navigate through different sections to explore:
- Glow Effects (Button, Flame, Star)
- Text Effects (Reveal, Character)
- Backgrounds (Dark, Light, Pulse)
- Combined Layouts

## System Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9+

## License

MIT License - feel free to use in your projects!

## Author

Created by Hemal Modi - [@hemal08ce094](https://github.com/hemal08ce094)

Inspired by modern motion design and the "Opus is cooking" animation concept.
