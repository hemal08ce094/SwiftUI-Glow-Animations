import SwiftUI

/// The reel title drawn over every scene: Outfit Light 46, white, centred at x 360, baseline y 329.
/// Light, not Regular: the reference stems measure 3 px at this size, Regular renders 4 to 5 px.
public struct ReelTitle: View {
    public static let baselineY: CGFloat = 329

    public var text: String

    public init(text: String = "Opus 5.5 is actually cooking") {
        self.text = text
    }

    public var body: some View {
        Text(verbatim: text)
            .font(GlowFonts.sans(weight: .light, size: 46))
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .fixedSize()
            .alignmentGuide(VerticalAlignment.top) { $0[.firstTextBaseline] }
            .frame(width: 720, height: 1280, alignment: .top)
            .offset(y: Self.baselineY)
            .allowsHitTesting(false)
    }
}
