import SwiftUI

/// "Start with a *spark*": regular sans lead words followed by one italic serif
/// accent word in gold. Sizes are design units.
public struct CaptionText: View {
    public var lead: String
    public var accent: String
    public var fontSize: CGFloat
    public var leadColor: Color
    public var accentColor: Color
    /// Serif italic optically reads smaller than Outfit at the same size.
    public var accentScale: CGFloat

    public init(
        _ lead: String,
        accent: String,
        fontSize: CGFloat = 56,
        leadColor: Color = GlowTheme.cream,
        accentColor: Color = GlowTheme.gold,
        accentScale: CGFloat = 1.15
    ) {
        self.lead = lead
        self.accent = accent
        self.fontSize = fontSize
        self.leadColor = leadColor
        self.accentColor = accentColor
        self.accentScale = accentScale
    }

    public var body: some View {
        let leadText = Text(verbatim: lead + " ")
            .font(GlowFonts.sans(weight: .regular, size: fontSize))
            .foregroundColor(leadColor)
        let accentText = Text(verbatim: accent)
            .font(GlowFonts.serifItalic(size: fontSize * accentScale))
            .foregroundColor(accentColor)
        return (leadText + accentText)
            .lineLimit(1)
            .fixedSize()
    }
}
