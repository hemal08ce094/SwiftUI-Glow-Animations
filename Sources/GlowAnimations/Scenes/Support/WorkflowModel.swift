import SwiftUI

/// The "Dream it → Build it → Ship it" diagram as laws of the reference frame number
/// (f0471 = scene t 0). Positions are in unscaled diagram units relative to the Dream pill centre;
/// the camera maps them to the stage. Every table is measured on reference/frames30.
struct WorkflowModel {
    static let firstFrame = 471.0

    let frame: Double

    init(t: Double) { frame = Self.firstFrame + t * 30 }
    init(frame: Double) { self.frame = frame }

    // MARK: Camera

    /// Dream centre on stage and diagram scale, measured per frame on the reference.
    private static let cameraKeys: [(Double, Double, Double, Double)] = [
        (497, 360, 641.5, 1.0), (501, 359.5, 642.0, 1.0), (503, 359.5, 642.0, 0.970),
        (505, 359.5, 642.5, 0.932), (507, 359.5, 643.0, 0.924), (509, 360.0, 642.0, 0.936),
        (511, 359.0, 638.5, 0.951), (513, 356.0, 631.5, 0.950), (515, 350.5, 622.5, 0.947),
        (517, 343.0, 610.5, 0.943), (519, 333.5, 596.0, 0.943), (521, 323.0, 580.5, 0.943),
        (523, 311.5, 564.0, 0.943), (525, 300.0, 546.5, 0.943), (527, 288.0, 530.0, 0.943),
        (529, 277.0, 514.5, 0.943), (531, 267.0, 501.5, 0.943), (533, 259.0, 492.0, 0.943),
        (535, 252.0, 480.0, 0.943), (537, 248.0, 474.0, 0.943), (539, 246.0, 471.5, 0.943),
        (541, 246.0, 470.5, 0.943), (544, 246.0, 466.5, 0.943), (547, 246.0, 461.5, 0.943),
        (550, 246.0, 457.5, 0.943), (553, 246.0, 456.0, 0.943), (555, 246.0, 450.5, 0.943),
        (557, 246.0, 441.0, 0.943), (559, 246.5, 428.0, 0.945), (561, 246.5, 412.0, 0.945),
        (563, 247.0, 393.5, 0.943), (565, 247.0, 373.0, 0.943), (567, 247.5, 351.5, 0.943),
        (569, 248.5, 330.0, 0.943), (571, 248.5, 309.5, 0.943), (573, 248.5, 290.0, 0.943),
        (575, 249.0, 273.0, 0.943), (577, 249.0, 260.0, 0.943), (579, 249.0, 250.0, 0.943),
        (581, 249.5, 243.5, 0.945), (583, 250.0, 243.0, 0.943), (585, 251.0, 250.5, 0.936),
        (587, 253.5, 265.0, 0.917), (589, 256.5, 286.0, 0.894), (591, 260.5, 311.0, 0.850),
        (593, 265.0, 337.0, 0.833), (595, 269.0, 361.0, 0.807), (597, 272.0, 381.0, 0.784),
        (599, 275.0, 397.0, 0.769),
    ]
    private static let camX = MeasuredKeyframes(cameraKeys.map { ($0.0, $0.1) })
    private static let camY = MeasuredKeyframes(cameraKeys.map { ($0.0, $0.2) })
    private static let camScale = MeasuredKeyframes(cameraKeys.map { ($0.0, $0.3) })
    /// From f0600 the diagram is framed about its own centre (Dream + (110, 311)), then collapses into it.
    private static let framedScale = MeasuredKeyframes([
        (599, 0.769), (600, 0.761), (602, 0.754), (604, 0.754), (606, 0.769), (608, 0.795), (609, 0.800),
        (610, 0.790), (611, 0.758), (612, 0.700), (613, 0.617), (614, 0.480), (615, 0.318), (616, 0.06), (616.6, 0),
    ])
    static let diagramCentre = CGPoint(x: 110, y: 311)

    var cameraScale: Double { frame < 599.5 ? Self.camScale(frame) : Self.framedScale(frame) }
    var cameraOrigin: CGPoint {
        if frame < 599.5 { return CGPoint(x: Self.camX(frame), y: Self.camY(frame)) }
        let s = cameraScale
        return CGPoint(x: 360 - Self.diagramCentre.x * s, y: 640 - Self.diagramCentre.y * s)
    }

    func toStage(_ p: CGPoint) -> CGPoint {
        let o = cameraOrigin, s = cameraScale
        return CGPoint(x: o.x + p.x * s, y: o.y + p.y * s)
    }

    // MARK: Wipes and the seed

    private static let creamRadius = MeasuredKeyframes([
        (471.5, 22), (472, 62.5), (473, 139.5), (474, 273.5), (475, 487), (476, 800),
    ])
    var showsHandoffDot: Bool { frame < 471.5 }
    var creamRadius: Double { Self.creamRadius(frame) }
    var showsSeed: Bool { frame >= 471.5 && frame < 482.5 }

    private static let blackRadius = MeasuredKeyframes([
        (618.4, 0), (619, 36), (620, 88), (621, 186), (622, 348), (623, 599), (624, 900),
    ])
    var blackRadius: Double { frame < 618.4 ? 0 : Self.blackRadius(frame) }
    var finalDot: Double { Ease.progress(frame, 618.2, 618.8) }
    private static let mergeFlash = MeasuredKeyframes([(615.5, 0), (616, 1), (617, 1), (618, 0.9), (618.8, 0)])
    private static let mergeCore = MeasuredKeyframes([(615.4, 0), (616, 1), (616.8, 0)])
    var mergeCore: Double { Self.mergeCore(frame) }
    var mergeFlash: Double { Self.mergeFlash(frame) }
    private static let mergeRing = MeasuredKeyframes([(617.2, 0), (618, 1), (618.8, 0)])
    var mergeRing: Double { Self.mergeRing(frame) }

    // MARK: Curves, pulses and glints

    var curve1Draw: Double { Self.easeOutQuad((frame - 508.5) / 12.5) }
    var curve2Draw: Double { Self.easeOutQuad((frame - 548.2) / 13) }
    var pen1: Bool { frame > 508.5 && frame < 521.5 }
    var pen2: Bool { frame > 548.2 && frame < 562 }

    /// Pulse position along its curve (0...1) and its visibility.
    var pulse1: (u: Double, alpha: Double) {
        (Self.sineInOut((frame - 532.5) / 9.5), Ease.progress(frame, 529.5, 532) * (1 - Ease.progress(frame, 542.5, 543.5)))
    }
    var pulse2: (u: Double, alpha: Double) {
        (Self.sineInOut((frame - 574) / 9), Ease.progress(frame, 570.5, 573) * (1 - Ease.progress(frame, 583, 584)))
    }
    /// How much of each curve has been recoloured by its pulse.
    var curve1Lit: Double { frame < 532.5 ? 0 : pulse1.u }
    var curve2Lit: Double { frame < 574 ? 0 : pulse2.u }

    /// Small sparks riding both lit curves, three per curve.
    var glintAlpha: Double { Ease.progress(frame, 590, 593) * (1 - Ease.progress(frame, 604, 607)) }
    func glintPositions() -> [Double] {
        let phase = (frame - 590) / 18
        return (0..<3).map { k in (phase + Double(k) / 3).truncatingRemainder(dividingBy: 1) }
    }

    /// Labels, icons and sparks blur away together near the end.
    var labelsOut: Double { Ease.progress(frame, 606, 609.5) }

    static func easeOutQuad(_ x: Double) -> Double { let p = 1 - Ease.clamp01(x); return 1 - p * p }
    static func sineInOut(_ x: Double) -> Double { 0.5 - 0.5 * cos(.pi * Ease.clamp01(x)) }
}

/// One pill of the diagram: fixed layout plus its measured timeline.
struct WorkflowPill {
    enum Icon { case moon, code, arrow }

    let label: String
    let icon: Icon
    /// Centre relative to the Dream centre, unscaled.
    let offset: CGPoint
    let size: CGSize
    let fontSize: CGFloat
    let growStart: Double
    let growth: MeasuredKeyframes
    let growthTilt: Double
    let iconStart: Double
    let labelStart: Double
    let sweepStart: Double
    /// Ship stays lit: its decay is frozen at this many frames after the sweep until `holdUntil`.
    let holdLitAt: Double?
    let holdUntil: Double

    static let dreamGrowth = MeasuredKeyframes([
        (0, 0), (1, 0.06), (2, 0.18), (3, 0.31), (4, 0.47), (5, 0.60), (6, 0.73), (7, 0.83), (8, 0.91),
        (9, 0.96), (10, 0.99), (11, 1.015), (13, 1.015), (14, 1.008), (15, 1),
    ])
    static let laterGrowth = MeasuredKeyframes([
        (0, 0), (1, 0.061), (2, 0.146), (3, 0.277), (4, 0.427), (5, 0.573), (6, 0.704), (7, 0.817),
        (8, 0.906), (9, 0.972), (10, 1.014), (11, 1.042), (12, 1.052), (13, 1.052), (15, 1.03), (18, 1),
    ])

    static let dream = WorkflowPill(
        label: "Dream it", icon: .moon, offset: .zero, size: CGSize(width: 264, height: 92), fontSize: 38.5,
        growStart: 482, growth: dreamGrowth, growthTilt: 0, iconStart: 487.5, labelStart: 490.5,
        sweepStart: 500.2, holdLitAt: nil, holdUntil: 0
    )
    static let build = WorkflowPill(
        label: "Build it", icon: .code, offset: CGPoint(x: 211, y: 308), size: CGSize(width: 236, height: 92),
        fontSize: 40.5, growStart: 521, growth: laterGrowth, growthTilt: 3, iconStart: 526, labelStart: 531,
        sweepStart: 545, holdLitAt: nil, holdUntil: 0
    )
    static let ship = WorkflowPill(
        label: "Ship it", icon: .arrow, offset: CGPoint(x: 7, y: 614), size: CGSize(width: 231, height: 92),
        fontSize: 40.5, growStart: 562, growth: laterGrowth, growthTilt: 3, iconStart: 568, labelStart: 569.5,
        sweepStart: 585, holdLitAt: 12, holdUntil: 605
    )
    static let all = [dream, build, ship]
}

/// The measured colour of a pill's fill: the ignite sweep and its slow decay back to the dark fill.
enum WorkflowFill {
    static let dark: UInt32 = 0x150E0C
    static let sweepFrames = 6.3

    /// Colour at a given distance (px, unscaled) behind the sweeping edge.
    private static let behindEdge: [(Double, UInt32)] = [
        (0, 0xF2801A), (40, 0xED7421), (80, 0xE66420), (120, 0xE04F23), (160, 0xD23D27), (200, 0xB0322A), (280, 0x9A2A27),
    ]
    /// Left, middle and right colours after the sweep, by frames since the sweep started.
    private static let decay: [(Double, UInt32, UInt32, UInt32)] = [
        (6.3, 0x9A2A27, 0xDF511F, 0xF17A19), (8, 0x8B2724, 0xDA4222, 0xE96821), (10, 0x832527, 0xD83F25, 0xE56020),
        (12, 0x7E2326, 0xD43D25, 0xE55B20), (15, 0x762125, 0xCA3926, 0xDE5721), (18, 0x642020, 0xA33125, 0xB3461B),
        (21, 0x4D1D1B, 0x72241B, 0x7E3216), (24, 0x2F1412, 0x3D1610, 0x421D0E), (27, 0x1B100E, 0x170E0B, 0x170E0A),
        (30, dark, dark, dark),
    ]

    /// The pill fill `since` frames after the sweep started, as a horizontal gradient over the pill.
    static func gradient(since: Double, width: Double) -> LinearGradient {
        guard since > 0 else { return LinearGradient(colors: [Color(hex: dark)], startPoint: .leading, endPoint: .trailing) }
        if since < sweepFrames {
            let edge = -10 + (width + 20) * since / sweepFrames
            let far = behindEdge[behindEdge.count - 1].0
            let span = far + 30
            var stops = behindEdge.reversed().map { d, hex in
                Gradient.Stop(color: Color(hex: hex), location: (far - d) / span)
            }
            stops.append(.init(color: Color(hex: dark), location: 1))
            return LinearGradient(stops: stops,
                                  startPoint: UnitPoint(x: (edge - far) / width, y: 0.5),
                                  endPoint: UnitPoint(x: (edge + 30) / width, y: 0.5))
        }
        let (l, m, r) = decayColours(since)
        return LinearGradient(colors: [l, m, r], startPoint: .leading, endPoint: .trailing)
    }

    /// 1 while lit orange, fading to 0 as the fill returns to dark.
    static func glow(since: Double) -> Double {
        guard since > 0 else { return 0 }
        return Ease.clamp01(since / 2) * (1 - Ease.progress(since, 12, 24))
    }

    private static func decayColours(_ since: Double) -> (Color, Color, Color) {
        let s = max(since, decay[0].0)
        var i = 0
        while i < decay.count - 2 && decay[i + 1].0 < s { i += 1 }
        let a = decay[i], b = decay[i + 1]
        let p = Ease.clamp01((s - a.0) / (b.0 - a.0))
        return (mix(a.1, b.1, p), mix(a.2, b.2, p), mix(a.3, b.3, p))
    }

    static func mix(_ a: UInt32, _ b: UInt32, _ p: Double) -> Color {
        func ch(_ v: UInt32, _ s: UInt32) -> Double { Double((v >> s) & 0xFF) / 255 }
        return Color(.sRGB,
                     red: ch(a, 16) + (ch(b, 16) - ch(a, 16)) * p,
                     green: ch(a, 8) + (ch(b, 8) - ch(a, 8)) * p,
                     blue: ch(a, 0) + (ch(b, 0) - ch(a, 0)) * p)
    }

}

extension WorkflowModel {
    struct PillState {
        var centre: CGPoint
        var size: CGSize
        var scale: Double
        var tilt: Double
        var fill: LinearGradient
        var lit: Double
        var halo: (inset: Double, opacity: Double)
        var iconReveal: Double
        var visible: Bool
    }

    func state(of pill: WorkflowPill) -> PillState {
        let k = frame - pill.growStart
        let g = pill.growth(k)
        let seed = 10.0
        let w = seed + (pill.size.width - seed) * g
        let h = seed + (pill.size.height - seed) * min(g, 1.01)

        var since = frame - pill.sweepStart
        if let hold = pill.holdLitAt, since > hold {
            since = frame < pill.holdUntil ? hold : hold + (frame - pill.holdUntil) * (30 - hold) / 5
        }
        let widthForFill = pill.size.width

        let pop: Double
        let popTilt: Double
        if pill.offset == .zero {
            pop = 1
            popTilt = 2.6 * sin(.pi * Ease.progress(frame, 499.5, 507))
        } else {
            let d = frame - pill.sweepStart
            pop = d > 0 ? 1 + 0.0623 * exp(-0.196 * d) * sin(.pi * d / 5) : 1
            popTilt = d > 0 ? 2.0 * sin(.pi * Ease.clamp01(d / 7)) : 0
        }
        let growTilt = pill.growthTilt * sin(.pi * Ease.clamp01(k / 14))
        let haloAge = frame - pill.sweepStart
        let halo = haloAge > 0 && haloAge < 16
            ? (inset: -(4 + 18 * Ease.easeOut(haloAge / 16)), opacity: 0.55 * (1 - haloAge / 16))
            : (inset: 0.0, opacity: 0.0)

        return PillState(
            centre: toStage(pill.offset),
            size: CGSize(width: w, height: h),
            scale: cameraScale * pop,
            tilt: growTilt + popTilt,
            fill: WorkflowFill.gradient(since: since, width: widthForFill),
            lit: WorkflowFill.glow(since: since),
            halo: halo,
            iconReveal: Ease.progress(frame, pill.iconStart, pill.iconStart + 3) * (1 - labelsOut),
            visible: k > 0
        )
    }
}
