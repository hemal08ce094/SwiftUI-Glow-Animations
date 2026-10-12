import SwiftUI

/// Scene 9, the outro (reference f0856–f0950): the orange ball sprouts a glowing six-armed
/// asterisk that spins into place, rises to make room for the "louisraille.fr" credit, sends out
/// one thin ring, and holds over a faint warm hairline.
public struct OutroScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        ZStack {
            Canvas { context, _ in
                var context = context
                context.translateBy(x: -OutroTimeline.canvasRect.minX, y: -OutroTimeline.canvasRect.minY)
                OutroTimeline(t: t).draw(in: context)
            }
            .frame(width: OutroTimeline.canvasRect.width, height: OutroTimeline.canvasRect.height)
            .position(x: OutroTimeline.canvasRect.midX, y: OutroTimeline.canvasRect.midY)
            OutroCredit(t: t)
        }
        .frame(width: 720, height: 1280)
    }
}

/// Laws fitted to the reference frames; comments give the measured anchors.
struct OutroTimeline {
    var t: Double

    static let canvasRect = CGRect(x: 150, y: 430, width: 420, height: 440)
    static let asterisk = Asterisk()

    /// x 358.6 throughout; y holds at 638.5, then settles exponentially to 593.3 from f0870
    /// (626.9 at f0871, 605.7 at f0874, 596.4 at f0878, 593.7 at f0884).
    static func center(at t: Double) -> CGPoint {
        let rise = t < 0.47 ? 1 : exp(-(t - 0.47) / 0.1)
        return CGPoint(x: 358.6, y: 593.3 + 45.2 * rise)
    }

    /// Clockwise rotation in degrees of the arm that starts on +x: a sprout spin that lands at f0863,
    /// then a steady 13.9°/s drift (95.5° at f0866 → 134.6° at f0950, from the 6-fold phase).
    static func rotation(at t: Double) -> Double {
        let u = Ease.clamp01(t / 0.2167)
        return 95.5 + 13.9 * (t - 1.0 / 3) - 51.3 * pow(1 - u, 1.2)
    }

    /// Arms reach 74 % of full length at f0857 and full length by f0864.
    static func armScale(at t: Double) -> CGFloat {
        let u = Ease.clamp01((t - 1.0 / 30) / 0.233)
        return CGFloat(0.74 + 0.26 * (1 - pow(1 - u, 1.5)))
    }

    func draw(in context: GraphicsContext) {
        let ballFade = Ease.progress(t, 0, 0.08)
        if ballFade < 1 {
            let radius = FlowTimeline.sphereRadius(at: GlowScene.flow.duration + t)
            FlowBlob.draw(
                in: context,
                balls: [BlobBall(center: CGPoint(x: 360, y: 640), radius: radius)],
                bounds: CGRect(x: 260, y: 540, width: 200, height: 200),
                opacity: 1 - ballFade
            )
        }
        drawAsterisk(in: context, opacity: Ease.progress(t, 0, 0.1))
        drawRing(in: context)
        drawHairline(in: context)
    }

    private func drawAsterisk(in context: GraphicsContext, opacity: Double) {
        guard opacity > 0 else { return }
        let c = Self.center(at: t)
        let rotation = Self.rotation(at: t) * .pi / 180
        let shape = Self.asterisk.path(center: c, rotation: rotation, scale: Self.armScale(at: t))
        var ctx = context
        ctx.opacity = opacity
        ctx.blendMode = .plusLighter

        for (blur, alpha, hex) in [(CGFloat(60), 1.0, UInt32(0xD0601C)), (26, 1.0, 0xD86A14), (12, 0.9, 0xE8861E), (5, 0.8, 0xF4A830)] {
            var glow = ctx
            glow.opacity *= alpha
            glow.addFilter(.blur(radius: blur))
            glow.drawLayer { layer in layer.fill(shape, with: .color(Color(hex: hex))) }
        }

        let haze = Gradient(stops: [
            .init(color: Color(hex: 0x120802), location: 0),
            .init(color: Color(hex: 0x120802), location: 0.46),
            .init(color: Color(hex: 0x0C0401), location: 0.58),
            .init(color: Color(hex: 0x080300), location: 0.69),
            .init(color: .black, location: 1),
        ])
        ctx.fill(
            Path(ellipseIn: CGRect(x: c.x - 130, y: c.y - 130, width: 260, height: 260)),
            with: .radialGradient(haze, center: c, startRadius: 0, endRadius: 130)
        )

        var body = ctx
        body.blendMode = .normal
        body.addFilter(.blur(radius: 1.2))
        let reach = Self.asterisk.armLength
        let gradient = Gradient(stops: [
            .init(color: Color(hex: 0xFFFD58), location: 0),
            .init(color: Color(hex: 0xFEF552), location: 0.5),
            .init(color: Color(hex: 0xF7DA3A), location: 0.85),
            .init(color: Color(hex: 0xF0A030), location: 1),
        ])
        body.drawLayer { layer in
            layer.fill(shape, with: .radialGradient(gradient, center: c, startRadius: 0, endRadius: reach))
        }
    }

    /// One thin ring from the asterisk, fitted on f0899–f0917: r = 45 + 81·(1 − (1 − u)²) with
    /// u = (t − 1.41) / 0.62; brightness holds to f0906, then fades out by f0917.
    private func drawRing(in context: GraphicsContext) {
        let u = (t - 1.41) / 0.62
        guard u > 0, u < 1 else { return }
        let radius = 45 + 81 * CGFloat(1 - (1 - u) * (1 - u))
        let c = Self.center(at: t)
        var ring = context
        ring.opacity = 0.45 * pow(min(1, (1 - u) / 0.65), 0.9)
        ring.stroke(
            Path(ellipseIn: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2)),
            with: .color(Color(hex: 0xC9A36A)),
            lineWidth: 1.5
        )
    }

    /// 2 px warm line at y 819–821 opening from the centre over f0883–f0894; Gaussian falloff, 115 px.
    private func drawHairline(in context: GraphicsContext) {
        let spread = Ease.easeOut((t - 0.9) / 0.37)
        guard spread > 0 else { return }
        let halfWidth = 230 * CGFloat(spread)
        let falloff = 115 * CGFloat(spread)
        let peak = Color(hex: 0x5A4438)
        var stops: [Gradient.Stop] = []
        for i in 0...12 {
            let x = CGFloat(i) / 12
            let dx = (x - 0.5) * 2 * halfWidth
            stops.append(.init(color: peak.opacity(Double(exp(-pow(dx / max(falloff, 1), 2)))), location: x))
        }
        var line = context
        line.blendMode = .plusLighter
        line.fill(
            Path(CGRect(x: 360 - halfWidth, y: 819, width: halfWidth * 2, height: 2)),
            with: .linearGradient(Gradient(stops: stops), startPoint: CGPoint(x: 360 - halfWidth, y: 0), endPoint: CGPoint(x: 360 + halfWidth, y: 0))
        )
    }
}

/// "louisraille.fr" credit, wiped in left to right from f0880 (sharp by f0904); no exit.
struct OutroCredit: View {
    var t: Double

    static let fontSize: CGFloat = 37.3
    static let baselineY: CGFloat = 699.5

    var body: some View {
        let reveal = Ease.clamp01((t - 0.6) / 0.81)
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: "louisraille")
                .foregroundStyle(Color(hex: 0xF2EEEA))
            Text(verbatim: ".fr")
                .foregroundStyle(Color(hex: 0xEBC294))
        }
        .font(GlowFonts.sans(weight: .light, size: Self.fontSize))
        .fixedSize()
        .blurWipe(progress: reveal, edgeWidth: 100)
        .alignmentGuide(VerticalAlignment.top) { $0[.firstTextBaseline] }
        .frame(width: 720, height: 1280, alignment: .top)
        .offset(y: Self.baselineY)
        .allowsHitTesting(false)
    }
}
