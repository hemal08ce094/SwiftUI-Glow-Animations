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
