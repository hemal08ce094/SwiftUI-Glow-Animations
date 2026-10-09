import SwiftUI

public extension GraphicsContext {
    /// Additive point light: white core → `tint` at 0.3 → amber α0.4 at 0.6 → clear, radius 8·coreRadius.
    func drawGlowDot(at center: CGPoint, coreRadius: CGFloat, tint: Color = GlowTheme.goldHot) {
        var ctx = self
        ctx.blendMode = .plusLighter
        let radius = coreRadius * 8
        let gradient = Gradient(stops: [
            .init(color: .white, location: 0),
            .init(color: .white, location: 0.125),
            .init(color: tint, location: 0.3),
            .init(color: GlowTheme.amber.opacity(0.4), location: 0.6),
            .init(color: .clear, location: 1),
        ])
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        ctx.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
        )
    }
}
