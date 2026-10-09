import SwiftUI

public struct GlowStar: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    let pointCount: Int = 6
    let color: Color
    let size: CGFloat

    public init(color: Color = Color(red: 1, green: 0.8, blue: 0.2), size: CGFloat = 60) {
        self.color = color
        self.size = size
    }

    public var body: some View {
        ZStack {
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

                var path = Path()
                let radius = size / 2

                for i in 0..<pointCount {
                    let angle = (Double(i) * 360 / Double(pointCount)) * .pi / 180
                    let x = center.x + radius * CGFloat(cos(angle))
                    let y = center.y + radius * CGFloat(sin(angle))

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()

                context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: 3
                )
            }
            .frame(width: size, height: size)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.6), color.opacity(0)]),
                        center: .center,
                        startRadius: 0, endRadius: size / 2
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 20)
        }
        .scaleEffect(scale)
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 0, z: 1))
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

