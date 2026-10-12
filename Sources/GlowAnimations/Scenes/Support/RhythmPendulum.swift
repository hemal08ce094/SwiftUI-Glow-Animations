import CoreText
import SwiftUI

/// The "Find your rhythm" pendulum wave as laws of the reference frame number (f0317 = scene t 0).
/// Measured on reference/frames30: the dots ride a constant-speed bounce (a triangle wave), not a sine;
/// dot i makes 16 − i half swings every 16 s.
struct RhythmModel {
    static let firstFrame = 317.0
    static let pivot = CGPoint(x: 360, y: 786)
    static let dotCount = 8
    static let baselineHalfWidth = 288.0

    let frame: Double

    init(t: Double) { frame = Self.firstFrame + t * 30 }
    init(frame: Double) { self.frame = frame }

    static func radius(_ i: Int) -> Double { 47 + 33.3 * Double(i) }

    // MARK: Card edge → baseline (f0317–f0334)

    /// Degrees from vertical, counter-clockwise (the top end swings left).
    var lineTilt: Double { 90 * Ease.easeInOut((frame - 318) / 12) }
    var lineLength: Double {
        let u = Ease.clamp01((frame - 318.5) / 12)
        return 220 + 356 * (1 - pow(1 - u, 2.5))
    }
    private static let lineCentreY = MeasuredKeyframes([
        (318, 640), (319, 642), (320, 648), (321, 656), (322, 668), (323, 687), (324, 715),
        (325, 738), (326, 754), (327, 768), (328, 777), (329, 782), (330, 785), (331, 786),
    ])
    var lineCentre: CGPoint { CGPoint(x: 360, y: Self.lineCentreY(frame)) }
    /// 1 while the line is the glowing card edge, 0 once it has settled into the dim baseline.
    var lineHeat: Double { 1 - Ease.progress(frame, 332.2, 333.4) }
    var endpointDots: Double { Ease.progress(frame, 328.5, 330) }

    // MARK: Arcs and dots arriving

    /// Arc i sweeps from its left end over the top, starting two frames before its dot appears.
    func arcSweep(_ i: Int) -> Double {
        let u = Ease.clamp01((frame - (331.8 + 1.5 * Double(i))) / 15)
        return 180 * (1 - pow(1 - u, 2.5))
    }

    func dotAppear(_ i: Int) -> Double {
        Ease.progress(frame, 333 + 1.45 * Double(i), 334.5 + 1.45 * Double(i))
    }

    // MARK: Pendulum

    static let swingStart = 353.5
    static func halfPeriod(_ i: Int) -> Double { 480 / Double(16 - i) }

    /// Half swings completed by dot i (0 before the release).
    func swings(_ i: Int) -> Double { max(0, frame - Self.swingStart) / Self.halfPeriod(i) }

    /// Angle in degrees from +x: 180 at the left end, 0 at the right end.
    func angle(_ i: Int) -> Double {
        let m = swings(i).truncatingRemainder(dividingBy: 2)
        return m < 1 ? 180 * (1 - m) : 180 * (m - 1)
    }

    /// Frames since dot i last touched an end of its arc; nil before the release.
    func sinceBounce(_ i: Int) -> Double? {
        guard frame >= Self.swingStart else { return nil }
        let s = swings(i)
        return (s - s.rounded(.down)) * Self.halfPeriod(i)
    }

    /// The last bounce end (+1 right, −1 left) and frames since it, for bounces after the release.
    func lastBounce(_ i: Int) -> (side: Double, frames: Double)? {
        let s = swings(i)
        guard s >= 1 else { return nil }
        let n = s.rounded(.down)
        let side: Double = n.truncatingRemainder(dividingBy: 2) == 1 ? 1 : -1
        return (side, (s - n) * Self.halfPeriod(i))
    }

    private static let flash = MeasuredKeyframes([
        (0, 1), (4, 0.85), (9, 0.72), (17, 0.38), (27, 0.15), (40, 0.05), (50, 0),
    ])

    /// Arc brightness 0...1: faint while drawing, a flash at every end touch that decays over ~1.5 s.
    func arcIntensity(_ i: Int) -> Double {
        guard let since = sinceBounce(i) else { return 0.2 }
        return 0.12 + 0.88 * Self.flash(since)
    }

    // MARK: Collapse and the final dot

    /// Scale of the whole figure about the pivot while it collapses into one point.
    var collapse: Double { 1 - pow(Ease.progress(frame, 456.2, 462), 2) }
    var mergedDot: Double { Ease.progress(frame, 460.8, 462) }
    private static let finalDotY = MeasuredKeyframes([
        (462, 786), (463, 718), (464, 669), (465, 641), (466.5, 630), (469, 639.5), (470, 640),
    ])
    var finalDotCentre: CGPoint { CGPoint(x: 360, y: Self.finalDotY(frame)) }
}

enum RhythmPalette {
    /// Arc colours, inner → outer.
    static let arcs: [UInt32] = [0xF0E0A0, 0xF7D060, 0xF0B040, 0xEE9A3C, 0xEA7A3A, 0xE6603F, 0xE24A50, 0xE03868]
    /// Radial profile of each dot sampled below it at f0352, 0, 3, 5, 7, 9, 12, 16 and 22 px from its centre.
    /// Overlapping halos combine with `.screen`, which reproduces the reference between neighbours.
    static let dotProfiles: [[UInt32]] = [
        [0xFCFFF5, 0xFBFDFD, 0xFDFBFF, 0xFFF0DB, 0xD8C086, 0xB69667, 0x715F3D, 0x34271B],
        [0xFFFBF5, 0xFFFCE4, 0xF5FFD2, 0xFFF2A3, 0xE1B864, 0xBC9346, 0x7C5E31, 0x3B2B16],
        [0xF3FAF6, 0xFDF7C9, 0xFEF58A, 0xF9EF72, 0xDEA83E, 0xB97F2D, 0x7B5628, 0x3D2812],
        [0xFBFAE8, 0xFDFAB2, 0xFFFD6A, 0xF9D147, 0xDC921D, 0xB46E1F, 0x7B4A1D, 0x3B200B],
        [0xFDF8F5, 0xFCF9AB, 0xF8FC57, 0xEDBD42, 0xE37816, 0xB85C1D, 0x783918, 0x3E1B08],
        [0xF9FFFF, 0xF3E5BD, 0xEBB768, 0xFB9248, 0xE0531B, 0xB2452A, 0x712B19, 0x3A1608],
        [0xFFFFFF, 0xFDD9D4, 0xE39974, 0xFC684C, 0xE74939, 0xBC3631, 0x782622, 0x37130C],
        [0xFEFCFF, 0xF2C6DC, 0xF08C9F, 0xFC657A, 0xD23A4B, 0xAA2E46, 0x681C20, 0x2F0D0C],
    ]
    /// The sampled radii are tightened by 20 %: summed with neighbours they otherwise read as a wider haze.
    static let profileRadii: [Double] = [0, 3, 5, 7, 9, 12, 16, 22].map { $0 * 0.8 }
    static let dotRadius = 24.0
    static let lineCore = Color(hex: 0xFFF3D3)
    static let lineGlow = Color(hex: 0xC8843C)
    static let baseline = Color(hex: 0x8A7E70)
    static let endpoint = Color(hex: 0xFFFBE0)
    /// The merged dot at f0468, sampled at 0, 8, 10, 13, 16, 20, 25, 30 and 40 px.
    static let finalDot: [(Double, UInt32)] = [
        (0, 0xFFFFFF), (8, 0xFFFEF7), (10, 0xFBE16C), (13, 0xFCC54D), (16, 0xE3A53B),
        (20, 0xA06E23), (25, 0x593716), (30, 0x382109), (40, 0x1C0F02),
    ]

    static func dotGradient(_ i: Int) -> Gradient {
        let profile = dotProfiles[i]
        var stops = zip(profileRadii, profile).map { r, hex in
            Gradient.Stop(color: Color(hex: hex), location: r / dotRadius)
        }
        stops.append(.init(color: Color(hex: profile[profile.count - 1], opacity: 0), location: 1))
        return Gradient(stops: stops)
    }

    static var finalDotGradient: Gradient {
        var stops = finalDot.map { r, hex in Gradient.Stop(color: Color(hex: hex), location: r / 50) }
        stops.append(.init(color: Color(hex: 0x1C0F02, opacity: 0), location: 1))
        return Gradient(stops: stops)
    }
}

/// Draws the whole pendulum figure for one instant into a Canvas context (720 x 1280 design units).
struct RhythmRenderer {
    let model: RhythmModel

    func draw(in context: inout GraphicsContext) {
        context.blendMode = .plusLighter
        if model.frame < 334 {
            drawLineWithMotionBlur(in: &context)
        }
        if model.frame >= 328.5, model.frame < 462 {
            drawBaseline(in: &context)
        }
        if model.frame >= 331.8, model.frame < 462 {
            drawArcs(in: &context)
            drawRipples(in: &context)
            drawDots(in: &context)
        }
        if model.frame >= 460.8 {
            drawFinalDot(in: &context)
        }
    }

    // MARK: Line

    private func drawLineWithMotionBlur(in context: inout GraphicsContext) {
        let speed = abs(RhythmModel(frame: model.frame + 0.5).lineTilt - RhythmModel(frame: model.frame - 0.5).lineTilt)
        let samples = speed > 4 ? 8 : 1
        for k in 0..<samples {
            let offset = samples == 1 ? 0 : 0.2 * (Double(k) / Double(samples - 1) - 0.5)
            drawLine(RhythmModel(frame: model.frame + offset), weight: 1 / Double(samples), in: &context)
        }
    }

    private func drawLine(_ m: RhythmModel, weight: Double, in context: inout GraphicsContext) {
        let tilt = m.lineTilt * .pi / 180
        let half = m.lineLength / 2
        let dir = CGPoint(x: -sin(tilt), y: -cos(tilt))
        let c = m.lineCentre
        var path = Path()
        path.move(to: CGPoint(x: c.x + dir.x * half, y: c.y + dir.y * half))
        path.addLine(to: CGPoint(x: c.x - dir.x * half, y: c.y - dir.y * half))

        let heat = m.lineHeat * weight
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: 26))
            layer.stroke(path, with: .color(RhythmPalette.lineGlow.opacity(0.22 * heat)), lineWidth: 30)
        }
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: 4))
            layer.stroke(path, with: .color(RhythmPalette.lineGlow.opacity(0.55 * heat)), lineWidth: 6)
        }
        context.stroke(path, with: .color(RhythmPalette.lineCore.opacity(heat)), lineWidth: 1.6)
    }

    // MARK: Baseline

    private func drawBaseline(in context: inout GraphicsContext) {
        let s = model.collapse
        let half = RhythmModel.baselineHalfWidth * s
        let p = RhythmModel.pivot
        var path = Path()
        path.move(to: CGPoint(x: p.x - half, y: p.y))
        path.addLine(to: CGPoint(x: p.x + half, y: p.y))
        let warm = model.frame >= RhythmModel.swingStart ? 1.0 : 0.75
        context.stroke(path, with: .color(RhythmPalette.baseline.opacity((1 - model.lineHeat) * warm)), lineWidth: 1.2)

        let dots = model.endpointDots * s
        guard dots > 0 else { return }
        for x in [p.x - half - 2, p.x + half + 2] {
            let r = 3.0
            context.fill(Path(ellipseIn: CGRect(x: x - r, y: p.y - r, width: 2 * r, height: 2 * r)),
                         with: .color(RhythmPalette.endpoint.opacity(dots)))
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: 4))
                layer.fill(Path(ellipseIn: CGRect(x: x - 6, y: p.y - 6, width: 12, height: 12)),
                           with: .color(RhythmPalette.lineGlow.opacity(0.45 * dots)))
            }
        }
    }

    // MARK: Arcs

    private func arcPath(_ i: Int, sweep: Double) -> Path {
        let r = RhythmModel.radius(i) * model.collapse
        var path = Path()
        path.addArc(center: RhythmModel.pivot, radius: r,
                    startAngle: .degrees(180), endAngle: .degrees(180 + sweep), clockwise: false)
        return path
    }

    private func drawArcs(in context: inout GraphicsContext) {
        let fade = model.collapse
        for i in 0..<RhythmModel.dotCount {
            let sweep = model.arcSweep(i)
            guard sweep > 0.5 else { continue }
            let path = arcPath(i, sweep: sweep)
            let color = Color(hex: RhythmPalette.arcs[i])
            let a = model.arcIntensity(i) * fade
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: 3))
                layer.stroke(path, with: .color(color.opacity(0.4 * a)), lineWidth: 3)
            }
            context.stroke(path, with: .color(color.opacity(a)), lineWidth: 1.5)
        }
    }

    // MARK: Ripples

    private func drawRipples(in context: inout GraphicsContext) {
        let s = model.collapse
        for i in 0..<RhythmModel.dotCount {
            guard let bounce = model.lastBounce(i), bounce.frames < 16 else { continue }
            let u = bounce.frames
            let halfWidth = (4 + 18 * Ease.easeOut(u / 12)) * s
            let halfHeight = 0.27 * halfWidth
            let x = RhythmModel.pivot.x + bounce.side * RhythmModel.radius(i) * s
            let rect = CGRect(x: x - halfWidth, y: RhythmModel.pivot.y - halfHeight, width: 2 * halfWidth, height: 2 * halfHeight)
            let color = Color(hex: RhythmPalette.dotProfiles[i][3])
            context.stroke(Path(ellipseIn: rect), with: .color(color.opacity(0.8 * (1 - u / 16))), lineWidth: 1.5)
        }
    }

    // MARK: Dots

    private func drawDots(in context: inout GraphicsContext) {
        let s = model.collapse
        let fade = 1 - model.mergedDot
        for i in 0..<RhythmModel.dotCount {
            let appear = model.dotAppear(i) * fade
            guard appear > 0 else { continue }
            let theta = model.angle(i) * .pi / 180
            let r = RhythmModel.radius(i) * s
            let c = CGPoint(x: RhythmModel.pivot.x + r * cos(theta), y: RhythmModel.pivot.y - r * sin(theta))
            let R = RhythmPalette.dotRadius
            var dot = context
            dot.blendMode = .screen
            dot.opacity = appear
            dot.fill(Path(ellipseIn: CGRect(x: c.x - R, y: c.y - R, width: 2 * R, height: 2 * R)),
                     with: .radialGradient(RhythmPalette.dotGradient(i), center: c, startRadius: 0, endRadius: R))
        }
    }

    private func drawFinalDot(in context: inout GraphicsContext) {
        let c = model.frame < 462 ? RhythmModel.pivot : model.finalDotCentre
        let R = 50.0
        var dot = context
        dot.opacity = model.mergedDot
        dot.fill(Path(ellipseIn: CGRect(x: c.x - R, y: c.y - R, width: 2 * R, height: 2 * R)),
                 with: .radialGradient(RhythmPalette.finalDotGradient, center: c, startRadius: 0, endRadius: R))
    }
}

/// "Find your *rhythm*": wipes in left to right with a soft blurred edge and wipes out the same way.
struct RhythmCaption: View {
    let frame: Double

    static let baselineY: CGFloat = 891
    static let originX: CGFloat = 207.4
    static let leadSize: CGFloat = 40.6
    static let accentSize: CGFloat = 46
    static let accentGap: CGFloat = 11.5

    var body: some View {
        let reveal = Ease.progress(frame, 362.5, 379)
        let leave = Ease.progress(frame, 454, 461.5)
        let line = HStack(alignment: .firstTextBaseline, spacing: Self.accentGap) {
            Text(verbatim: "Find your")
                .font(GlowFonts.sans(weight: .light, size: Self.leadSize))
                .foregroundStyle(Color.white)
            Text(verbatim: "rhythm")
                .font(GlowFonts.serifItalic(size: Self.accentSize))
                .foregroundStyle(LinearGradient(colors: [Color(hex: 0xD9965E), Color(hex: 0xE9B37A), Color(hex: 0xF0CD9A)],
                                                startPoint: .leading, endPoint: .trailing))
        }
        .fixedSize()
        ZStack(alignment: .topLeading) {
            Color.clear
            Group {
                if leave > 0 {
                    line.blurWipe(progress: 1 - leave, edgeWidth: 70, blur: 8, reversed: true)
                } else {
                    line.blurWipe(progress: reveal, edgeWidth: 70, blur: 8)
                }
            }
            .offset(x: Self.originX, y: Self.baselineY - Self.ascent)
        }
        .frame(width: 720, height: 1280)
    }

    private static let ascent: CGFloat = {
        GlowFonts.registerIfNeeded()
        let lead = CTFontGetAscent(CTFontCreateWithName("Outfit-Light" as CFString, leadSize, nil))
        let accent = CTFontGetAscent(CTFontCreateWithName("InstrumentSerif-Italic" as CFString, accentSize, nil))
        return max(lead, accent)
    }()
}
