import SwiftUI

/// Scene 3, "Give it *shape*": the asterisk rises, sends out one ring pulse, then drops and
/// dissolves into the gradient pill that scene 4 grows into a card.
/// Spec: docs/storyboard/03-shape.md. Tracks are keyed by reference reel frame (f0191 = t 0).
public struct ShapeScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    static let startFrame = 191.0

    public var body: some View {
        let frame = Self.startFrame + 30 * t
        ZStack {
            Canvas(rendersAsynchronously: false) { context, _ in
                ShapePainter(frame: frame).paintLights(context)
            }
            .frame(width: 720, height: 1280)

            TimedCaption(
                lead: "Give it",
                accent: "shape",
                fontSize: 44,
                baselineY: 673,
                frame: frame,
                timings: [
                    CaptionWordTiming(inFrame: 196.5, inFrames: 16, outFrame: 239, outFrames: 6),
                    CaptionWordTiming(inFrame: 202, inFrames: 16, outFrame: 240.5, outFrames: 6),
                    CaptionWordTiming(inFrame: 205.5, inFrames: 21, outFrame: 242, outFrames: 7),
                ]
            )
            .blendMode(.plusLighter)

            Canvas(rendersAsynchronously: false) { context, _ in
                ShapePainter(frame: frame).paintPill(context)
            }
            .frame(width: 720, height: 1280)
        }
        .frame(width: 720, height: 1280)
    }
}

private struct ShapePainter {
    let frame: Double

    private var t: Double { (frame - ShapeScene.startFrame) / 30 }

    // MARK: Asterisk

    private static let asteriskY = FrameTrack(origin: 0, [
        (190, 640), (191, 620.4), (192, 601), (193, 588.3), (194, 580), (195, 574.4), (196, 570.8),
        (198, 566.7), (200, 565), (204, 564), (239, 564), (240, 566), (241, 577), (242, 596),
        (243, 619), (244, 630), (245, 640),
    ])

    private static let asteriskScale = FrameTrack(origin: 0, [(240, 1), (242, 0.94), (243, 0.88), (244, 0.8), (245, 0.5)])

    private var asteriskCenter: CGPoint {
        CGPoint(x: 360, y: Self.asteriskY.value(frame: frame))
    }

    func paintLights(_ context: GraphicsContext) {
        drawPulse(context)
        let breathing = 1 + 0.1 * sin(2 * .pi * max(0, t - 0.3))
        AsteriskRenderer(
            center: asteriskCenter,
            tip: GrowGeometry.tipRadius.value(frame: 190),
            valley: GrowGeometry.valleyRadius.value(frame: 190),
            exponent: GrowGeometry.petalExponent.value(frame: 190),
            angle: GrowGeometry.petalAngle(frame: frame),
            halo: breathing,
            scale: Self.asteriskScale.value(frame: frame)
        ).draw(in: context, opacity: 1)
    }

    // MARK: Ring pulse

    private static let pulseStart = 209.0
    private static let pulseAlpha = FrameTrack(origin: 0, [
        (209, 0), (210, 0.8), (211, 1), (214, 0.62), (217, 0.5), (220, 0.45), (223, 0.42),
        (226, 0.33), (229, 0.27), (232, 0.19), (235, 0.1), (238, 0),
    ])
    private static let pulseGlow = FrameTrack(origin: 0, [(209, 1), (216, 1), (222, 0.3), (230, 0.2)])

    private func drawPulse(_ context: GraphicsContext) {
        let alpha = Self.pulseAlpha.value(frame: frame)
        guard alpha > 0.001 else { return }
        let tau = (frame - Self.pulseStart) / 30
        let r = 35 + 88 * (1 - exp(-tau / 0.45))
        let c = CGPoint(x: 360, y: 564)
        let path = Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
        let glow = Self.pulseGlow.value(frame: frame)
        var ctx = context
        ctx.blendMode = .plusLighter
        let colour = GlowRGB(hex: 0xFFCC91)
        let passes: [(CGFloat, Double)] = [(12, 0.07 * glow), (5, 0.2 * glow), (1.3, 1.0)]
        for (width, a) in passes {
            ctx.stroke(path, with: .color(colour.color(opacity: min(1, alpha * a))), style: StrokeStyle(lineWidth: width))
        }
    }

    // MARK: Pill (drawn over the caption, as on the reference)

    private static let pillWidth = FrameTrack(origin: 0, [(243.5, 38), (244, 96), (245, 234), (246, 303)])

    func paintPill(_ context: GraphicsContext) {
        guard frame >= 243.5 else { return }
        let width = Self.pillWidth.value(frame: frame)
        PillRenderer(center: CGPoint(x: 360, y: 640), width: width, height: 38).draw(in: context)
    }
}

/// The pink→orange capsule scene 4 takes over (colours sampled at f0246).
struct PillRenderer {
    var center: CGPoint
    var width: Double
    var height: Double

    static let gradient = Gradient(stops: [
        .init(color: GlowRGB(hex: 0xFA7488).color, location: 0),
        .init(color: GlowRGB(hex: 0xFD8172).color, location: 0.17),
        .init(color: GlowRGB(hex: 0xFA7E64).color, location: 0.30),
        .init(color: GlowRGB(hex: 0xF07E46).color, location: 0.50),
        .init(color: GlowRGB(hex: 0xE57F2D).color, location: 0.70),
        .init(color: GlowRGB(hex: 0xE17F2B).color, location: 0.83),
        .init(color: GlowRGB(hex: 0xDA8432).color, location: 1),
    ])

    func draw(in context: GraphicsContext) {
        let rect = CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
        let capsule = Path(roundedRect: rect, cornerRadius: height / 2)
        var bloom = context
        bloom.blendMode = .plusLighter
        bloom.drawLayer { layer in
            layer.addFilter(.blur(radius: 14))
            layer.opacity = 0.55
            layer.fill(capsule, with: .color(GlowRGB(hex: 0x5A1610).color))
        }
        let shading = GraphicsContext.Shading.linearGradient(
            Self.gradient, startPoint: CGPoint(x: rect.minX, y: 0), endPoint: CGPoint(x: rect.maxX, y: 0))
        context.fill(capsule, with: shading)
        let rim = Path(roundedRect: rect.insetBy(dx: 0.75, dy: 0.75), cornerRadius: height / 2 - 0.75)
        context.stroke(rim, with: .color(.white.opacity(0.12)), lineWidth: 1.5)
    }
}
