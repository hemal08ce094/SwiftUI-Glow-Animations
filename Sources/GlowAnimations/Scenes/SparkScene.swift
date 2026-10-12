import SwiftUI

/// Scene 1, "Start with a *spark*": a spark drops onto a ripple plane, a sun rises out of the
/// splash, flashes and collapses into the dot that scene 2 grows from.
/// Spec: docs/storyboard/01-spark.md. Laws below are fitted to the reference frames.
public struct SparkScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        ZStack {
            Canvas(rendersAsynchronously: false) { context, _ in
                SparkPainter(t: t).paint(context)
            }
            .frame(width: 720, height: 1280)

            TimedCaption(
                lead: "Start with a",
                accent: "spark",
                fontSize: 44,
                baselineY: 541,
                frame: 1 + 30 * t,
                timings: [
                    CaptionWordTiming(inFrame: 33.8, inFrames: 12, outFrame: 88.3, outFrames: 8),
                    CaptionWordTiming(inFrame: 37.3, inFrames: 13, outFrame: 89.5, outFrames: 8),
                    CaptionWordTiming(inFrame: 39.5, inFrames: 12, outFrame: 90.5, outFrames: 8),
                    CaptionWordTiming(inFrame: 41.2, inFrames: 17, outFrame: 91.5, outFrames: 9.5),
                ]
            )
            .blendMode(.plusLighter)
        }
        .frame(width: 720, height: 1280)
    }
}

private struct SparkPainter {
    let t: Double

    static let planeY: Double = 824
    static let impactTime: Double = 1.0
    static let fallStart: Double = 0.567

    func paint(_ context: GraphicsContext) {
        drawFlashRing(context)
        drawRings(context)
        drawImpactGlow(context)
        drawDropletRipples(context)
        drawReflection(context)
        drawSun(context)
        drawFlare(context)
        drawBeam(context)
        drawDroplets(context)
        drawSpark(context)
        drawEmergingRing(context)
    }

    private func drawEmergingRing(_ context: GraphicsContext) {
        let frame = 1 + 30 * t
        guard frame >= 103.5 else { return }
        GrowGeometry.strokeOutline(GrowGeometry.outline(frame: frame), in: context, frame: frame, heat: 1, alpha: 1)
    }

    // MARK: Spark (f0005–f0031)

    private func drawSpark(_ context: GraphicsContext) {
        guard t >= 0.12, t < 1.04 else { return }
        let pop = Ease.easeOut((t - 0.12) / 0.18)
        let flicker = 1 + 0.08 * sin(2 * .pi * 5 * t)
        let tau = max(0, t - Self.fallStart)
        let y = 373 + 2350 * tau * tau
        let stretch = 1 + 185 * tau * tau / 30
        let fade = 1 - Ease.progress(t, 0.967, 1.04)
        SparkProfiles.spark.scaled(max(0.05, pop)).draw(
            in: context,
            at: CGPoint(x: 360, y: y),
            scaleY: stretch,
            opacity: pop * fade * (tau > 0 ? 1 : flicker)
        )
    }

    // MARK: Ripple plane

    private struct Ring {
        let size: Double
        let start: Double
        let rate: Double
        let gain: Double
    }

    private static let rings = [
        Ring(size: 282, start: 1.033, rate: 0.45, gain: 1.0),
        Ring(size: 215, start: 1.20, rate: 0.38, gain: 1.0),
        Ring(size: 150, start: 1.25, rate: 0.40, gain: 1.05),
        Ring(size: 95, start: 1.30, rate: 0.40, gain: 1.1),
        Ring(size: 53, start: 1.35, rate: 0.40, gain: 1.15),
    ]

    private var ringFade: Double {
        let decay = min(1, 0.95 * exp(-(t - 1.067) / 0.66)) * 0.55
        return decay * (1 - Ease.progress(t, 2.77, 2.93))
    }

    /// Cream hairline with an amber halo, as the ripple rings read on the reference.
    static func strokeRing(_ path: Path, in context: GraphicsContext, opacity: Double, lineWidth: CGFloat = 1.4) {
        guard opacity > 0.001 else { return }
        var ctx = context
        ctx.blendMode = .plusLighter
        let passes: [(UInt32, CGFloat, Double)] = [
            (0xC8701E, 16, 0.09), (0xE08A34, 7, 0.22), (0xF0B060, 3.2, 0.38), (0xFFE6C4, lineWidth, 0.85),
        ]
        for (hex, width, alpha) in passes {
            ctx.stroke(path, with: .color(GlowRGB(hex: hex).color(opacity: min(1, opacity * alpha))),
                       style: StrokeStyle(lineWidth: width))
        }
    }

    private func ringRadius(_ ring: Ring) -> Double {
        ring.size * (1 - exp(-max(0, t - ring.start) / ring.rate))
    }

    private func drawRings(_ context: GraphicsContext) {
        guard t >= 1.033, t < 3.1 else { return }
        let base = ringFade
        for ring in Self.rings where t > ring.start {
            let a = ringRadius(ring)
            guard a > 2 else { continue }
            let alpha = base * ring.gain * Ease.progress(t, ring.start, ring.start + 0.1)
            let path = Path(ellipseIn: CGRect(x: 360 - a, y: Self.planeY - 0.22 * a, width: 2 * a, height: 0.44 * a))
            Self.strokeRing(path, in: context, opacity: alpha)
        }
        let outer = ringRadius(Self.rings[0])
        let lineAlpha = 0.35 * base + Self.horizonFlash.value(at: t)
        if outer > 20 {
            var ctx = context
            ctx.blendMode = .plusLighter
            let line = Path(CGRect(x: 360 - outer, y: Self.planeY - 0.5, width: 2 * outer, height: 1))
            let colour = GlowRGB(hex: 0xC98A40)
            ctx.fill(line, with: .linearGradient(
                Gradient(stops: [
                    .init(color: colour.color(opacity: 0), location: 0),
                    .init(color: colour.color(opacity: lineAlpha), location: 0.3),
                    .init(color: colour.color(opacity: lineAlpha), location: 0.7),
                    .init(color: colour.color(opacity: 0), location: 1),
                ]),
                startPoint: CGPoint(x: 360 - outer, y: 0), endPoint: CGPoint(x: 360 + outer, y: 0)))
        }
    }

    private static let horizonFlash = FrameTrack(origin: 1, [(84, 0), (86, 0.35), (88, 0.5), (90, 0.3), (92, 0)])

    private func drawImpactGlow(_ context: GraphicsContext) {
        let tau = t - Self.impactTime
        guard tau > 0, tau < 0.9 else { return }
        let grow = 30 + 45 * (1 - exp(-tau / 0.18))
        let glow = GlowProfile([
            (0, 0x9A6434), (0.3, 0x7A4E26), (0.6, 0x3A220C), (1, 0x000000),
        ]).scaled(grow)
        glow.draw(in: context, at: CGPoint(x: 360, y: Self.planeY + 2), scaleY: 0.24,
                  opacity: Ease.progress(tau, 0, 0.05) * exp(-tau / 0.35))
        GlowProfile([(0, 0x3A2210), (0.5, 0x22140A), (1, 0x000000)]).scaled(grow * 1.6)
            .draw(in: context, at: CGPoint(x: 360, y: Self.planeY - 10), scaleY: 0.6,
                  opacity: Ease.progress(tau, 0, 0.05) * exp(-tau / 0.5))
    }

    // MARK: Splash: beam, crown droplets, top droplet

    private static let columnTop = FrameTrack(origin: 1, [
        (31, 828), (32, 812), (33, 793), (34, 777), (35, 765), (36, 756), (37, 750), (38, 752),
        (39, 755), (40, 762), (41, 774), (42, 791), (43, 809), (44, 828),
    ])

    private func drawBeam(_ context: GraphicsContext) {
        guard t > 1.0, t < 1.433 else { return }
        let top = Self.columnTop.value(at: t)
        let bottom = 828.0
        guard bottom - top > 1 else { return }
        let narrowing = 1 - 0.5 * Ease.progress(t, 1.33, 1.37)
        let profile = SparkProfiles.beam.scaled(narrowing)
        let halfWidth = profile.outerRadius
        var ctx = context
        ctx.blendMode = .plusLighter
        let stops: [Gradient.Stop] = stride(from: -halfWidth, through: halfWidth, by: halfWidth / 17).map { x in
            .init(color: profile.sample(abs(x)).color, location: (x + halfWidth) / (2 * halfWidth))
        }
        ctx.fill(
            Path(CGRect(x: 360 - halfWidth, y: top, width: 2 * halfWidth, height: bottom - top)),
            with: .linearGradient(Gradient(stops: stops),
                                  startPoint: CGPoint(x: 360 - halfWidth, y: 0),
                                  endPoint: CGPoint(x: 360 + halfWidth, y: 0))
        )
        profile.scaled(0.8).draw(in: context, at: CGPoint(x: 360, y: top))
    }

    private static let dropPeakTime = 1.3167
    private static let gravity = 1376.0

    private var topDropletY: Double {
        let dt = t - Self.dropPeakTime
        return 737 + Self.gravity * dt * dt
    }

    private func drawDroplets(_ context: GraphicsContext) {
        let drop = SparkProfiles.droplet
        if t >= 1.2, t < 1.57 {
            drop.draw(in: context, at: CGPoint(x: 360, y: topDropletY), opacity: 1)
        }
        for (droplet, landing) in Self.crown {
            let tau = t - 1.033
            guard tau > 0, t < landing else { continue }
            drop.draw(in: context, at: droplet.position(at: t), opacity: Ease.progress(tau, 0.03, 0.12))
        }
    }

    private struct CrownDroplet {
        let vx: Double
        let drift: Double

        func position(at t: Double) -> CGPoint {
            let tau = t - 1.033
            let fall = t - 1.2
            return CGPoint(x: 360 + vx * tau, y: 791 + SparkPainter.gravity * fall * fall + drift * tau)
        }

        func computeLanding() -> Double {
            var lo = 1.2, hi = 1.6
            for _ in 0..<30 {
                let mid = (lo + hi) / 2
                if position(at: mid).y < 826 { lo = mid } else { hi = mid }
            }
            return lo
        }
    }

    private static let crown: [(droplet: CrownDroplet, landing: Double)] = [
        CrownDroplet(vx: -165, drift: -12),
        CrownDroplet(vx: -90, drift: 0),
        CrownDroplet(vx: 48, drift: 10),
        CrownDroplet(vx: 135, drift: 30),
        CrownDroplet(vx: 210, drift: -12),
    ].map { ($0, $0.computeLanding()) }

    private func drawDropletRipples(_ context: GraphicsContext) {
        var sources = Self.crown.map { ($0.droplet.position(at: $0.landing).x, $0.landing) }
        sources.append((360, 1.567))
        for (x, landing) in sources {
            let tau = t - landing
            guard tau > 0, tau < 0.7 else { continue }
            let a = 5 + 26 * (1 - exp(-tau / 0.18))
            let path = Path(ellipseIn: CGRect(x: x - a, y: 826 - 0.26 * a, width: 2 * a, height: 0.52 * a))
            Self.strokeRing(path, in: context, opacity: 0.8 * exp(-tau / 0.25), lineWidth: 1.1)
        }
    }

    // MARK: Sun, reflection, flare, flash

    private static let sunY = FrameTrack(origin: 1, [
        (54, 895), (56, 872), (58, 861), (60, 850), (62, 839), (64, 826), (66, 811), (68, 790.5),
        (70, 766.5), (72, 737.5), (74, 711), (76, 688.5), (78, 671.5), (80, 657.5), (82, 646.5),
        (84, 641.5), (86, 639.5), (88, 639.5),
    ])

    private static let sunProfile = ProfileTrack(origin: 1, SparkProfiles.swell)

    private func drawSun(_ context: GraphicsContext) {
        guard t >= 1.77 else { return }
        let y = Self.sunY.value(at: t)
        let profile = Self.sunProfile.profile(at: t)
        let plane = Self.planeY + 2
        let reveal = plane + max(0, 820 - y) * 0.7 + max(0, 790 - y) * 3.5
        var above = context
        above.clip(to: Path(CGRect(x: 0, y: 0, width: 720, height: reveal)))
        profile.draw(in: above, at: CGPoint(x: 360, y: y))
        guard reveal < 1280 else { return }
        var below = context
        below.blendMode = .plusLighter
        below.clip(to: Path(CGRect(x: 0, y: reveal, width: 720, height: 1280 - reveal)))
        below.drawLayer { layer in
            profile.tinted(0.95, 0.62, 0.28).draw(in: layer, at: CGPoint(x: 360, y: y), scaleX: 1.15, opacity: 0.45)
            layer.blendMode = .destinationIn
            layer.fill(
                Path(CGRect(x: 0, y: reveal, width: 720, height: 1280 - reveal)),
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: .white, location: 0),
                        .init(color: .white.opacity(0.45), location: 0.3),
                        .init(color: .white.opacity(0.12), location: 0.65),
                        .init(color: .clear, location: 1),
                    ]),
                    startPoint: CGPoint(x: 0, y: reveal), endPoint: CGPoint(x: 0, y: reveal + 45)))
        }
    }

    private static let flareStrength = FrameTrack(origin: 1, [
        (81, 0), (82, 0.25), (83, 0.5), (84, 0.8), (86, 1), (90, 1), (92, 0.75), (94, 0.45),
        (96, 0.2), (98, 0.05), (100, 0),
    ])

    private func drawFlare(_ context: GraphicsContext) {
        let strength = Self.flareStrength.value(at: t)
        guard strength > 0.001 else { return }
        let y = Self.sunY.value(at: t)
        var ctx = context
        ctx.blendMode = .plusLighter
        let colour = GlowRGB(hex: 0xF0A050)
        let stops: [Gradient.Stop] = stride(from: 0.0, through: 1.0, by: 0.05).map { u in
            let falloff = pow(1 - abs(2 * u - 1), 1.6)
            return .init(color: colour.color(opacity: min(1, strength * falloff)), location: u)
        }
        let shading = GraphicsContext.Shading.linearGradient(
            Gradient(stops: stops), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 720, y: 0))
        GlowProfile([(0, 0xB06A28), (0.4, 0x6A3C14), (1, 0x000000)]).scaled(60)
            .draw(in: context, at: CGPoint(x: 360, y: y), scaleX: 4.2, scaleY: 0.2, opacity: strength)
        for (height, alpha) in [(2.0, 0.9), (5.0, 0.35), (11.0, 0.15)] {
            var layer = ctx
            layer.opacity = alpha
            layer.fill(Path(CGRect(x: 0, y: y - height / 2, width: 720, height: height)), with: shading)
        }
    }

    private static let barRows: [(y: Double, gain: Double, width: Double)] = [
        (826, 0.8, 110), (834, 1.0, 72), (843.5, 0.92, 96), (853.5, 0.85, 100), (865, 0.82, 90),
        (877, 0.62, 44), (890, 0.5, 84), (905, 0.45, 46), (920, 0.36, 34), (937, 0.3, 46),
        (954, 0.26, 60),
    ]

    private static let reflectionStrength = FrameTrack(origin: 1, [
        (62, 0), (66, 0.5), (70, 0.8), (84, 0.8), (86, 0.9), (88, 0.6), (90, 0.35), (92, 0),
    ])

    private func drawReflection(_ context: GraphicsContext) {
        let strength = Self.reflectionStrength.value(at: t)
        guard strength > 0.001 else { return }
        var ctx = context
        ctx.blendMode = .plusLighter
        let column = GlowProfile([(0, 0x8A5426), (0.5, 0x46280E), (1, 0x000000)]).scaled(70)
        column.draw(in: ctx, at: CGPoint(x: 360, y: 870), scaleX: 0.55, scaleY: 1.4, opacity: strength)
        let colour = GlowRGB(hex: 0xF5A852)
        for (i, row) in Self.barRows.enumerated() {
            let shimmer = 1 + 0.25 * sin(t * 37 + Double(i) * 2.1) * sin(t * 23 + Double(i))
            let half = row.width * shimmer / 2
            for (height, gain) in [(2.0, 0.85), (5.0, 0.15)] {
                let alpha = min(1, strength * row.gain * gain)
                ctx.fill(
                    Path(CGRect(x: 360 - half, y: row.y - height / 2, width: 2 * half, height: height)),
                    with: .linearGradient(
                        Gradient(stops: [
                            .init(color: colour.color(opacity: 0), location: 0),
                            .init(color: colour.color(opacity: alpha), location: 0.3),
                            .init(color: colour.color(opacity: alpha), location: 0.7),
                            .init(color: colour.color(opacity: 0), location: 1),
                        ]),
                        startPoint: CGPoint(x: 360 - half, y: 0), endPoint: CGPoint(x: 360 + half, y: 0))
                )
            }
        }
    }

    /// Expanding shock ring of the flash: sampled peak radius per frame (it reaches the corners at f0090).
    private static let shockRadius = FrameTrack(origin: 1, [
        (86, 200), (87, 320), (88, 460), (89, 562), (90, 690), (91, 760),
    ])
    private static let shockStrength = FrameTrack(origin: 1, [
        (85.5, 0), (86, 0.3), (87, 1), (88, 0.9), (89, 0.95), (90, 1), (91, 0.5), (92, 0),
    ])

    private func drawFlashRing(_ context: GraphicsContext) {
        let strength = Self.shockStrength.value(at: t)
        guard strength > 0.001 else { return }
        let r = Self.shockRadius.value(at: t)
        let ring = GlowProfile(stops: [
            (0, .black), (max(0, r - 130), .black), (r - 50, GlowRGB(hex: 0x2C180A)),
            (r, GlowRGB(hex: 0x4E3C24)), (r + 25, GlowRGB(hex: 0x24160A)), (r + 60, .black),
        ])
        ring.draw(in: context, at: CGPoint(x: 360, y: 639.5), opacity: strength)
    }
}
