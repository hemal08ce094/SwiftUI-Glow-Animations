# iOS Integration Guide - Exact Animation Replicas

Complete guide for integrating the frame-accurate animations into your iOS applications.

## Quick Start

### 1. Add to Your Project

**Via Swift Package Manager:**
```bash
File → Add Packages
https://github.com/hemal08ce094/SwiftUI-Glow-Animations
```

**Or manually copy `PreciseAnimations.swift` to your project**

### 2. Import in Your View
```swift
import SwiftUI
import GlowAnimations  // If using SPM

struct MyView: View {
    var body: some View {
        SpiralVortexAnimation()
    }
}
```

---

## Animation Library

### 1. SpiralVortexAnimation
**Best For**: Loading states, introduction sequences, "wait please" moments

```swift
ZStack {
    Color.black
    
    SpiralVortexAnimation()
}
.ignoresSafeArea()
```

**Characteristics**:
- Duration: 2.0 seconds
- Central glowing sphere with concentric rings
- 3D perspective effect
- Includes vertical light streaks
- Smooth breathing scale animation

**Customization**:
```swift
// Modify timing
struct CustomSpiralVortex: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        // Copy SpiralVortexAnimation code
        // Change duration from 2.0 to 3.0
    }
}
```

---

### 2. RotatingCircleWithNodes
**Best For**: Loading progress, network activity, processing states

```swift
VStack {
    Text("Processing...")
    
    RotatingCircleWithNodes()
        .frame(width: 250, height: 250)
}
.background(Color.black)
```

**Characteristics**:
- Duration: 4.0 seconds (rotation)
- 6 glowing nodes rotating around circle
- Staggered opacity pulses
- Dual-color gradient circle
- Premium, tech-forward feel

**Usage in Apps**:
```swift
// Loading screen
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                RotatingCircleWithNodes()
                    .frame(width: 200, height: 200)
                
                Text("Syncing with Claude...")
                    .foregroundColor(.white)
            }
        }
    }
}
```

---

### 3. MorphingFlowerShape
**Best For**: Achievement badges, success states, special highlights

```swift
HStack(spacing: 30) {
    VStack {
        MorphingFlowerShape()
            .frame(width: 200, height: 200)
        
        Text("Achievement Unlocked")
            .foregroundColor(.white)
    }
}
.background(Color.black)
```

**Characteristics**:
- Duration: 3.5 seconds (rotation)
- 6-petal flower/gear design
- Staggered petal pulses
- Warm golden color palette
- Creates festive, celebratory feeling

**Usage in Apps**:
```swift
// Success modal
struct SuccessModalView: View {
    @State private var showAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 30) {
                if showAnimation {
                    MorphingFlowerShape()
                        .frame(width: 240, height: 240)
                }
                
                Text("Mission Complete!")
                    .font(.title)
                    .foregroundColor(.white)
                
                Button("Continue") { }
            }
        }
        .onAppear {
            withAnimation {
                showAnimation = true
            }
        }
    }
}
```

---

### 4. GradientPillAnimation
**Best For**: CTA buttons, purchase prompts, important actions

```swift
VStack {
    Text("Ready to build?")
    
    GradientPillAnimation()
        .onTapGesture {
            // Handle action
        }
}
```

**Characteristics**:
- Duration: 1.8 seconds
- Pulsing scale and shadow
- Pink-to-orange gradient
- Draws attention through breathing effect
- High conversion potential

**Usage in Apps**:
```swift
// Call-to-action screen
struct CTAScreen: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                VStack(spacing: 15) {
                    Text("Get Started Today")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Join millions using Claude")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                GradientPillAnimation()
                    .onTapGesture {
                        // Navigate to signup
                    }
                
                Button(action: {}) {
                    Text("Maybe Later")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(28)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
```

---

### 5. DiagonalGlowingLine
**Best For**: Transitions, dividers, visual accents, connecting elements

```swift
VStack {
    DiagonalGlowingLine()
        .frame(height: 250)
    
    Text("Next Section")
}
```

**Characteristics**:
- Duration: 2.5 seconds (rotation)
- Rotating diagonal line
- Layered blur + sharp core
- Opacity pulsing (1.5s)
- Abstract, modern aesthetic

**Usage in Apps**:
```swift
// Divider between sections
struct SectionDivider: View {
    var body: some View {
        VStack(spacing: 20) {
            // Previous section
            VStack {
                Text("Your Progress")
                    .foregroundColor(.white)
            }
            .frame(height: 150)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Animated divider
            DiagonalGlowingLine()
                .frame(height: 150)
            
            // Next section
            VStack {
                Text("Continue Here")
                    .foregroundColor(.white)
            }
            .frame(height: 150)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.black)
    }
}
```

---

## Real-World Examples

### Example 1: App Launch Screen
```swift
struct LaunchScreen: View {
    @State private var progress = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                SpiralVortexAnimation()
                    .frame(height: 200)
                
                VStack(spacing: 10) {
                    Text("Opus 5.5 is cooking")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Preparing your experience...")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                ProgressView(value: progress)
                    .tint(Color(red: 1, green: 0.65, blue: 0.2))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3)) {
                            progress = 1.0
                        }
                    }
            }
            .padding()
        }
    }
}
```

### Example 2: Feature Showcase
```swift
struct FeatureShowcase: View {
    @State private var activeFeature = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $activeFeature) {
                // Feature 1
                VStack(spacing: 30) {
                    MorphingFlowerShape()
                        .frame(width: 200, height: 200)
                    
                    Text("Intelligent Animations")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Frame-perfect animations inspired by Opus")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .tag(0)
                
                // Feature 2
                VStack(spacing: 30) {
                    RotatingCircleWithNodes()
                        .frame(width: 200, height: 200)
                    
                    Text("Smooth Performance")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("60 FPS on all modern devices")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .tag(1)
                
                // Feature 3
                VStack(spacing: 30) {
                    SpiralVortexAnimation()
                        .frame(height: 200)
                    
                    Text("Easy Integration")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Add to your apps in minutes")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}
```

### Example 3: Settings with Animations
```swift
struct AnimatedSettingsView: View {
    @State private var isPremium = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                List {
                    Section("Your Status") {
                        HStack {
                            if isPremium {
                                MorphingFlowerShape()
                                    .frame(width: 40, height: 40)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Premium Member")
                                    .foregroundColor(.white)
                                Text("Unlock all features")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("Features") {
                        HStack {
                            RotatingCircleWithNodes()
                                .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading) {
                                Text("Advanced Animations")
                                Text("Full animation library")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("Actions") {
                        GradientPillAnimation()
                            .frame(height: 56)
                            .onTapGesture {
                                isPremium.toggle()
                            }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
    }
}
```

---

## Customization Patterns

### Change Colors
```swift
struct CustomSpiralVortex: View {
    var body: some View {
        ZStack {
            Color.black
            
            // Modify the gradient in SpiralVortexAnimation
            // Change Color(red: 1, green: 0.9, blue: 0.4) to your color
        }
    }
}
```

### Adjust Timing
```swift
// Faster (energetic)
.onAppear {
    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
        // animation code
    }
}

// Slower (calming)
.onAppear {
    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
        // animation code
    }
}
```

### Combine Animations
```swift
struct CombinedAnimationView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                SpiralVortexAnimation()
                    .frame(height: 150)
                
                DiagonalGlowingLine()
                    .frame(height: 150)
                
                GradientPillAnimation()
                    .onTapGesture { }
            }
            .padding()
        }
    }
}
```

---

## Performance Considerations

### Frame Rate
- Target: 60 FPS on iPhone 12+
- Acceptable: 30 FPS on older devices
- Test on real devices, not just simulator

### Optimization Tips
```swift
// Use .drawingGroup() for complex views
SpiralVortexAnimation()
    .drawingGroup()

// Limit concurrent animations
VStack {
    SpiralVortexAnimation()
    // Don't add 3+ complex animations in same view
}

// Disable when in background
@Environment(\.scenePhase) var scenePhase

if scenePhase == .active {
    SpiralVortexAnimation()
}
```

### Memory Usage
- Each animation: ~0.5-1MB memory
- Shadow effects increase cost
- Blur radius > 20pt = significant cost

---

## Accessibility

### Respect Motion Preferences
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

if reduceMotion {
    // Show static version
    StaticSpiralView()
} else {
    // Show animated version
    SpiralVortexAnimation()
}
```

### Provide Alternatives
- Don't rely solely on animation for information
- Include text labels with colors
- Provide pause/play controls if needed

---

## Testing Checklist

- [ ] Animation renders at 60 FPS on target device
- [ ] Colors match video reference
- [ ] Timing matches specifications (±100ms acceptable)
- [ ] Smooth loop with no jumps or pauses
- [ ] Works in light and dark modes
- [ ] Respects `reduceMotion` setting
- [ ] Memory usage < 2MB per animation
- [ ] Doesn't interfere with other UI elements
- [ ] Accessible with VoiceOver
- [ ] Performs well on iPhone 11+

---

## Troubleshooting

### Animation not smooth
- Check frame rate in device settings
- Reduce blur radius values
- Use `.drawingGroup()` modifier
- Profile with Xcode Instruments

### Colors don't match
- Verify color space (sRGB)
- Check opacity values
- Ensure no color filters applied globally
- Test on actual device (simulator may differ)

### Animation loops incorrectly
- Verify `repeatForever(autoreverses:)` parameter
- Check animation duration values
- Ensure state variables reset properly
- Use `.onAppear` for initial setup

### Memory issues
- Reduce animation complexity
- Limit number of simultaneous animations
- Use `.onDisappear` to stop animations
- Check for memory leaks in Instruments

---

## File Structure

```
YourProject/
├── ContentView.swift
├── Screens/
│   ├── LaunchScreen.swift
│   ├── LoadingView.swift
│   └── SuccessModal.swift
└── Animations/
    └── PreciseAnimations.swift  (or import from SPM)
```

---

## Support

For issues or questions:
1. Check EXACT-ANIMATIONS.md for specifications
2. Review implementation examples above
3. Compare with demo app on GitHub
4. Check frame timings with Xcode Instruments

---

## License

MIT License - Free to use in commercial and personal projects
