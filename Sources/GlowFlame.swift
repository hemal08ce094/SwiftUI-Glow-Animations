import SwiftUI

public struct GlowFlame: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    let color: Color
    let size: CGFloat

    public init(color: Color = Color(red: 1, green: 0.7, blue: 0.2), size: CGFloat = 60) {
        self.color = color
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0)]),
                        center: .center,
                        startRadius: 0, endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .blur(radius: 15)
                .scaleEffect(scale)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.4)]),
                        center: .center,
                        startRadius: 0, endRadius: size / 3
                    )
                )
                .frame(width: size / 1.5, height: size / 1.5)
                .blur(radius: 8)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.3
                opacity = 0.6
            }
        }
    }
}

