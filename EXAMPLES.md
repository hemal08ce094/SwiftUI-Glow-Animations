# SwiftUI Glow Animations - Code Examples

Complete working examples for common use cases.

## 1. Loading Screen

```swift
import SwiftUI
import GlowAnimations

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)
            
            VStack(spacing: 40) {
                Spacer()
                
                GlowFlame(
                    color: Color(red: 0.3, green: 0.8, blue: 1),
                    size: 100
                )
                
                VStack(spacing: 15) {
                    Text("Preparing something amazing")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                    
                    CharacterReveal(
                        text: "Loading...",
                        duration: 2.0
                    )
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoadingScreen()
}
```

## 2. Feature Launch Modal

```swift
import SwiftUI
import GlowAnimations

struct FeatureLaunchModal: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AnimatedBackground(isDark: false)
            
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    GlowStar(
                        color: Color(red: 1, green: 0.8, blue: 0.2),
                        size: 100
                    )
                    
                    TextReveal(
                        text: "New Feature",
                        colors: [
                            Color(red: 1, green: 0.4, blue: 0.6),
                            Color(red: 1, green: 0.7, blue: 0.2)
                        ]
                    )
                }
                
                Text("Experience the power of AI-generated animations in your SwiftUI apps")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    GlowButton(
                        title: "Explore",
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
                    
                    Button(action: { dismiss() }) {
                        Text("Maybe Later")
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.black)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(28)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    FeatureLaunchModal()
}
```

## 3. Settings Page with Glow Effects

```swift
import SwiftUI
import GlowAnimations

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground(isDark: true)
                
                VStack {
                    List {
                        Section("Display") {
                            HStack {
                                Label("Theme", systemImage: "sun.max")
                                Spacer()
                                Text("Dark")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Section("Features") {
                            HStack {
                                GlowStar(
                                    color: Color(red: 1, green: 0.8, blue: 0.2),
                                    size: 30
                                )
                                Text("Premium Features")
                            }
                        }
                        
                        Section("Actions") {
                            GlowButton(
                                title: "Save Settings",
                                icon: "✓",
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
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
```

## 4. Onboarding Flow

```swift
import SwiftUI
import GlowAnimations

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)
            
            VStack(spacing: 30) {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        title: "Opus 5.5",
                        subtitle: "is actually cooking",
                        icon: { GlowFlame(size: 100) }
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        title: "Beautiful",
                        subtitle: "animations made easy",
                        icon: { GlowStar(color: Color(red: 1, green: 0.8, blue: 0.2), size: 100) }
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        title: "Get Started",
                        subtitle: "in minutes",
                        icon: { GlowButton(
                            title: "Let's Go",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.4, blue: 0.6),
                                    Color(red: 1, green: 0.7, blue: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            action: {}
                        )}
                    )
                    .tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }
}

struct OnboardingPage<Icon: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let icon: () -> Icon
    
    var body: some View {
        VStack(spacing: 20) {
            icon()
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
```

## 5. Action Bar

```swift
import SwiftUI
import GlowAnimations

struct ActionBar: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
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
                
                GlowButton(
                    title: "Deploy",
                    icon: "🚀",
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
            }
            
            HStack(spacing: 12) {
                GlowButton(
                    title: "Test",
                    icon: "✓",
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 1, blue: 0.6),
                            Color(red: 0.2, green: 0.8, blue: 0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    action: {}
                )
                
                GlowButton(
                    title: "Share",
                    icon: "↗",
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1, green: 0.6, blue: 0.3),
                            Color(red: 1, green: 0.8, blue: 0.2)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    action: {}
                )
            }
        }
        .padding()
    }
}

#Preview {
    ZStack {
        AnimatedBackground(isDark: true)
        
        VStack {
            Spacer()
            ActionBar()
        }
    }
}
```

## 6. Status Card

```swift
import SwiftUI
import GlowAnimations

struct StatusCard: View {
    let status: String
    let isSuccess: Bool
    
    var body: some View {
        ZStack {
            AnimatedBackground(isDark: !isSuccess)
            
            VStack(spacing: 20) {
                if isSuccess {
                    GlowStar(
                        color: Color(red: 1, green: 0.8, blue: 0.2),
                        size: 80
                    )
                } else {
                    GlowFlame(
                        color: Color(red: 1, green: 0.4, blue: 0.6),
                        size: 80
                    )
                }
                
                CharacterReveal(
                    text: status,
                    duration: 1.5
                )
                
                Text(isSuccess ? "Everything is working perfectly" : "Something needs attention")
                    .foregroundColor(isSuccess ? .black : .white)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .background(Color.white.opacity(isSuccess ? 0.05 : 0.02))
            .cornerRadius(20)
            .padding()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusCard(status: "Success", isSuccess: true)
        StatusCard(status: "Processing", isSuccess: false)
    }
}
```

## 7. Hero Section

```swift
import SwiftUI
import GlowAnimations

struct HeroSection: View {
    var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    TextReveal(
                        text: "Opus 5.5 is cooking",
                        colors: [
                            Color(red: 1, green: 0.4, blue: 0.6),
                            Color(red: 1, green: 0.7, blue: 0.2)
                        ]
                    )
                    .font(.system(size: 40, weight: .bold))
                    
                    Text("Experience the next generation of AI-powered animations")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                GlowFlame(
                    color: Color(red: 1, green: 0.7, blue: 0.2),
                    size: 120
                )
                
                Spacer()
                
                GlowButton(
                    title: "Get Started",
                    icon: "→",
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
                .padding()
            }
        }
    }
}

#Preview {
    HeroSection()
}
```

## 8. Animated Navigation

```swift
import SwiftUI
import GlowAnimations

struct AnimatedNavigationView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HeroSection()
                    .tag(0)
                
                FeatureLaunchModal()
                    .tag(1)
                
                StatusCard(status: "Ready", isSuccess: true)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        GlowStar(
                            color: selectedTab == index
                                ? Color(red: 1, green: 0.8, blue: 0.2)
                                : Color(red: 1, green: 0.8, blue: 0.2).opacity(0.3),
                            size: selectedTab == index ? 30 : 20
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedTab = index
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    AnimatedNavigationView()
}
```

## Performance Tips

1. **Limit Concurrent Animations**: Use `.id()` to prevent unnecessary re-renders
2. **Use `@State` Wisely**: Keep animation state minimal
3. **Optimize Blur Radius**: Larger blur radius = more performance cost
4. **Test on Real Devices**: Simulators may show different performance
5. **Consider Reduce Motion**: Check `@Environment(\.accessibilityReduceMotion)`

```swift
struct PerformanceOptimizedView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        if reduceMotion {
            StaticView()
        } else {
            AnimatedView()
        }
    }
}
```

## Accessibility Considerations

Always provide alternatives for users with motion sensitivity:

```swift
struct AccessibleGlowButton: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let title: String
    let action: () -> Void
    
    var body: some View {
        if reduceMotion {
            Button(action: action) {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(28)
            }
        } else {
            GlowButton(title: title, gradient: defaultGradient, action: action)
        }
    }
}
```
