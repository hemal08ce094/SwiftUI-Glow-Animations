import SwiftUI

public struct AnimatedBackground: View {
    @State private var colors: [Color]
    let duration: Double
    let isDark: Bool

    public init(isDark: Bool = true, duration: Double = 3) {
        self.isDark = isDark
        self.duration = duration
        self._colors = State(
            initialValue: isDark
                ? [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]
                : [Color(red: 0.97, green: 0.95, blue: 0.92), Color(red: 0.95, green: 0.92, blue: 0.88)]
        )
    }

    public var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            if isDark {
                colors = [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.15, green: 0.12, blue: 0.2)
                ]
            } else {
                colors = [
                    Color(red: 0.99, green: 0.97, blue: 0.95),
                    Color(red: 0.92, green: 0.88, blue: 0.85)
                ]
            }
        }
    }
}

public struct PulseBackground: View {
    let colors: [Color]
    @State private var scale: CGFloat = 1.0

    public init(colors: [Color]) {
        self.colors = colors
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [colors[0].opacity(0.3), colors[0].opacity(0)]),
                        center: .center,
                        radius: 300
                    )
                )
                .scaleEffect(scale)
                .opacity(0.5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.5
            }
        }
    }
}

