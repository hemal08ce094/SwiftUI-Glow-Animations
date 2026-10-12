import SwiftUI

/// Text whose glyphs blur in one after another, left to right. Glyph i starts at
/// `start + spread · i / n` and resolves over `duration` (all in the caller's time unit):
/// a blurred ghost fades in first, then the sharp glyph takes over. Kerning is kept because
/// the line stays one concatenated `Text`.
struct GlyphBlurReveal: View {
    struct Run {
        var text: String
        var font: Font
        var tracking: CGFloat = 0
    }

    var runs: [Run]
    var color: Color
    var time: Double
    var start: Double
    var spread: Double
    var duration: Double
    var blur: CGFloat = 8
    /// 1 = fully shown; scales both layers so the label can also fade out as a whole.
    var opacity: Double = 1

    var body: some View {
        ZStack {
            line { u in Ease.smoothstep((u - 0.3) / 0.7) }
            line { u in min(1, 2.5 * u) * (1 - Ease.smoothstep((u - 0.4) / 0.6)) }
                .blur(radius: blur)
        }
        .fixedSize()
    }

    /// Visibility 0...1 of glyph `i` of `count`.
    func progress(glyph i: Int, of count: Int) -> Double {
        let begin = start + spread * Double(i) / Double(max(1, count - 1))
        return Ease.easeOut((time - begin) / duration)
    }

    private func line(alpha: (Double) -> Double) -> some View {
        let count = runs.reduce(0) { $0 + $1.text.count }
        var index = 0
        var text = Text(verbatim: "")
        for run in runs {
            for character in run.text {
                let a = alpha(progress(glyph: index, of: count)) * opacity
                text = text + Text(verbatim: String(character))
                    .font(run.font)
                    .tracking(run.tracking)
                    .foregroundColor(color.opacity(a))
                index += 1
            }
        }
        return text.lineLimit(1).fixedSize()
    }
}
