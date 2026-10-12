import CoreText
import SwiftUI

enum WorkflowPalette {
    static let pillLabel = Color(hex: 0xF6F1EC)
    static let iconTop = Color(hex: 0xFFB347)
    static let iconBottom = Color(hex: 0xF0552A)
    static let arrow = Color(hex: 0xEE7040)
    static let curveInk = Color(hex: 0x1F0E00)
    static let curveStart = Color(hex: 0xD8485C)
    static let curveMid = Color(hex: 0xD88A4E)
    static let curveEnd = Color(hex: 0xECAC5A)
    static let pulseCore = Color(hex: 0xFFF6D8)
    static let pulseRing = Color(hex: 0xFF6A2A)
    static let glint = Color(hex: 0xFFD27A)
    static let seed = Color(hex: 0x180D04)
    static let shadow = Color(hex: 0x6A3A22)
    static let litGlow = Color(hex: 0xFF7A30)
    static let halo = Color(hex: 0xF0B08A)
    /// Cream measured down the stage edge at f0480.
    static let creamStops: [Gradient.Stop] = [
        .init(color: Color(hex: 0xF3ECE7), location: 0), .init(color: Color(hex: 0xF5ECE3), location: 0.25),
        .init(color: Color(hex: 0xF4E5D9), location: 0.5), .init(color: Color(hex: 0xF3E2D4), location: 0.78),
        .init(color: Color(hex: 0xF2E3D2), location: 1),
    ]
    static let warmBlob = Color(hex: 0xF4D3B8)
    /// The merged dot on black at f0620, sampled at 0, 4, 6, 8, 10, 14, 20, 30 and 40 px.
    static let finalDot: [(Double, UInt32)] = [
        (0, 0xFFFBF5), (4, 0xFEFEFB), (6, 0xFFEC98), (8, 0xFFC64C), (10, 0xF8B247), (14, 0xBC8539),
        (20, 0x65421D), (30, 0x2A1704), (40, 0x160C01),
    ]
}

/// Warm cream backdrop: a vertical gradient plus the soft peach glow low in the frame.
struct WorkflowBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(stops: WorkflowPalette.creamStops, startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [WorkflowPalette.warmBlob.opacity(0.55), WorkflowPalette.warmBlob.opacity(0)],
                           center: UnitPoint(x: 0.5, y: 1000.0 / 1280), startRadius: 0, endRadius: 330)
        }
        .frame(width: 720, height: 1280)
    }
}

/// One pill: dark (or igniting) capsule with icon and glyph-revealed label, drawn at unscaled size.
struct WorkflowPillView: View {
    let pill: WorkflowPill
    let state: WorkflowModel.PillState
    let frame: Double
    let labelsOut: Double

    var body: some View {
        let w = state.size.width, h = state.size.height
        let full = pill.size
        ZStack {
            Capsule()
                .fill(state.fill)
                .shadow(color: WorkflowPalette.shadow.opacity(0.28 * (1 - state.lit)), radius: 9, y: 6)
                .shadow(color: WorkflowPalette.litGlow.opacity(0.45 * state.lit), radius: 12, y: 3)
                .frame(width: w, height: h)
            if state.halo.opacity > 0 {
                Capsule()
                    .strokeBorder(WorkflowPalette.halo.opacity(state.halo.opacity), lineWidth: 1.5)
                    .padding(state.halo.inset)
                    .frame(width: w, height: h)
            }
            content
                .frame(width: full.width, height: full.height)
                .frame(width: w, height: h)
                .clipShape(Capsule())
        }
        .frame(width: max(w, 1), height: max(h, 1))
    }

    private var content: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            WorkflowIcon(kind: pill.icon)
                .frame(width: 30, height: 30)
                .scaleEffect(0.6 + 0.4 * state.iconReveal)
                .opacity(state.iconReveal)
                .blur(radius: 4 * labelsOut)
                .offset(x: iconCentreX - 15, y: pill.size.height / 2 - 15)
            GlyphBlurReveal(
                runs: [.init(text: pill.label, font: GlowFonts.sans(weight: .light, size: pill.fontSize))],
                color: WorkflowPalette.pillLabel,
                time: frame, start: pill.labelStart, spread: 5, duration: 7, blur: 6,
                opacity: 1 - labelsOut
            )
            .blur(radius: 5 * labelsOut)
            .offset(x: 76, y: pill.size.height / 2 + pill.fontSize * 0.347 - ascent)
        }
    }

    private var iconCentreX: CGFloat {
        switch pill.icon {
        case .moon: 40.5
        case .code: 43.6
        case .arrow: 42.6
        }
    }

    private var ascent: CGFloat {
        GlowFonts.registerIfNeeded()
        return CTFontGetAscent(CTFontCreateWithName("Outfit-Light" as CFString, pill.fontSize, nil))
    }
}

/// The three pill icons: crescent moon with a star, `</>`, and a north-east arrow.
struct WorkflowIcon: View {
    let kind: WorkflowPill.Icon

    var body: some View {
        let gradient = LinearGradient(colors: [WorkflowPalette.iconTop, WorkflowPalette.iconBottom],
                                      startPoint: .topLeading, endPoint: .bottom)
        switch kind {
        case .moon:
            ZStack {
                MoonShape().fill(gradient, style: FillStyle(eoFill: true))
                Circle().fill(WorkflowPalette.iconTop.opacity(0.9))
                    .frame(width: 3.6, height: 3.6)
                    .offset(x: 7.5, y: -7.5)
            }
        case .code:
            CodeGlyph().stroke(gradient, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        case .arrow:
            ArrowGlyph().stroke(WorkflowPalette.arrow, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
        }
    }
}

/// A crescent opening to the upper right, 21 px across in a 30 px box.
struct MoonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width * 0.35
        var p = Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
        let cut = r * 0.72
        let cc = CGPoint(x: c.x + r * 0.55, y: c.y - r * 0.5)
        p.addEllipse(in: CGRect(x: cc.x - cut, y: cc.y - cut, width: 2 * cut, height: 2 * cut))
        return p
    }
}

/// `</>`, 29 px wide and 20 px tall in a 30 px box.
struct CodeGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 30
        let o = CGPoint(x: rect.minX, y: rect.minY)
        func pt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: o.x + x * s, y: o.y + y * s) }
        var p = Path()
        p.move(to: pt(9, 9)); p.addLine(to: pt(3, 15)); p.addLine(to: pt(9, 21))
        p.move(to: pt(21, 9)); p.addLine(to: pt(27, 15)); p.addLine(to: pt(21, 21))
        p.move(to: pt(17, 7)); p.addLine(to: pt(13, 23))
        return p
    }
}

/// ↗, 19 px across in a 30 px box.
struct ArrowGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 30
        let o = CGPoint(x: rect.minX, y: rect.minY)
        func pt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: o.x + x * s, y: o.y + y * s) }
        var p = Path()
        p.move(to: pt(7, 23)); p.addLine(to: pt(22, 8))
        p.move(to: pt(11, 8)); p.addLine(to: pt(22, 8)); p.addLine(to: pt(22, 19))
        return p
    }
}

/// Curves, pen dots, pulses and sparks, drawn in stage coordinates.
struct WorkflowLinks {
    let model: WorkflowModel

    /// Fitted on f0580: each link leaves the bottom of one pill and enters just inside the top of the next.
    static let curve1 = (from: CGPoint(x: 0, y: 48), to: CGPoint(x: 211, y: 268))
    static let curve2 = (from: CGPoint(x: 211, y: 356), to: CGPoint(x: 7, y: 574))

    static func point(_ c: (from: CGPoint, to: CGPoint), _ u: Double) -> CGPoint {
        let dy = c.to.y - c.from.y
        let c1 = CGPoint(x: c.from.x, y: c.from.y + 0.40 * dy)
        let c2 = CGPoint(x: c.to.x, y: c.to.y - 0.45 * dy)
        let v = 1 - u
        let a = v * v * v, b = 3 * v * v * u, d = 3 * v * u * u, e = u * u * u
        return CGPoint(x: a * c.from.x + b * c1.x + d * c2.x + e * c.to.x,
                       y: a * c.from.y + b * c1.y + d * c2.y + e * c.to.y)
    }

    private func path(_ c: (from: CGPoint, to: CGPoint), from u0: Double, to u1: Double) -> Path {
        var p = Path()
        let steps = max(2, Int((u1 - u0) * 80))
        for i in 0...steps {
            let u = u0 + (u1 - u0) * Double(i) / Double(steps)
            let q = model.toStage(Self.point(c, u))
            if i == 0 { p.move(to: q) } else { p.addLine(to: q) }
        }
        return p
    }

    func draw(in context: inout GraphicsContext) {
        let s = model.cameraScale
        drawCurve(Self.curve1, drawn: model.curve1Draw, lit: model.curve1Lit, scale: s, in: &context)
        drawCurve(Self.curve2, drawn: model.curve2Draw, lit: model.curve2Lit, scale: s, in: &context)
        if model.pen1 { drawPen(Self.point(Self.curve1, model.curve1Draw), scale: s, in: &context) }
        if model.pen2 { drawPen(Self.point(Self.curve2, model.curve2Draw), scale: s, in: &context) }
        drawPulse(Self.curve1, model.pulse1, scale: s, in: &context)
        drawPulse(Self.curve2, model.pulse2, scale: s, in: &context)
        if model.glintAlpha > 0 {
            for u in model.glintPositions() {
                drawGlint(model.toStage(Self.point(Self.curve1, u)), scale: s, in: &context)
                drawGlint(model.toStage(Self.point(Self.curve2, u)), scale: s, in: &context)
            }
        }
    }

    private func drawCurve(_ c: (from: CGPoint, to: CGPoint), drawn: Double, lit: Double, scale s: Double,
                           in context: inout GraphicsContext) {
        guard drawn > 0.002 else { return }
        let width = 2.2 * s
        if lit < drawn {
            context.stroke(path(c, from: lit, to: drawn), with: .color(WorkflowPalette.curveInk.opacity(0.9)), lineWidth: width)
        }
        guard lit > 0.002 else { return }
        let litPath = path(c, from: 0, to: lit)
        let a = model.toStage(c.from), b = model.toStage(c.to)
        let shading = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [WorkflowPalette.curveStart, WorkflowPalette.curveMid, WorkflowPalette.curveEnd]), startPoint: a, endPoint: b)
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: 3 * s))
            layer.opacity = 0.4
            layer.stroke(litPath, with: shading, lineWidth: 3 * s)
        }
        context.stroke(litPath, with: shading, lineWidth: width)
    }

    private func drawPen(_ p: CGPoint, scale s: Double, in context: inout GraphicsContext) {
        let q = model.toStage(p)
        let r = 3.5 * s
        context.fill(Path(ellipseIn: CGRect(x: q.x - r, y: q.y - r, width: 2 * r, height: 2 * r)),
                     with: .color(WorkflowPalette.curveInk))
    }

    private func drawPulse(_ c: (from: CGPoint, to: CGPoint), _ pulse: (u: Double, alpha: Double), scale s: Double,
                           in context: inout GraphicsContext) {
        guard pulse.alpha > 0 else { return }
        let q = model.toStage(Self.point(c, pulse.u))
        var layer = context
        layer.opacity = pulse.alpha
        let bloom = 24 * s
        layer.fill(Path(ellipseIn: CGRect(x: q.x - bloom, y: q.y - bloom, width: 2 * bloom, height: 2 * bloom)),
                   with: .radialGradient(Gradient(colors: [WorkflowPalette.litGlow.opacity(0.5), WorkflowPalette.litGlow.opacity(0.22), WorkflowPalette.litGlow.opacity(0)]),
                                         center: q, startRadius: 0, endRadius: bloom))
        let ring = 5.5 * s
        layer.stroke(Path(ellipseIn: CGRect(x: q.x - ring, y: q.y - ring, width: 2 * ring, height: 2 * ring)),
                     with: .color(WorkflowPalette.pulseRing), lineWidth: 1.6 * s)
        let core = 3 * s
        layer.fill(Path(ellipseIn: CGRect(x: q.x - core, y: q.y - core, width: 2 * core, height: 2 * core)),
                   with: .color(WorkflowPalette.pulseCore))
    }

    private func drawGlint(_ q: CGPoint, scale s: Double, in context: inout GraphicsContext) {
        let r = 13 * s
        var layer = context
        layer.opacity = model.glintAlpha
        layer.fill(Path(ellipseIn: CGRect(x: q.x - r, y: q.y - r, width: 2 * r, height: 2 * r)),
                   with: .radialGradient(Gradient(stops: [
                       .init(color: Color.white, location: 0), .init(color: Color.white, location: 0.15),
                       .init(color: WorkflowPalette.glint.opacity(0.55), location: 0.3),
                       .init(color: WorkflowPalette.glint.opacity(0), location: 1),
                   ]), center: q, startRadius: 0, endRadius: r))
    }
}
