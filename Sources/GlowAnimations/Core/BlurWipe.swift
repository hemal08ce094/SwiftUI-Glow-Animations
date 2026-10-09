import SwiftUI

struct BlurWipeModifier: ViewModifier {
    var progress: Double
    var edgeWidth: CGFloat
    var blur: CGFloat
    var reversed: Bool

    func body(content: Content) -> some View {
        let pad = blur * 2
        let p = CGFloat(Ease.clamp01(progress))
        ZStack {
            content
                .padding(pad)
                .mask { mask(pad: pad, p: p, sharp: true) }
            content
                .padding(pad)
                .blur(radius: blur)
                .mask { mask(pad: pad, p: p, sharp: false) }
        }
        .padding(-pad)
    }

    private func mask(pad: CGFloat, p: CGFloat, sharp: Bool) -> some View {
        GeometryReader { geo in
            let width = geo.size.width - 2 * pad
            let front = pad + p * (width + edgeWidth)
            let bandStart = front - edgeWidth
            ZStack(alignment: .leading) {
                if sharp {
                    Rectangle()
                        .frame(width: max(0, bandStart))
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: edgeWidth / 2)
                        .offset(x: bandStart)
                } else {
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: edgeWidth)
                        .offset(x: bandStart)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
            .scaleEffect(x: reversed ? -1 : 1)
            .opacity(p > 0 ? 1 : 0)
        }
    }
}

public extension View {
    /// Left-to-right reveal (right-to-left when `reversed`): sharp behind the edge, blurred and fading in the edge band.
    func blurWipe(progress: Double, edgeWidth: CGFloat = 40, blur: CGFloat = 8, reversed: Bool = false) -> some View {
        modifier(BlurWipeModifier(progress: progress, edgeWidth: edgeWidth, blur: blur, reversed: reversed))
    }

    /// Fades in with `u`: opacity `u`, blur `blur·(1−u)`.
    func blurFade(u: Double, blur: CGFloat = 8) -> some View {
        let u = Ease.clamp01(u)
        return opacity(u).blur(radius: blur * (1 - u))
    }
}
