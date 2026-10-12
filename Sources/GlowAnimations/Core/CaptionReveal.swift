import CoreText
import SwiftUI

/// "Start with a *spark*" caption whose words blur in left to right and blur out on a stagger.
public struct CaptionReveal: View {
    public enum AccentStyle: Sendable {
        case serifItalicGold, serifItalicWhite, none
    }

    public var lead: String
    public var accent: String
    public var fontSize: CGFloat
    public var accentStyle: AccentStyle
    public var t: Double
    public var inAt: Double
    public var outAt: Double?
    public var wordStagger: Double
    public var wordDuration: Double
    public var outWordDuration: Double
    public var outStagger: Double
    public var blurRadius: CGFloat

    public init(
        lead: String,
        accent: String,
        fontSize: CGFloat,
        accentStyle: AccentStyle = .serifItalicGold,
        t: Double,
        inAt: Double,
        outAt: Double? = nil,
        wordStagger: Double = 0.10,
        wordDuration: Double = 0.20,
        outWordDuration: Double = 0.13,
        outStagger: Double = 0.03,
        blurRadius: CGFloat = 8
    ) {
        self.lead = lead
        self.accent = accent
        self.fontSize = fontSize
        self.accentStyle = accentStyle
        self.t = t
        self.inAt = inAt
        self.outAt = outAt
        self.wordStagger = wordStagger
        self.wordDuration = wordDuration
        self.outWordDuration = outWordDuration
        self.outStagger = outStagger
        self.blurRadius = blurRadius
    }

    private var words: [String] {
        let leadWords = lead.split(separator: " ").map(String.init)
        return accent.isEmpty ? leadWords : leadWords + [accent]
    }

    /// Visibility 0...1 of word `i` at the current time.
    public func visibility(ofWord i: Int) -> Double {
        let start = inAt + wordStagger * Double(i)
        var u = Ease.easeOut((t - start) / wordDuration)
        if let outAt {
            let outStart = outAt + outStagger * Double(i)
            u *= 1 - Ease.easeIn((t - outStart) / outWordDuration)
        }
        return u
    }

    public var body: some View {
        let words = words
        let accentIndex = accent.isEmpty ? -1 : words.count - 1
        let space = Self.spaceWidth(fontSize: fontSize)
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(Array(words.enumerated()), id: \.offset) { i, word in
                let u = visibility(ofWord: i)
                text(word, isAccent: i == accentIndex)
                    .fixedSize()
                    .opacity(u)
                    .blur(radius: blurRadius * (1 - u))
                if i < words.count - 1 {
                    Color.clear.frame(width: space, height: 1)
                }
            }
        }
        .fixedSize()
    }

    private func text(_ word: String, isAccent: Bool) -> Text {
        guard isAccent else {
            return Text(verbatim: word)
                .font(GlowFonts.sans(weight: .light, size: fontSize))
                .foregroundColor(.white)
        }
        switch accentStyle {
        case .serifItalicGold:
            return Text(verbatim: word).font(GlowFonts.serifItalic(size: fontSize)).foregroundColor(GlowTheme.gold)
        case .serifItalicWhite:
            return Text(verbatim: word).font(GlowFonts.serifItalic(size: fontSize)).foregroundColor(.white)
        case .none:
            return Text(verbatim: word).font(GlowFonts.sans(weight: .light, size: fontSize)).foregroundColor(.white)
        }
    }

    static func spaceWidth(fontSize: CGFloat) -> CGFloat {
        GlowFonts.registerIfNeeded()
        let font = CTFontCreateWithName("Outfit-Light" as CFString, fontSize, nil)
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: " ", attributes: [NSAttributedString.Key(kCTFontAttributeName as String): font])
        )
        return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    }
}
