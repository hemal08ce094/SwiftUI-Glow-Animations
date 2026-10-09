import SwiftUI

/// Additive glow: the content plus progressively wider blurred copies blended with
/// `.plusLighter`, flattened together so the blend stays local to this view.
struct BloomModifier: ViewModifier {
    var color: Color?
    var radius: CGFloat
    var intensity: Double

    func body(content: Content) -> some View {
        ZStack {
            layer(content, blur: radius * 0.25, opacity: 0.9)
            layer(content, blur: radius * 0.6, opacity: 0.7)
            layer(content, blur: radius, opacity: 0.5)
            content
        }
        .compositingGroup()
    }

    @ViewBuilder
    private func layer(_ content: Content, blur: CGFloat, opacity: Double) -> some View {
        Group {
            if let color {
                content.colorMultiply(color)
            } else {
                content
            }
        }
        .blur(radius: blur)
        .opacity(min(1, opacity * intensity))
        .blendMode(.plusLighter)
    }
}

public extension View {
    /// Adds an additive bloom halo. `radius` is in the caller's coordinate space
    /// (design units inside a `GlowStage`). `color` tints the halo; nil keeps the content colour.
    func bloom(color: Color? = nil, radius: CGFloat = 24, intensity: Double = 1) -> some View {
        modifier(BloomModifier(color: color, radius: radius, intensity: intensity))
    }
}

/// Three-layer point light (white core, gold halo 2.5r, amber halo 8r), blended `.plusLighter`; its frame is the core.
public struct GlowDot: View {
    public var coreRadius: CGFloat
    public var tint: Color
    public var intensity: Double

    public init(coreRadius: CGFloat, tint: Color = GlowTheme.goldHot, intensity: Double = 1) {
        self.coreRadius = coreRadius
        self.tint = tint
        self.intensity = intensity
    }

    public var body: some View {
        let r = coreRadius
        ZStack {
            Circle()
                .fill(GlowTheme.amber)
                .frame(width: r * 16, height: r * 16)
                .blur(radius: r * 2.2)
                .opacity(min(1, 0.55 * intensity))
            Circle()
                .fill(tint)
                .frame(width: r * 5, height: r * 5)
                .blur(radius: r * 0.6)
                .opacity(min(1, intensity))
            Circle()
                .fill(Color.white)
                .frame(width: r * 2, height: r * 2)
        }
        .frame(width: r * 2, height: r * 2)
        .compositingGroup()
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }
}
