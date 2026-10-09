import SwiftUI
import GlowAnimations

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Exact Animation Replicas") {
                    NavigationLink(destination: SpiralVortexAnimation()) {
                        Label("Spiral Vortex", systemImage: "sparkles")
                    }
                    NavigationLink(destination: RotatingCircleWithNodes()) {
                        Label("Circle with Nodes", systemImage: "circle.fill")
                    }
                    NavigationLink(destination: MorphingFlowerShape()) {
                        Label("Flower Shape", systemImage: "flower.fill")
                    }
                    NavigationLink(destination: GradientPillAnimation()) {
                        Label("Gradient Pill", systemImage: "capsule.fill")
                    }
                    NavigationLink(destination: DiagonalGlowingLine()) {
                        Label("Glowing Line", systemImage: "line.diagonal")
                    }
                }

                Section("Other Components") {
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
            }
            .navigationTitle("Glow Animations")
        }
    }
}

struct GlowButtonDemo: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Glow Button Variations")
                    .font(.headline)
                    .foregroundColor(.white)

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

struct GlowFlameDemo: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Flame Variations")
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 40) {
                    VStack(spacing: 10) {
                        GlowFlame(color: Color(red: 1, green: 0.7, blue: 0.2), size: 80)
                        Text("Warm").foregroundColor(.white).font(.caption)
                    }

                    VStack(spacing: 10) {
                        GlowFlame(color: Color(red: 1, green: 0.3, blue: 0.5), size: 80)
                        Text("Pink").foregroundColor(.white).font(.caption)
                    }

                    VStack(spacing: 10) {
                        GlowFlame(color: Color(red: 0.3, green: 0.8, blue: 1), size: 80)
                        Text("Cool").foregroundColor(.white).font(.caption)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Flame Variations")
    }
}

struct GlowStarDemo: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Star Variations")
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 40) {
                    GlowStar(color: Color(red: 1, green: 0.8, blue: 0.2), size: 80)
                    GlowStar(color: Color(red: 1, green: 0.4, blue: 0.6), size: 80)
                    GlowStar(color: Color(red: 0.4, green: 0.8, blue: 1), size: 80)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Star Variations")
    }
}

#Preview {
    ContentView()
}
