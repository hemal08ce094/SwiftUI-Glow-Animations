import SwiftUI

public struct DemoView: View {
    @State private var selectedVariation = 0

    public var body: some View {
        NavigationStack {
            List {
                Section("Glow Effects") {
                    NavigationLink(destination: GlowButtonDemo()) {
                        Label("Glow Button", systemImage: "button.horizontal")
                    }
                    NavigationLink(destination: GlowFlameDemo()) {
                        Label("Glow Flame", systemImage: "flame.fill")
                    }
                    NavigationLink(destination: GlowStarDemo()) {
                        Label("Glow Star", systemImage: "star.fill")
                    }
                }

                Section("Text Effects") {
                    NavigationLink(destination: TextRevealDemo()) {
                        Label("Text Reveal", systemImage: "text.alignleft")
                    }
                    NavigationLink(destination: CharacterRevealDemo()) {
                        Label("Character Reveal", systemImage: "a.circle")
                    }
                }

                Section("Backgrounds") {
                    NavigationLink(destination: BackgroundDemo()) {
                        Label("Animated Backgrounds", systemImage: "square.fill")
                    }
                }

                Section("Layouts") {
                    NavigationLink(destination: CombinedDemo()) {
                        Label("Combined Layout", systemImage: "square.grid.2x2")
                    }
                }
            }
            .navigationTitle("Glow Animations")
        }
    }
}

public struct GlowButtonDemo: View {
    public var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)

            VStack(spacing: 20) {
                Spacer()

                GlowButton(
                    title: "Details",
                    icon: "✨",
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.6), Color(red: 1, green: 0.6, blue: 0.2)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    action: {}
                )
                .padding()

                GlowButton(
                    title: "Build it",
                    icon: "</> ",
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [Color(red: 1, green: 0.5, blue: 0.3), Color(red: 1, green: 0.7, blue: 0.4)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    action: {}
                )
                .padding()

                Spacer()
            }
        }
        .navigationTitle("Glow Buttons")
    }
}

public struct GlowFlameDemo: View {
    public var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)

            VStack(spacing: 30) {
                HStack(spacing: 40) {
                    VStack(spacing: 10) {
                        GlowFlame(color: Color(red: 1, green: 0.7, blue: 0.2), size: 80)
                        Text("Warm")
                            .foregroundColor(.white)
                            .font(.caption)
                    }

                    VStack(spacing: 10) {
                        GlowFlame(color: Color(red: 1, green: 0.3, blue: 0.5), size: 80)
                        Text("Pink")
                            .foregroundColor(.white)
                            .font(.caption)
                    }

                    VStack(spacing: 10) {
                        GlowFlame(color: Color(red: 0.3, green: 0.8, blue: 1), size: 80)
                        Text("Cool")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Glow Flame Variations")
    }
}

public struct GlowStarDemo: View {
    public var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)

            VStack(spacing: 40) {
                HStack(spacing: 40) {
                    GlowStar(color: Color(red: 1, green: 0.8, blue: 0.2), size: 80)
                    GlowStar(color: Color(red: 1, green: 0.4, blue: 0.6), size: 80)
                    GlowStar(color: Color(red: 0.4, green: 0.8, blue: 1), size: 80)
                }
            }
            .padding()
        }
        .navigationTitle("Glow Star Variations")
    }
}

public struct TextRevealDemo: View {
    public var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)

            VStack(spacing: 30) {
                TextReveal(text: "Opus 5.5 is cooking")
                TextReveal(
                    text: "Build it",
                    colors: [Color(red: 1, green: 0.5, blue: 0.3), Color(red: 1, green: 0.7, blue: 0.4)]
                )
                TextReveal(
                    text: "Details",
                    colors: [Color(red: 0.4, green: 0.8, blue: 1), Color(red: 0.3, green: 1, blue: 0.8)]
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Text Reveal")
    }
}

public struct CharacterRevealDemo: View {
    public var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)

            VStack(spacing: 50) {
                CharacterReveal(text: "Cooking")
                CharacterReveal(
                    text: "Amazing",
                    duration: 2.5,
                    gradient: LinearGradient(
                        gradient: Gradient(colors: [Color(red: 1, green: 0.5, blue: 0.3), Color(red: 1, green: 0.7, blue: 0.4)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Character Reveal")
    }
}

public struct BackgroundDemo: View {
    public var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Dark Theme")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(AnimatedBackground(isDark: true))
            .cornerRadius(12)

            VStack {
                Text("Light Theme")
                    .foregroundColor(.black)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(AnimatedBackground(isDark: false))
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .navigationTitle("Animated Backgrounds")
    }
}

public struct CombinedDemo: View {
    public var body: some View {
        ZStack {
            AnimatedBackground(isDark: true)

            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    TextReveal(text: "Opus 5.5 is cooking")
                    GlowFlame(size: 50)
                }

                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        GlowButton(
                            title: "Build",
                            icon: "</> ",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1, green: 0.5, blue: 0.3), Color(red: 1, green: 0.7, blue: 0.4)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            action: {}
                        )
                        GlowButton(
                            title: "Deploy",
                            icon: "🚀",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.4, green: 0.8, blue: 1), Color(red: 0.3, green: 1, blue: 0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            action: {}
                        )
                    }
                }

                GlowStar(color: Color(red: 1, green: 0.8, blue: 0.2), size: 60)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Combined Layout")
    }
}

