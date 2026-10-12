import SwiftUI

/// Vertically stretched Bernoulli lemniscate centred at (360, 640): x spans 102...618, y spans 520...760.
/// θ = π/2 (mod 2π) is the crossing; π is the far-left tip and 2π the far-right tip.
enum Lemniscate {
    static let center = CGPoint(x: 360, y: 640)
    static let halfWidth: CGFloat = 258
    static let verticalStretch: CGFloat = 1.30

    static func point(_ theta: Double, scale: CGFloat = 1) -> CGPoint {
        let s = sin(theta)
        let c = cos(theta)
        let d = 1 + s * s
        return CGPoint(
            x: center.x + scale * halfWidth * CGFloat(c / d),
            y: center.y + scale * verticalStretch * halfWidth * CGFloat(s * c / d)
        )
    }

    /// Polyline through the curve from `start` to `end` (radians), sampled every `step`.
    static func path(from start: Double, to end: Double, scale: CGFloat = 1, step: Double = .pi / 240) -> Path {
        var path = Path()
        guard end > start else { return path }
        let count = max(1, Int(ceil((end - start) / step)))
        path.move(to: point(start, scale: scale))
        for i in 1...count {
            path.addLine(to: point(start + (end - start) * Double(i) / Double(count), scale: scale))
        }
        return path
    }

    /// Horizontal colour ramp sampled from the fully lit curve: pink at the left tip,
    /// orange then gold through the crossing, pale yellow-white at the right tip.
    static func shading(_ stops: [(x: CGFloat, hex: UInt32)], scale: CGFloat, opacity: Double = 1) -> GraphicsContext.Shading {
        let x0 = center.x - halfWidth
        let x1 = center.x + halfWidth
        let gradient = Gradient(stops: stops.map {
            .init(color: Color(hex: $0.hex, opacity: opacity), location: ($0.x - x0) / (x1 - x0))
        })
        return .linearGradient(
            gradient,
            startPoint: CGPoint(x: center.x + scale * (x0 - center.x), y: center.y),
            endPoint: CGPoint(x: center.x + scale * (x1 - center.x), y: center.y)
        )
    }

    static let coreStops: [(x: CGFloat, hex: UInt32)] = [
        (102, 0xE04A74), (150, 0xF0647A), (230, 0xF2706A), (300, 0xF59060),
        (345, 0xFCB860), (380, 0xFDC864), (410, 0xFDD06C), (490, 0xFDDE7C),
        (570, 0xFDE896), (618, 0xFDECAA),
    ]

    static let haloStops: [(x: CGFloat, hex: UInt32)] = [
        (102, 0xFF2A6C), (230, 0xFF3C2C), (300, 0xFF6A2E), (345, 0xFF9C3E),
        (410, 0xFFAE40), (490, 0xFFB848), (618, 0xFFC870),
    ]
}

/// Radial falloff of the scene-7 point light, sampled at f0630: white to r 4, gold by r 8, amber tail to r 60.
enum ConnectsDot {
    private static let stops: [(r: CGFloat, hex: UInt32)] = [
        (0, 0xFFFFFF), (4, 0xFFFDE8), (6, 0xFDEEA8), (8, 0xF8CF5A), (10, 0xF9BE4B),
        (12, 0xEDA842), (15, 0xC08232), (20, 0x724A1B), (25, 0x442B10), (30, 0x2E1C09),
        (40, 0x1A0E05), (50, 0x0F0703), (60, 0x090402), (75, 0x000000),
    ]

    static let outerRadius: CGFloat = 75

    static func draw(in context: GraphicsContext, at center: CGPoint, opacity: Double = 1) {
        guard opacity > 0 else { return }
        var ctx = context
        ctx.blendMode = .plusLighter
        ctx.opacity = opacity
        let gradient = Gradient(stops: stops.map { .init(color: Color(hex: $0.hex), location: $0.r / outerRadius) })
        let rect = CGRect(x: center.x - outerRadius, y: center.y - outerRadius, width: outerRadius * 2, height: outerRadius * 2)
        ctx.fill(Path(ellipseIn: rect), with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: outerRadius))
    }
}
