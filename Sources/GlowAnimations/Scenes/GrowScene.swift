import SwiftUI

/// Scene 2, "Let it *grow*": the dot launches a ring and six nodes, the ring blooms into a
/// six-petal flower that spins down into a solid asterisk.
/// Spec: docs/storyboard/02-grow.md. Tracks are keyed by reference reel frame (f0105 = t 0).
public struct GrowScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    /// The stage's scene durations are rounded to 1 ms, so the reel can ask for one frame past
    /// this scene's last reference frame; that frame belongs to scene 3.
    public var body: some View {
        if GrowGeometry.startFrame + 30 * t >= 190.5 {
            ShapeScene(t: t - 86.0 / 30)
        } else {
            content
        }
    }

    private var content: some View {
        ZStack {
            Canvas(rendersAsynchronously: false) { context, _ in
                GrowPainter(frame: GrowGeometry.startFrame + 30 * t).paint(context)
            }
            .frame(width: 720, height: 1280)

            TimedCaption(
                lead: "Let it",
                accent: "grow",
                fontSize: 44,
                baselineY: 656,
                frame: GrowGeometry.startFrame + 30 * t,
                timings: [
                    CaptionWordTiming(inFrame: 113.5, inFrames: 11, outFrame: 165.5, outFrames: 7),
                    CaptionWordTiming(inFrame: 117, inFrames: 11, outFrame: 167, outFrames: 7),
                    CaptionWordTiming(inFrame: 119.5, inFrames: 15, outFrame: 168.5, outFrames: 7),
                ]
            )
            .blendMode(.plusLighter)
        }
        .frame(width: 720, height: 1280)
    }
}

/// Geometry shared by scenes 1–3, expressed in reference reel frames.
enum GrowGeometry {
    static let startFrame = 105.0
    static let center = CGPoint(x: 360, y: 640)

    static let ringRadius = FrameTrack(origin: 0, [
        (103.5, 0), (104, 15), (105, 33), (106, 53.3), (107, 74.5), (108, 94.7), (109, 112.9),
        (110, 129.3), (111, 143.3), (112, 154.4), (113, 162.9), (114, 169), (115, 173.3),
        (116, 175.6), (117, 176.5), (118, 176.7), (120, 174.3), (122, 171), (124, 167.5),
        (126, 165), (128, 163.1), (130, 161.9), (135, 161.5), (140, 162), (145, 162.9), (150, 164),
    ])

    static let tipRadius = FrameTrack(origin: 0, [
        (150, 164), (152, 168), (154, 173), (156, 180), (158, 189), (160, 194), (162, 198),
        (164, 200), (166, 202), (168, 202), (170, 210), (172, 211.5), (173, 210), (174, 202),
        (175, 200), (176, 198), (177, 192), (178, 180), (179, 160), (180, 132), (181, 96),
        (182, 68), (183, 48), (184, 38), (185, 32), (186, 29.6), (188, 29.3),
    ])

    static let valleyRadius = FrameTrack(origin: 0, [
        (150, 164), (152, 164), (154, 166), (156, 167), (158, 167), (160, 166), (162, 163),
        (164, 162), (166, 161), (168, 161), (170, 169), (172, 171), (173, 168), (174, 163),
        (175, 161), (176, 158), (177, 150), (178, 134), (179, 110), (180, 80), (181, 48),
        (182, 28), (183, 18), (184, 12), (185, 9.5), (186, 8.5),
    ])

    /// Petal sharpness: 1 gives round lobes with cusped valleys, higher narrows the petals.
    static let petalExponent = FrameTrack(origin: 0, [(176, 1.0), (180, 1.8), (184, 2.0), (186, 2.2)])

    /// Extra spin of the collapsing flower on top of the node phase (degrees), f0171–f0185.
    static let collapseSpin = FrameTrack(origin: 0, [
        (171, 0), (172, 2.75), (173, 10), (174, 15.25), (175, 28.5), (176, 41.75), (177, 59),
        (178, 82.25), (179, 101.5), (180, 118.75), (181, 130), (182, 139.25), (183, 146.5),
        (184, 147.75), (185, 149),
    ])

    /// Absolute tip angle of the finished asterisk from f0185 on (six-fold phase of the reference).
    static let asteriskAngle = FrameTrack(origin: 0, [
        (185, 124), (186, 127.4), (188, 129.4), (190, 131.4), (200, 142.2), (204, 146.5),
        (208, 150.7), (212, 153.8), (216, 156.5), (220, 158.7), (224, 161), (228, 163.2),
        (232, 165.6), (236, 168.5), (239, 173.3), (244, 182),
    ])

    /// Node phase φ: node k sits at φ + 60k (screen degrees, clockwise from +x).
    static func nodePhase(frame n: Double) -> Double {
        -85 + 0.75 * (n - startFrame)
    }

    /// Angle of petal tip 0, which the nodes ride.
    static func petalAngle(frame n: Double) -> Double {
        n < 185 ? nodePhase(frame: n) + collapseSpin.value(frame: n) : asteriskAngle.value(frame: n)
    }

    /// Centre of the hot (pink) segment of the ring gradient.
    static let hotAngle = FrameTrack(origin: 0, [
        (103, 172), (105, 192), (112, 261), (116, 312), (120, 332), (125, 387), (130, 438),
        (136, 492), (140, 512), (145, 532), (150, 572), (155, 639), (160, 718), (165, 780),
        (176, 888), (190, 1025),
    ])

    static func outlineRadius(frame n: Double, angle: Double) -> Double {
        if n <= 150 { return ringRadius.value(frame: n) }
        let tip = tipRadius.value(frame: n)
        let valley = valleyRadius.value(frame: n)
        let q = petalExponent.value(frame: n)
        let rel = (angle - petalAngle(frame: n)) * .pi / 180
        return valley + (tip - valley) * pow(abs(cos(3 * rel)), q)
    }

    static func outline(frame n: Double, samples: Int = 360) -> Path {
        var path = Path()
        if n <= 150 {
            let r = ringRadius.value(frame: n)
            path.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r))
            return path
        }
        for i in 0..<samples {
            let deg = Double(i) * 360 / Double(samples)
            let r = outlineRadius(frame: n, angle: deg)
            let a = deg * .pi / 180
            let p = CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        return path
    }

    /// Ring colour relative to the hot angle ψ (degrees): the spec's saturated hot segment on a
    /// cream line whose bright half leans yellow.
    static let base = GlowRGB(hex: 0xF4E6D2)
    static let hotStops: [(Double, GlowRGB)] = [
        (-70, base), (-48, GlowRGB(hex: 0xFFB8A0)), (-28, GlowRGB(hex: 0xFF967A)), (0, GlowRGB(hex: 0xFF845E)),
        (22, GlowRGB(hex: 0xFFA070)), (45, GlowRGB(hex: 0xFFD690)), (75, GlowRGB(hex: 0xFFF89E)),
        (105, GlowRGB(hex: 0xFFFFEE)), (140, GlowRGB(hex: 0xFFFFE0)), (180, base),
    ]

    /// Conic gradient for the outline core: `heat` 1 is the full hot segment, 0 a uniform warm cream line.
    static func ringGradient(heat: Double, alpha: Double) -> Gradient {
        let cream = GlowRGB(hex: 0xF0DCC0)
        var stops: [Gradient.Stop] = []
        for rel in stride(from: -180.0, through: 180.0, by: 7.5) {
            let colour = GlowRGB.lerp(cream, hotColour(rel), heat)
            let dimHalf = rel < -70 || rel > 140
            let a = alpha * Ease.lerp(0.95, dimHalf ? 0.82 : 1, heat)
            stops.append(.init(color: colour.color(opacity: min(1, a)), location: (rel + 180) / 360))
        }
        return Gradient(stops: stops)
    }

    /// Amber bloom under the line, turning red-orange under the hot segment.
    static func bloomGradient(heat: Double, alpha: Double) -> Gradient {
        let amber = GlowRGB(hex: 0xF0A030), ember = GlowRGB(hex: 0xE04A1C)
        var stops: [Gradient.Stop] = []
        for rel in stride(from: -180.0, through: 180.0, by: 7.5) {
            let inHot = heat * max(0, 1 - abs(rel + 10) / 55)
            stops.append(.init(color: GlowRGB.lerp(amber, ember, inHot).color(opacity: min(1, 0.68 * alpha)),
                               location: (rel + 180) / 360))
        }
        return Gradient(stops: stops)
    }

    /// Low-alpha wide pass that lets the hot segment bleed red-orange into its glow.
    static func hotGlowGradient(heat: Double, alpha: Double) -> Gradient {
        var stops: [Gradient.Stop] = []
        for rel in stride(from: -180.0, through: 180.0, by: 7.5) {
            let inHot = max(0, 1 - abs(rel - 20) / 70)
            stops.append(.init(color: hotColour(rel).color(opacity: min(1, alpha * heat * 0.14 * inHot)),
                               location: (rel + 180) / 360))
        }
        return Gradient(stops: stops)
    }

    private static func hotColour(_ rel: Double) -> GlowRGB {
        guard rel > hotStops[0].0, rel < hotStops[hotStops.count - 1].0 else { return base }
        for i in 1..<hotStops.count where rel <= hotStops[i].0 {
            let a = hotStops[i - 1], b = hotStops[i]
            return GlowRGB.lerp(a.1, b.1, (rel - a.0) / (b.0 - a.0))
        }
        return base
    }

    /// Strokes the ring/flower outline: warm amber bloom, hot-segment bleed, then the cream core.
    static func strokeOutline(_ path: Path, in context: GraphicsContext, frame n: Double, heat: Double, alpha: Double) {
        guard alpha > 0.001 else { return }
        var ctx = context
        ctx.blendMode = .plusLighter
        let angle = Angle.degrees(hotAngle.value(frame: n) - 180)
        let bloom = GraphicsContext.Shading.conicGradient(bloomGradient(heat: heat, alpha: alpha), center: center, angle: angle)
        ctx.drawLayer { layer in
            layer.addFilter(.blur(radius: 5.5))
            layer.stroke(path, with: bloom, style: StrokeStyle(lineWidth: 3.5, lineJoin: .round))
        }
        let hot = GraphicsContext.Shading.conicGradient(hotGlowGradient(heat: heat, alpha: alpha), center: center, angle: angle)
        let core = GraphicsContext.Shading.conicGradient(ringGradient(heat: heat, alpha: alpha), center: center, angle: angle)
        ctx.stroke(path, with: hot, style: StrokeStyle(lineWidth: 6, lineJoin: .round))
        ctx.stroke(path, with: core, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
    }
}

private struct GrowPainter {
    let frame: Double

    private var t: Double { (frame - GrowGeometry.startFrame) / 30 }

    func paint(_ context: GraphicsContext) {
        drawDot(context)
        drawOutline(context)
        drawAsterisk(context)
        drawNodes(context)
    }

    // MARK: Centre dot

    private static let dotFade = FrameTrack(origin: 0, [(105, 1), (106, 0.9), (107, 0.8), (108, 0.6), (110, 0.25), (113, 0)])

    private func drawDot(_ context: GraphicsContext) {
        let fade = Self.dotFade.value(frame: frame)
        guard fade > 0.001 else { return }
        GrowProfiles.releasedDot.draw(in: context, at: GrowGeometry.center, opacity: fade)
    }

    // MARK: Ring and flower outline

    private static let outlineHeat = FrameTrack(origin: 0, [(174, 1), (178, 0)])
    private static let outlineAlpha = FrameTrack(origin: 0, [(184, 1), (185, 0.7), (186, 0)])

    private func drawOutline(_ context: GraphicsContext) {
        guard frame >= 103.5 else { return }
        let alpha = Self.outlineAlpha.value(frame: frame)
        guard alpha > 0.001 else { return }
        GrowGeometry.strokeOutline(
            GrowGeometry.outline(frame: frame), in: context, frame: frame,
            heat: Self.outlineHeat.value(frame: frame), alpha: alpha)
    }

    // MARK: Asterisk fill

    private static let fillAlpha = FrameTrack(origin: 0, [(182.5, 0), (184, 0.4), (185, 0.95), (186, 1)])
    private static let fillWarmth = FrameTrack(origin: 0, [(184, 0), (185, 0.15), (186, 1)])
    private static let haloStrength = FrameTrack(origin: 0, [(183, 0), (185, 0.6), (186, 1)])

    private func drawAsterisk(_ context: GraphicsContext) {
        let alpha = Self.fillAlpha.value(frame: frame)
        guard alpha > 0.001 else { return }
        AsteriskRenderer(
            center: GrowGeometry.center,
            tip: GrowGeometry.tipRadius.value(frame: frame),
            valley: GrowGeometry.valleyRadius.value(frame: frame),
            exponent: GrowGeometry.petalExponent.value(frame: frame),
            angle: GrowGeometry.petalAngle(frame: frame),
            warmth: Self.fillWarmth.value(frame: frame),
            halo: Self.haloStrength.value(frame: frame)
        ).draw(in: context, opacity: alpha)
    }

    // MARK: Nodes

    /// Radius of a node before it reaches the ring, by frames from its 130 px crossing.
    private static let flight = FrameTrack(origin: 0, [
        (-4.2, 0), (-3, 33), (-2, 64), (-1, 98), (0, 130), (1, 155), (2, 170),
    ])
    /// How far a node overshoots the ring after arriving, by frames from its 130 px crossing.
    private static let overshoot = FrameTrack(origin: 0, [
        (1, 3), (2, 10), (3, 13), (4, 12), (5, 8), (6, 3), (7, 0),
    ])
    private static let nodeFade = FrameTrack(origin: 0, [(176, 1), (180, 0)])

    /// Reference frame at which node k crosses r = 130 on its way out.
    private static let crossing: [Double] = [108.9, 109.9, 110.9, 112.1, 113.6, 115.1]

    private func nodeRadius(_ k: Int) -> Double {
        let local = frame - Self.crossing[k]
        let riding = frame <= 150 ? GrowGeometry.ringRadius.value(frame: frame) : GrowGeometry.tipRadius.value(frame: frame)
        guard local < 7 else { return riding }
        let flying = Self.flight.value(frame: local)
        let arrived = riding + Self.overshoot.value(frame: local)
        return Ease.lerp(flying, arrived, Ease.smoothstep(local - 0.5))
    }

    private func drawNodes(_ context: GraphicsContext) {
        let fade = Self.nodeFade.value(frame: frame)
        guard fade > 0.001 else { return }
        let phase = GrowGeometry.petalAngle(frame: frame)
        for k in 0..<6 {
            let local = frame - Self.crossing[k]
            guard local > -4.2 else { continue }
            let r = nodeRadius(k)
            let a = (phase + 60 * Double(k)) * .pi / 180
            let dir = CGVector(dx: cos(a), dy: sin(a))
            let p = CGPoint(x: GrowGeometry.center.x + r * dir.dx, y: GrowGeometry.center.y + r * dir.dy)
            drawTail(context, node: p, dir: dir, radius: r, local: local)
            drawArrivalRipple(context, at: p, local: local)
            let twinkle = 0.85 + 0.15 * sin(2 * .pi * 3 * t + Double(k))
            let arrival = Ease.smoothstep((local + 0.5) / 2.5)
            GrowProfiles.node.scaled((0.6 + 0.4 * fade) * (0.4 + 0.6 * arrival))
                .draw(in: context, at: p, opacity: twinkle * fade * Ease.progress(local, -4.2, -3))
        }
    }

    private func drawTail(_ context: GraphicsContext, node p: CGPoint, dir: CGVector, radius r: Double, local: Double) {
        let alpha = 0.7 * (1 - Ease.progress(local, 0.5, 3.5))
        guard alpha > 0.001, r > 2 else { return }
        let length = 0.6 * r
        let end = CGPoint(x: p.x - dir.dx * length, y: p.y - dir.dy * length)
        var ctx = context
        ctx.blendMode = .plusLighter
        var path = Path()
        path.move(to: p)
        path.addLine(to: end)
        let colour = GlowRGB(hex: 0xFFC77A)
        ctx.stroke(path, with: .linearGradient(
            Gradient(colors: [colour.color(opacity: alpha), colour.color(opacity: 0)]),
            startPoint: p, endPoint: end), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    private func drawArrivalRipple(_ context: GraphicsContext, at p: CGPoint, local: Double) {
        let tau = (local - 1) / 30
        guard tau > 0, tau < 1.2 else { return }
        let r = 8 + 20 * (1 - exp(-tau / 0.25))
        let path = Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: 2 * r, height: 2 * r))
        var ctx = context
        ctx.blendMode = .plusLighter
        ctx.stroke(path, with: .color(GlowRGB(hex: 0xE8C8A0).color(opacity: 0.55 * exp(-tau / 0.35))),
                   style: StrokeStyle(lineWidth: 1.2))
    }
}

enum GrowProfiles {
    /// The dot at f0105, just after it has released the ring.
    static let releasedDot = GlowProfile([
        (0, 0xFDF9E4), (2, 0xFEF8E0), (4, 0xFFFAD8), (6, 0xE1CEA6), (8, 0xAA8744), (10, 0xA27530),
        (12, 0x8F612A), (16, 0x5F3D15), (20, 0x3E2C10), (26, 0x1E1206), (34, 0x000000),
    ])

    /// A node riding the ring at f0140.
    static let node = GlowProfile([
        (0, 0xFCFCFE), (3, 0xFBFDF9), (4, 0xFCFDEF), (5, 0xFDFDE6), (6, 0xFEE9B9), (7, 0xF4CC8B),
        (8, 0xEAAD5B), (10, 0xD29343), (12, 0xB57B3A), (14, 0x936430), (16, 0x704F28),
        (20, 0x422C16), (24, 0x28180D), (30, 0x170C06), (40, 0x000000),
    ])
}

/// The solid six-petal asterisk (end of scene 2, all of scene 3 until it dissolves).
struct AsteriskRenderer {
    var center: CGPoint
    var tip: Double
    var valley: Double
    var exponent: Double
    var angle: Double
    var warmth: Double = 1
    var halo: Double = 1
    var scale: Double = 1

    func path() -> Path {
        var path = Path()
        let samples = 180
        for i in 0..<samples {
            let deg = Double(i) * 360 / Double(samples)
            let rel = (deg - angle) * .pi / 180
            let r = scale * (valley + (tip - valley) * pow(abs(cos(3 * rel)), exponent))
            let a = deg * .pi / 180
            let p = CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        return path
    }

    private var fill: Gradient {
        let hot: [(UInt32, Double)] = [
            (0xFDFB48, 0), (0xFFF948, 0.42), (0xFDE744, 0.56), (0xFED246, 0.7), (0xFFBC51, 0.84),
            (0xF6A84D, 0.95), (0xE89640, 1),
        ]
        let ember: [(UInt32, Double)] = [
            (0xF79F29, 0), (0xF59C28, 0.42), (0xF29A2C, 0.56), (0xEC8E30, 0.7), (0xE47A2D, 0.84),
            (0xC97230, 0.95), (0xB46A40, 1),
        ]
        return Gradient(stops: zip(hot, ember).map { h, e in
            .init(color: GlowRGB.lerp(GlowRGB(hex: e.0), GlowRGB(hex: h.0), warmth).color, location: h.1)
        })
    }

    func draw(in context: GraphicsContext, opacity: Double) {
        guard opacity > 0.001 else { return }
        let outer = scale * tip
        let shape = path()
        var ctx = context
        ctx.blendMode = .plusLighter
        AsteriskRenderer.halo.scaled(scale).draw(in: context, at: center, opacity: opacity * halo)
        let shading = GraphicsContext.Shading.radialGradient(fill, center: center, startRadius: 0, endRadius: outer)
        ctx.drawLayer { layer in
            layer.opacity = min(1, 0.85 * opacity * halo)
            layer.addFilter(.blur(radius: 4.5 * scale))
            layer.fill(shape, with: .color(GlowRGB(hex: 0xE87818).color))
        }
        var core = context
        core.blendMode = .normal
        core.opacity = opacity
        core.fill(shape, with: shading)
    }

    /// Wide amber bloom around the asterisk (luma>30 out to r ≈ 80).
    static let halo = GlowProfile([
        (0, 0x6A3A0C), (24, 0x7A440E), (30, 0x6E3A0C), (36, 0x55300C), (40, 0x40220A), (50, 0x241204),
        (60, 0x160A02), (80, 0x070301), (100, 0x000000),
    ])
}
