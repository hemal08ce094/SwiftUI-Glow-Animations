import SwiftUI

public struct ConnectorLine: View {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let gradientColors: [Color]
    @State private var animatedEnd: CGFloat = 0

    public init(startPoint: CGPoint, endPoint: CGPoint, gradientColors: [Color]) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.gradientColors = gradientColors
    }

    public var body: some View {
        Canvas { context, canvasSize in
            var path = Path()
            path.move(to: startPoint)

            let controlX = (startPoint.x + endPoint.x) / 2
            let controlY = startPoint.y + (endPoint.y - startPoint.y) / 3

            path.addCurve(
                to: CGPoint(
                    x: startPoint.x + (endPoint.x - startPoint.x) * animatedEnd,
                    y: startPoint.y + (endPoint.y - startPoint.y) * animatedEnd
                ),
                control1: CGPoint(x: controlX, y: controlY),
                control2: CGPoint(x: controlX, y: controlY)
            )

            let gradient = LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )

            context.stroke(path, with: .linearGradient(gradient), lineWidth: 3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animatedEnd = 1.0
            }
        }
    }
}

#Preview {
    Canvas { context, canvasSize in
        var path = Path()
        path.move(to: CGPoint(x: 100, y: 100))
        path.addLine(to: CGPoint(x: 300, y: 300))

        context.stroke(path, with: .color(.white), lineWidth: 2)
    }
}
