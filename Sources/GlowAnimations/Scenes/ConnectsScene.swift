import SwiftUI

/// Scene 7, "Everything connects" (reference f0624–f0735): the dot left by scene 6 runs one
/// and a half laps of a lemniscate as a comet, stops at the crossing, the whole curve ignites,
/// then it springs out and collapses into the orange ball that scene 8 grows into a sphere.
public struct ConnectsScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        ZStack {
            Canvas { context, _ in
                var context = context
                context.translateBy(x: -ConnectsTimeline.canvasRect.minX, y: -ConnectsTimeline.canvasRect.minY)
                ConnectsTimeline(t: t).draw(in: context)
            }
            .frame(width: ConnectsTimeline.canvasRect.width, height: ConnectsTimeline.canvasRect.height)
            .position(x: ConnectsTimeline.canvasRect.midX, y: ConnectsTimeline.canvasRect.midY)
            ConnectsCaption(t: t)
        }
        .frame(width: 720, height: 1280)
    }
}

/// Every law below was fitted to the reference frames (head position, ring radius, ignite level,
/// collapse extent); the comments give the measured anchors.
struct ConnectsTimeline {
    var t: Double

    /// Everything this canvas draws, including the curve at its 1.08 overshoot plus halo.
    static let canvasRect = CGRect(x: 40, y: 470, width: 640, height: 340)

    static let departure = 0.305
    static let travel = 2.78
    static let startTheta = Double.pi / 2
    static let laps = 1.5
    static let trailLength = 0.48 * Double.pi
    static let persistentLevel = 0.13
    static let collapseStart = 3.285
    static let collapseDuration = 0.38
    static let ballFadeStart = 3.63
    static let ballFadeEnd = 3.69

    /// Sine ease-in-out over 1.5 laps: leaves the crossing at f0635, top speed at the far right (f0675), stops at f0716.
    static func headTheta(at t: Double) -> Double {
        let u = Ease.clamp01((t - departure) / travel)
        return startTheta + laps * 2 * .pi * (1 - cos(.pi * u)) / 2
    }

    /// Times the head passes through the crossing mid-run (f0666, f0684).
    static let crossingTimes: [Double] = [1.0 / 3, 2.0 / 3].map { fraction in
        departure + travel * acos(1 - 2 * fraction) / .pi
    }

    /// Whole-curve fade-up f0713 → f0720.
    static func litLevel(at t: Double) -> Double {
        Ease.smoothstep((t - 3.0) / 0.22)
    }

    /// Springs out to 1.08 at f0727 then collapses to the centre by f0734.
    static func collapseScale(at t: Double) -> CGFloat {
        let u = Ease.clamp01((t - collapseStart) / collapseDuration)
        let overshoot = 1.5
        return CGFloat(max(0, 1 - ((overshoot + 1) * u * u * u - overshoot * u * u)))
    }

    /// Mean trail brightness behind the head (d in units of π), measured on f0660–f0712 relative to the head.
    private static let trailProfile: [(d: Double, level: Double)] = [
        (0, 1), (0.05, 1), (0.10, 0.83), (0.15, 0.69), (0.20, 0.58), (0.25, 0.46),
        (0.30, 0.38), (0.35, 0.29), (0.40, 0.21), (0.48, 0.13),
    ]

    /// Trail level at parameter distance `d` behind the head. Until the head has covered 0.5π
    /// the profile is compressed onto the distance travelled (dim, short tail at f0648/f0652).
    static func trailLevel(behind d: Double, travelled: Double) -> Double {
        guard d >= 0, d <= travelled else { return 0 }
        let stretched = d / .pi * max(1, 0.5 * .pi / travelled)
        guard let upper = trailProfile.firstIndex(where: { $0.d >= stretched }) else { return persistentLevel }
        guard upper > 0 else { return 1 }
        let a = trailProfile[upper - 1]
        let b = trailProfile[upper]
        return Ease.lerp(a.level, b.level, (stretched - a.d) / (b.d - a.d))
    }

    func draw(in context: GraphicsContext) {
        let shutter = 0.5 / 30
        let scaleNow = Self.collapseScale(at: t)
        let moving = abs(scaleNow - Self.collapseScale(at: t + shutter)) > 0.02
        let samples = moving ? 6 : 1
        let scales = (0..<samples).map { Self.collapseScale(at: t + shutter * Double($0) / Double(samples)) }
        drawCurve(in: context, scales: scales)
        drawRings(in: context)

        let ballMix = Ease.progress(t, Self.ballFadeStart, Self.ballFadeEnd)
        ConnectsDot.draw(in: context, at: Lemniscate.point(Self.headTheta(at: t), scale: scaleNow), opacity: 1 - ballMix)
        if ballMix > 0 {
            let radius = FlowTimeline.sphereRadius(at: t - GlowScene.connects.duration)
            FlowBlob.draw(
                in: context,
                balls: [BlobBall(center: Lemniscate.center, radius: radius)],
                bounds: CGRect(x: 200, y: 480, width: 320, height: 320),
                opacity: ballMix
            )
        }
    }

    /// Draws the curve once per shutter sample in `scales` (one sample unless it is collapsing fast).
    private func drawCurve(in context: GraphicsContext, scales: [CGFloat]) {
        let head = Self.headTheta(at: t)
        let travelled = head - Self.startTheta
        let lit = Self.litLevel(at: t)
        let loopEnd = Self.startTheta + 2 * .pi
        let base = max(lit, head > Self.startTheta ? Self.persistentLevel : 0)
        let share = 1 / Double(scales.count)

        var additive = context
        additive.blendMode = .plusLighter

        for (blur, width, strength) in [(CGFloat(5), CGFloat(5), 1.0), (12, 8, 0.8)] {
            var haloLayer = additive
            haloLayer.addFilter(.blur(radius: blur))
            haloLayer.drawLayer { layer in
                for scale in scales {
                    let halo = Lemniscate.shading(Lemniscate.haloStops, scale: scale)
                    if lit > 0 {
                        var full = layer
                        full.opacity = lit * share * strength
                        full.stroke(Lemniscate.path(from: Self.startTheta, to: loopEnd, scale: scale), with: halo, lineWidth: width)
                    }
                    forEachTrailSegment(head: head) { path, d in
                        let extra = (Self.trailLevel(behind: d, travelled: travelled) - max(lit, Self.persistentLevel)) / (1 - Self.persistentLevel)
                        guard extra > 0 else { return }
                        var seg = layer
                        seg.opacity = extra * share * strength
                        seg.stroke(path(scale), with: halo, style: StrokeStyle(lineWidth: width, lineCap: .round))
                    }
                }
            }
        }

        guard scales.count > 1 else {
            drawCores(in: additive, scales: scales, head: head, travelled: travelled, lit: lit, base: base)
            return
        }
        var smear = additive
        smear.addFilter(.blur(radius: 2.5))
        smear.drawLayer { layer in
            var layer = layer
            layer.blendMode = .plusLighter
            drawCores(in: layer, scales: scales, head: head, travelled: travelled, lit: lit, base: base)
        }
    }

    private func drawCores(in additive: GraphicsContext, scales: [CGFloat], head: Double, travelled: Double, lit: Double, base: Double) {
        let loopEnd = Self.startTheta + 2 * .pi
        let visitedEnd = min(head, loopEnd)
        let share = 1 / Double(scales.count)
        for scale in scales {
            let core = Lemniscate.shading(Lemniscate.coreStops, scale: scale)
            if visitedEnd > Self.startTheta || lit > 0 {
                var line = additive
                line.opacity = max(base, lit > 0 ? 0 : 0.26) * share
                let end = lit > 0 ? loopEnd : visitedEnd
                let width = 1.5 + 0.5 * CGFloat(lit)
                let hue = lit > 0.5 ? core : Lemniscate.shading(Lemniscate.haloStops, scale: scale)
                line.stroke(Lemniscate.path(from: Self.startTheta, to: end, scale: scale), with: hue, lineWidth: width)
            }

            forEachTrailSegment(head: head) { path, d in
                let level = Self.trailLevel(behind: d, travelled: travelled)
                let extra = level - base
                guard extra > 0 else { return }
                var seg = additive
                seg.opacity = extra * share
                let brightness = (level - Self.persistentLevel) / (1 - Self.persistentLevel)
                seg.stroke(path(scale), with: core, style: StrokeStyle(lineWidth: 1.2 + 1.4 * CGFloat(brightness), lineCap: .round))
            }

            let whiteReach = 0.24 * Double.pi
            forEachTrailSegment(head: head, length: whiteReach) { path, d in
                var seg = additive
                seg.opacity = pow(1 - d / whiteReach, 1.2) * Self.trailLevel(behind: d, travelled: travelled) * share
                seg.stroke(path(scale), with: .color(Color(hex: 0xFFF6E6)), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
            }
        }
    }

    /// Splits the trail behind the head into short pieces; `body` gets each piece's path builder
    /// (taking the collapse scale) and its parameter distance behind the head.
    private func forEachTrailSegment(head: Double, length: Double = trailLength, _ body: ((CGFloat) -> Path, Double) -> Void) {
        let travelled = head - Self.startTheta
        guard travelled > 0 else { return }
        let reach = min(length, travelled)
        let count = max(1, Int(ceil(reach / (length / 28))))
        let step = reach / Double(count)
        for i in 0..<count {
            let near = head - step * Double(i)
            let far = near - step
            let mid = step * (Double(i) + 0.5)
            let build: (CGFloat) -> Path = { scale in Lemniscate.path(from: far, to: near, scale: scale, step: step / 2) }
            body(build, mid)
        }
    }

    /// A thin ring blooms from the crossing each time the head passes it: r 10 → 46 over 16 frames.
    private func drawRings(in context: GraphicsContext) {
        var ctx = context
        ctx.blendMode = .plusLighter
        for start in Self.crossingTimes {
            let age = t - start
            let u = age / 0.6
            guard u > 0, u < 1 else { continue }
            let radius = 10 + 36 * CGFloat(1 - pow(max(0, 1 - age / 0.533), 2))
            let alpha = 0.75 * exp(-age * 30 / 7) * (1 - pow(u, 8))
            let rect = CGRect(x: 360 - radius, y: 640 - radius, width: radius * 2, height: radius * 2)
            var ring = ctx
            ring.opacity = alpha
            ring.stroke(Path(ellipseIn: rect), with: .color(Color(hex: 0xFFD8BC)), lineWidth: 1.5)
        }
    }
}

/// "Everything *connects*": wipes in left to right from f0645, wipes out left to right from f0723.
struct ConnectsCaption: View {
    var t: Double

    /// Fitted to the f0700 word extents: "Everything" x 192–375, "connects" x 390–531.
    static let fontSize: CGFloat = 40.1
    static let accentSize: CGFloat = 46.2
    static let baselineY: CGFloat = 878.5

    var body: some View {
        let reveal = Ease.clamp01((t - 0.53) / 0.85)
        let exit = Ease.clamp01((t - 3.34) / 0.45)
        let line = HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: "Everything")
                .font(GlowFonts.sans(weight: .light, size: Self.fontSize))
                .foregroundStyle(Color.white)
            Color.clear.frame(width: CaptionReveal.spaceWidth(fontSize: Self.fontSize), height: 1)
            Text(verbatim: "connects")
                .font(GlowFonts.serifItalic(size: Self.accentSize))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xEC9440), Color(hex: 0xF5C88A)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .fixedSize()

        Group {
            if exit > 0 {
                line.blurWipe(progress: 1 - exit, edgeWidth: 200, reversed: true)
            } else {
                line.blurWipe(progress: reveal, edgeWidth: 200)
            }
        }
        .alignmentGuide(VerticalAlignment.top) { $0[.firstTextBaseline] }
        .frame(width: 720, height: 1280, alignment: .top)
        .offset(y: Self.baselineY)
        .allowsHitTesting(false)
    }
}
