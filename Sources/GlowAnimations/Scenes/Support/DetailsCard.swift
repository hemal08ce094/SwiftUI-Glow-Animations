import CoreText
import QuartzCore
import SwiftUI

/// Every value of the "Details" card at one instant, as laws of the reference frame number
/// (f0246 = scene t 0). Keyframe tables are measured on reference/frames30.
struct DetailsCardState {
    static let firstFrame = 246.0
    static let finalSize = CGSize(width: 601, height: 222)
    static let pillHeight = 38.0
    static let maxCornerRadius = 30.0
    static let perspectiveDistance = 1600.0

    let frame: Double

    init(t: Double) { frame = Self.firstFrame + t * 30 }
    init(frame: Double) { self.frame = frame }

    // MARK: Pill → card

    /// The pill keeps easing out to 368 px wide while the card growth starts.
    private var pillWidth: Double { 368 - 66 * exp(-0.755 * max(0, frame - Self.firstFrame)) }

    /// 0 = pill, 1 = settled card; overshoots to 1.035 at f0265.
    private static let growth = MeasuredKeyframes([
        (251, 0), (252, 0.076), (253, 0.185), (254, 0.315), (255, 0.446), (256, 0.576), (257, 0.69),
        (258, 0.783), (259, 0.859), (260, 0.924), (261, 0.967), (262, 1.0), (263, 1.013), (264, 1.025),
        (265, 1.033), (266, 1.035), (269, 1.028), (274, 1.012), (280, 1.0),
    ])

    var growth: Double { Self.growth(frame) }

    var size: CGSize {
        let g = growth
        let w = pillWidth + (Self.finalSize.width - 368) * g
        let h = Self.pillHeight + (Self.finalSize.height - Self.pillHeight) * g
        return CGSize(width: w, height: h)
    }

    var cornerRadius: Double { min(size.height / 2, Self.maxCornerRadius) }

    /// Weight of the redder bottom-row gradient; a thin pill reads as the top row only.
    var bottomTint: Double { Ease.clamp01(growth) }

    // MARK: Pose (fitted per frame: yaw about the vertical axis, D = 1600, then screen roll and offset)

    private static let yawKeys = MeasuredKeyframes([
        (266, 0), (268, 1.8), (270, 6.0), (272, 10.5), (274, 14.8), (276, 18.0), (279, 19.9), (282, 17.9),
        (284, 14.2), (286, 9.6), (288, 3.6), (290, -4.8), (292, -10.0), (294, -13.6), (297, -16.1),
        (300, -12.8), (302, -9.6), (304.5, -7.3), (306, -8.3), (308, -10.8), (310, -17.5), (311, -22.7),
        (312, -30.2), (313, -41), (314, -54), (315, -69), (316, -87), (317, -90),
    ])
    private static let dxKeys = MeasuredKeyframes([
        (266, 0), (270, 2.4), (274, 4.4), (279, 6.2), (283, 4.6), (286, 1.5), (288, -0.8), (290, -0.8),
        (293, -3.4), (297, -4.9), (300, -3.9), (303, -2.4), (306, -2.5), (308, -3.9), (310, -5.8),
        (311, -8.8), (312, -10.7), (313, -12), (314, -14), (316, -12), (317, 0),
    ])
    private static let dyKeys = MeasuredKeyframes([
        (264, -0.5), (266, -0.3), (270, 0.8), (274, 2.8), (277, 3.8), (283, 4.2), (288, 4.0), (291, 3.5),
        (295, 2.6), (299, 1.5), (302, 0.5), (305, -0.5), (308, -1.8), (311, -2.8), (313, -3.1), (316, -3.4),
    ])

    /// Degrees; positive brings the right edge toward the viewer.
    var yaw: Double { Self.yawKeys(frame) }
    /// Degrees; the near side dips while the card first rocks, then the roll fades out.
    var roll: Double { 0.05 * yaw * (1 - Ease.progress(frame, 300, 303)) }
    var center: CGPoint { CGPoint(x: 360 + Self.dxKeys(frame), y: 640 + Self.dyKeys(frame)) }

    /// The side turned away from the viewer darkens linearly toward its edge (≈ 1 % per degree).
    var farShade: Double { min(0.85, 0.0105 * abs(yaw)) }

    /// `depth` moves the layer off the card plane (positive = toward the viewer); a layer lifted forward
    /// parallaxes toward the far edge as the card turns.
    func projection(pivot: CGPoint, depth: Double = 0) -> ProjectionTransform {
        var perspective = CATransform3DIdentity
        perspective.m34 = -1 / Self.perspectiveDistance
        var m = CATransform3DMakeTranslation(-pivot.x, -pivot.y, depth)
        m = CATransform3DConcat(m, CATransform3DMakeRotation(-yaw * .pi / 180, 0, 1, 0))
        m = CATransform3DConcat(m, perspective)
        m = CATransform3DConcat(m, CATransform3DMakeRotation(roll * .pi / 180, 0, 0, 1))
        m = CATransform3DConcat(m, CATransform3DMakeTranslation(pivot.x, pivot.y, 0))
        return ProjectionTransform(m)
    }

    // MARK: Light

    var glow: Double { Ease.progress(frame, 251, 260) }
    /// The far edge's red rim flares as the card turns edge-on.
    var rimFlare: Double { Ease.progress(abs(yaw), 22, 70) }
    var reflection: Double { Ease.progress(frame, 257, 264) }

    /// Sheen band centre on the card's middle row, card-local x (0 = card centre).
    private static let sheenKeys = MeasuredKeyframes([
        (283.4, -420), (285, -296), (286, -205), (287, -81), (288, 67), (289, 186), (290, 280), (291.6, 420),
    ])
    var sheenX: Double { Self.sheenKeys(frame) }
    var sheenVisible: Bool { frame > 283.4 && frame < 291.6 }

    // MARK: Content reveal

    var asteriskScale: Double { 0.3 + 0.7 * Ease.easeOut(Ease.progress(frame, 260.5, 265.5)) }
    var asteriskOpacity: Double { Ease.progress(frame, 261, 264.5) }
    /// Glyph reveals in frames: (first glyph start, last glyph start offset, per-glyph duration).
    static let titleReveal = (start: 262.5, spread: 4.5, duration: 10.0)
    static let subtitleReveal = (start: 268.5, spread: 8.0, duration: 10.0)
}

/// Colours sampled across the settled card at f0265: top row (y 545) and bottom row (y 735).
enum DetailsPalette {
    static let topRow: [UInt32] = [
        0xFC7485, 0xFB7C7E, 0xFC7F7A, 0xFF7E6E, 0xFB7A5F, 0xFA7C52,
        0xF57C49, 0xF37F3C, 0xF08432, 0xEF8529, 0xEF8829, 0xEE8B2A,
    ]
    static let bottomRow: [UInt32] = [
        0xFA5F5F, 0xFA6254, 0xFC654D, 0xFB6F46, 0xF67541, 0xF27A3A,
        0xEB7F2B, 0xEA8029, 0xE57F27, 0xE27D25, 0xDF812A, 0xDD852A,
    ]
    static let glow = Color(hex: 0xFF4A28)
    static let rim = Color(hex: 0xFF2A1A)
    static let sheen = Color(hex: 0xFFC882)

    static func gradient(_ row: [UInt32]) -> LinearGradient {
        let stops = row.enumerated().map { i, hex in
            Gradient.Stop(color: Color(hex: hex), location: 0.033 + 0.0833 * Double(i))
        }
        return LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing)
    }
}

/// The card's front face (fill, shading, sheen, rim, asterisk and text), unprojected.
struct DetailsCardFace: View {
    let state: DetailsCardState

    private static let titleSize: CGFloat = 49
    private static let titleTracking: CGFloat = 1.2
    private static let subtitleSize: CGFloat = 32
    private static let accentSize: CGFloat = 35

    var body: some View {
        let size = state.size
        let shape = RoundedRectangle(cornerRadius: state.cornerRadius, style: .circular)
        ZStack {
            shape.fill(DetailsPalette.gradient(DetailsPalette.topRow))
            shape.fill(DetailsPalette.gradient(DetailsPalette.bottomRow))
                .mask(LinearGradient(stops: [.init(color: .clear, location: 0.085), .init(color: .black, location: 0.92)],
                                     startPoint: .top, endPoint: .bottom))
                .opacity(state.bottomTint)
            farShade
            if state.sheenVisible { sheen(height: size.height) }
            content(in: size)
            shape.strokeBorder(Color.white.opacity(0.28), lineWidth: 1.5)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(shape)
    }

    private var farShade: some View {
        let farIsLeft = state.yaw > 0
        return LinearGradient(colors: [Color.black.opacity(state.farShade), .clear],
                              startPoint: farIsLeft ? .leading : .trailing,
                              endPoint: farIsLeft ? .trailing : .leading)
    }

    /// A "/" band of warm light, Gaussian across (σ ≈ 48 px), added on top of the fill.
    private func sheen(height: CGFloat) -> some View {
        let sigma = 48.0
        let half = 3 * sigma
        let stops = stride(from: -half, through: half, by: sigma / 2).map { x in
            Gradient.Stop(color: DetailsPalette.sheen.opacity(0.42 * exp(-x * x / (2 * sigma * sigma))),
                          location: (x + half) / (2 * half))
        }
        return Rectangle()
            .fill(LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing))
            .frame(width: 2 * half, height: height * 3)
            .rotationEffect(.degrees(28))
            .offset(x: state.sheenX)
            .blendMode(.plusLighter)
    }

    private func content(in size: CGSize) -> some View {
        let cx = size.width / 2, cy = size.height / 2
        return ZStack(alignment: .topLeading) {
            Color.clear
            DetailsAsterisk()
                .fill(Color.white)
                .frame(width: 56, height: 56)
                .scaleEffect(state.asteriskScale)
                .opacity(state.asteriskOpacity)
                .blur(radius: 3 * (1 - state.asteriskOpacity))
                .offset(x: cx - 222 - 28, y: cy - 28)
            title
                .offset(x: cx - 168, y: cy - 1 - Self.ascent("Outfit-Regular", Self.titleSize))
            subtitle
                .offset(x: cx - 167, y: cy + 39.5 - max(Self.ascent("Outfit-Light", Self.subtitleSize),
                                                         Self.ascent("InstrumentSerif-Italic", Self.accentSize)))
        }
        .frame(width: size.width, height: size.height)
    }

    private var title: some View {
        let reveal = DetailsCardState.titleReveal
        return GlyphBlurReveal(
            runs: [.init(text: "Details", font: GlowFonts.sans(weight: .regular, size: Self.titleSize),
                         tracking: Self.titleTracking)],
            color: Color.white.opacity(0.97),
            time: state.frame, start: reveal.start, spread: reveal.spread, duration: reveal.duration, blur: 7
        )
    }

    private var subtitle: some View {
        let reveal = DetailsCardState.subtitleReveal
        return GlyphBlurReveal(
            runs: [
                .init(text: "make it ", font: GlowFonts.sans(weight: .light, size: Self.subtitleSize)),
                .init(text: "real", font: GlowFonts.serifItalic(size: Self.accentSize)),
            ],
            color: Color.white.opacity(0.72),
            time: state.frame, start: reveal.start, spread: reveal.spread, duration: reveal.duration, blur: 6
        )
    }

    private static func ascent(_ postScriptName: String, _ size: CGFloat) -> CGFloat {
        GlowFonts.registerIfNeeded()
        return CTFontGetAscent(CTFontCreateWithName(postScriptName as CFString, size, nil))
    }
}

/// Six rounded petals, 25 px from centre to tip at a 56 px frame, rotated so one petal points 10° below +x.
struct DetailsAsterisk: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.width / 56
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let petal = CGRect(x: 1.5 * scale, y: -4.4 * scale, width: 23.5 * scale, height: 8.8 * scale)
        var path = Path(ellipseIn: CGRect(x: center.x - 5 * scale, y: center.y - 5 * scale,
                                          width: 10 * scale, height: 10 * scale))
        for k in 0..<6 {
            let degrees = -10.0 + 60.0 * Double(k)
            let transform = CGAffineTransform(rotationAngle: -degrees * .pi / 180)
                .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
            path.addPath(Path(ellipseIn: petal), transform: transform)
        }
        return path
    }
}

/// Glow, face and floor reflection of the card at one instant, projected with its pose.
struct DetailsCardLayer: View {
    let state: DetailsCardState

    private static let reflectionGap: CGFloat = 12

    var body: some View {
        let c = state.center
        let size = state.size
        let shape = RoundedRectangle(cornerRadius: state.cornerRadius, style: .circular)
        ZStack {
            ZStack {
                glow(shape: shape, size: size)
                    .scaleEffect((DetailsCardState.perspectiveDistance - glowDepth) / DetailsCardState.perspectiveDistance)
                    .position(c)
            }
            .frame(width: 720, height: 1280)
            .projectionEffect(state.projection(pivot: c, depth: glowDepth))
            cardAndReflection(size: size, center: c)
        }
    }

    /// The reference glow hugs the far edge when the card turns, as if lifted in front of the card
    /// while still composited beneath it; near edge-on it closes back onto the edge.
    private var glowDepth: Double { 55 * (1 - Ease.progress(abs(state.yaw), 45, 90)) }

    private func cardAndReflection(size: CGSize, center c: CGPoint) -> some View {
        ZStack {
            if state.reflection > 0 {
                DetailsCardFace(state: state)
                    .scaleEffect(x: 1, y: -1)
                    .mask(LinearGradient(stops: [
                        .init(color: .black.opacity(0.22), location: 0),
                        .init(color: .black.opacity(0.12), location: 0.18),
                        .init(color: .black.opacity(0.05), location: 0.42),
                        .init(color: .black.opacity(0.012), location: 0.75),
                        .init(color: .clear, location: 1),
                    ], startPoint: .top, endPoint: .bottom))
                    .blur(radius: 3)
                    .opacity(state.reflection)
                    .position(x: c.x, y: c.y + size.height + Self.reflectionGap)
            }
            DetailsCardFace(state: state).position(c)
        }
        .frame(width: 720, height: 1280)
        .projectionEffect(state.projection(pivot: c))
    }

    private func glow(shape: RoundedRectangle, size: CGSize) -> some View {
        ZStack {
            shape.fill(DetailsPalette.glow).blur(radius: 80).opacity(0.26)
            shape.fill(DetailsPalette.glow).blur(radius: 22).opacity(0.32)
            shape.fill(DetailsPalette.glow).blur(radius: 8).opacity(0.45)
            shape.fill(DetailsPalette.rim).blur(radius: 6).opacity(0.3 * state.rimFlare)
        }
        .frame(width: size.width, height: size.height)
        .opacity(state.glow)
        .blendMode(.plusLighter)
    }
}
