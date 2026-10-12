import SwiftUI

/// Linear RGB triple in 0...1 used for additive glow maths before it becomes a `Color`.
struct GlowRGB: Equatable {
    var r: Double
    var g: Double
    var b: Double

    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    init(hex: UInt32) {
        r = Double((hex >> 16) & 0xFF) / 255
        g = Double((hex >> 8) & 0xFF) / 255
        b = Double(hex & 0xFF) / 255
    }

    static let black = GlowRGB(r: 0, g: 0, b: 0)

    static func lerp(_ a: GlowRGB, _ b: GlowRGB, _ u: Double) -> GlowRGB {
        GlowRGB(r: a.r + (b.r - a.r) * u, g: a.g + (b.g - a.g) * u, b: a.b + (b.b - a.b) * u)
    }

    func scaled(_ k: Double) -> GlowRGB { GlowRGB(r: r * k, g: g * k, b: b * k) }

    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: 1) }

    func color(opacity: Double) -> Color { Color(.sRGB, red: r, green: g, blue: b, opacity: opacity) }
}

/// A radially symmetric light, given as the colour it adds on black at sampled radii (design px).
/// Profiles are measured straight off the reference frames, so drawing one additively reproduces
/// the sampled light field.
struct GlowProfile {
    var stops: [(radius: Double, rgb: GlowRGB)]

    init(_ samples: [(Double, UInt32)]) {
        stops = samples.map { ($0.0, GlowRGB(hex: $0.1)) }
    }

    init(stops: [(radius: Double, rgb: GlowRGB)]) {
        self.stops = stops
    }

    var outerRadius: Double { stops.last?.radius ?? 0 }

    func sample(_ radius: Double) -> GlowRGB {
        guard let first = stops.first else { return .black }
        if radius <= first.radius { return first.rgb }
        for i in 1..<stops.count where radius <= stops[i].radius {
            let a = stops[i - 1], b = stops[i]
            return GlowRGB.lerp(a.rgb, b.rgb, (radius - a.radius) / (b.radius - a.radius))
        }
        return stops[stops.count - 1].rgb
    }

    /// Every radius scaled by `k` (the light grows or shrinks, keeping its falloff shape).
    func scaled(_ k: Double) -> GlowProfile {
        GlowProfile(stops: stops.map { ($0.radius * k, $0.rgb) })
    }

    func dimmed(_ k: Double) -> GlowProfile {
        GlowProfile(stops: stops.map { ($0.radius, $0.rgb.scaled(k)) })
    }

    /// Multiplies each channel, e.g. to tint a light seen through amber water.
    func tinted(_ r: Double, _ g: Double, _ b: Double) -> GlowProfile {
        GlowProfile(stops: stops.map { ($0.radius, GlowRGB(r: $0.rgb.r * r, g: $0.rgb.g * g, b: $0.rgb.b * b)) })
    }

    static func mix(_ a: GlowProfile, _ b: GlowProfile, _ u: Double) -> GlowProfile {
        let radii = Set(a.stops.map(\.radius) + b.stops.map(\.radius)).sorted()
        return GlowProfile(stops: radii.map { ($0, GlowRGB.lerp(a.sample($0), b.sample($0), u)) })
    }

    /// Draws the light additively, optionally stretched (`scaleX`, `scaleY`) about `center`.
    func draw(
        in context: GraphicsContext,
        at center: CGPoint,
        scaleX: Double = 1,
        scaleY: Double = 1,
        opacity: Double = 1
    ) {
        let outer = outerRadius
        guard outer > 0, opacity > 0.001 else { return }
        var ctx = context
        ctx.blendMode = .plusLighter
        ctx.translateBy(x: center.x, y: center.y)
        ctx.scaleBy(x: scaleX, y: scaleY)
        let gradient = Gradient(stops: stops.map {
            .init(color: $0.rgb.scaled(min(1, opacity)).color, location: $0.radius / outer)
        })
        ctx.fill(
            Path(ellipseIn: CGRect(x: -outer, y: -outer, width: outer * 2, height: outer * 2)),
            with: .radialGradient(gradient, center: .zero, startRadius: 0, endRadius: outer)
        )
    }
}

/// Monotone cubic interpolation through keyframes measured in reference frame numbers.
/// `origin` is the reference frame that is scene time 0, so `value(at: t)` reads frame `origin + 30·t`.
struct FrameTrack {
    let origin: Double
    let frames: [Double]
    let values: [Double]
    private let slopes: [Double]

    init(origin: Double, _ keys: [(Double, Double)]) {
        self.origin = origin
        frames = keys.map(\.0)
        values = keys.map(\.1)
        slopes = Self.monotoneSlopes(frames, values)
    }

    func value(at t: Double) -> Double {
        value(frame: origin + 30 * t)
    }

    func value(frame n: Double) -> Double {
        guard let first = frames.first, let last = frames.last else { return 0 }
        if n <= first { return values[0] }
        if n >= last { return values[values.count - 1] }
        var i = 0
        while i < frames.count - 2 && n > frames[i + 1] { i += 1 }
        let h = frames[i + 1] - frames[i]
        let s = (n - frames[i]) / h
        let s2 = s * s, s3 = s2 * s
        return (2 * s3 - 3 * s2 + 1) * values[i]
            + (s3 - 2 * s2 + s) * h * slopes[i]
            + (-2 * s3 + 3 * s2) * values[i + 1]
            + (s3 - s2) * h * slopes[i + 1]
    }

    private static func monotoneSlopes(_ x: [Double], _ y: [Double]) -> [Double] {
        let n = x.count
        guard n > 1 else { return Array(repeating: 0, count: n) }
        var delta = [Double](repeating: 0, count: n - 1)
        for i in 0..<(n - 1) { delta[i] = (y[i + 1] - y[i]) / (x[i + 1] - x[i]) }
        var m = [Double](repeating: 0, count: n)
        m[0] = delta[0]
        m[n - 1] = delta[n - 2]
        for i in 1..<(n - 1) {
            m[i] = delta[i - 1] * delta[i] <= 0 ? 0 : (delta[i - 1] + delta[i]) / 2
        }
        for i in 0..<(n - 1) where delta[i] == 0 {
            m[i] = 0
            m[i + 1] = 0
        }
        for i in 0..<(n - 1) where delta[i] != 0 {
            let a = m[i] / delta[i], b = m[i + 1] / delta[i]
            let h = a * a + b * b
            if h > 9 {
                let k = 3 / h.squareRoot()
                m[i] = k * a * delta[i]
                m[i + 1] = k * b * delta[i]
            }
        }
        return m
    }
}

/// Glow profiles keyed by reference frame, blended linearly between neighbours.
struct ProfileTrack {
    let origin: Double
    let keys: [(frame: Double, profile: GlowProfile)]

    init(origin: Double, _ keys: [(Double, GlowProfile)]) {
        self.origin = origin
        self.keys = keys.map { ($0.0, $0.1) }
    }

    func profile(at t: Double) -> GlowProfile {
        let n = origin + 30 * t
        guard let first = keys.first, let last = keys.last else { return GlowProfile([]) }
        if n <= first.frame { return first.profile }
        if n >= last.frame { return last.profile }
        var i = 0
        while i < keys.count - 2 && n > keys[i + 1].frame { i += 1 }
        let u = (n - keys[i].frame) / (keys[i + 1].frame - keys[i].frame)
        return GlowProfile.mix(keys[i].profile, keys[i + 1].profile, u)
    }
}

extension GraphicsContext {
    /// Strokes `path` additively with a soft glow built from widening, fading passes.
    func strokeGlow(
        _ path: Path,
        color: GlowRGB,
        opacity: Double,
        width: CGFloat,
        glow: [(width: CGFloat, opacity: Double)] = [(4, 0.22), (9, 0.08)]
    ) {
        guard opacity > 0.001 else { return }
        var ctx = self
        ctx.blendMode = .plusLighter
        for pass in glow {
            ctx.stroke(path, with: .color(color.color(opacity: min(1, opacity * pass.opacity))),
                       style: StrokeStyle(lineWidth: pass.width, lineCap: .round, lineJoin: .round))
        }
        ctx.stroke(path, with: .color(color.color(opacity: min(1, opacity))),
                   style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }
}

/// Per-word reveal timing in reference frames: blur-in from `inFrame` over `inFrames`
/// (ease-out quad), blur-out from `outFrame` over `outFrames` (smoothstep).
struct CaptionWordTiming {
    var inFrame: Double
    var inFrames: Double
    var outFrame: Double
    var outFrames: Double

    func visibility(frame n: Double) -> Double {
        let u = Ease.clamp01((n - inFrame) / inFrames)
        let shown = 1 - (1 - u) * (1 - u)
        return shown * (1 - Ease.smoothstep((n - outFrame) / outFrames))
    }
}

/// "Lead words *accent*" caption with measured per-word timing, centred on x 360 with its
/// baseline at `baselineY`. Words blur in place and never reflow.
struct TimedCaption: View {
    var lead: String
    var accent: String
    var fontSize: CGFloat
    var baselineY: CGFloat
    var frame: Double
    var timings: [CaptionWordTiming]
    var blurRadius: CGFloat = 8

    private var words: [String] {
        lead.split(separator: " ").map(String.init) + [accent]
    }

    var body: some View {
        let words = words
        let space = CaptionReveal.spaceWidth(fontSize: fontSize)
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(Array(words.enumerated()), id: \.offset) { i, word in
                let u = i < timings.count ? timings[i].visibility(frame: frame) : 1
                text(word, isAccent: i == words.count - 1)
                    .fixedSize()
                    .opacity(u)
                    .blur(radius: blurRadius * (1 - u))
                if i < words.count - 1 {
                    Color.clear.frame(width: space, height: 1)
                }
            }
        }
        .fixedSize()
        .alignmentGuide(VerticalAlignment.top) { $0[.firstTextBaseline] }
        .frame(width: 720, height: 1280, alignment: .top)
        .offset(y: baselineY)
        .allowsHitTesting(false)
    }

    private func text(_ word: String, isAccent: Bool) -> Text {
        if isAccent {
            return Text(verbatim: word).font(GlowFonts.serifItalic(size: fontSize)).foregroundColor(GlowTheme.gold)
        }
        return Text(verbatim: word).font(GlowFonts.sans(weight: .regular, size: fontSize)).foregroundColor(.white)
    }
}
