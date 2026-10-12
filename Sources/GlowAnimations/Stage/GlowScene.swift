import SwiftUI

/// The nine scenes of the reel, in playback order.
public enum GlowScene: String, CaseIterable, Identifiable, Sendable {
    case spark, grow, shape, details, rhythm, workflow, connects, flow, outro

    public var id: String { rawValue }

    /// English name. Apps should localise their own copy; the package ships no strings.
    public var displayName: String {
        switch self {
        case .spark: "Spark"
        case .grow: "Grow"
        case .shape: "Shape"
        case .details: "Details"
        case .rhythm: "Rhythm"
        case .workflow: "Workflow"
        case .connects: "Connects"
        case .flow: "Flow"
        case .outro: "Outro"
        }
    }

    public static let frameRate = 30.0

    /// Scene length in reference frames at 30 fps.
    public var frameCount: Int {
        switch self {
        case .spark: 104
        case .grow: 86
        case .shape: 55
        case .details: 71
        case .rhythm: 154
        case .workflow: 153
        case .connects: 112
        case .flow: 120
        case .outro: 95
        }
    }

    /// Scene length in seconds.
    public var duration: Double { Double(frameCount) / Self.frameRate }

    /// First reel frame of this scene, 0-based.
    public var firstFrame: Int {
        Self.allCases.prefix { $0 != self }.reduce(0) { $0 + $1.frameCount }
    }

    /// Reel time at which this scene starts.
    public var reelStart: Double { Double(firstFrame) / Self.frameRate }

    public static var frameCount: Int { allCases.reduce(0) { $0 + $1.frameCount } }

    public static var reelDuration: Double { Double(frameCount) / frameRate }

    /// Resolves a reel time to the scene playing then and the scene-local time.
    /// Boundaries are exact frame counts, so reel frame k always lands in the scene that
    /// owns reference frame k; a 0.1 ms tolerance absorbs clock rounding at the boundary.
    public static func locate(reelTime t: Double) -> (scene: GlowScene, localTime: Double) {
        let frames = t * frameRate + 1e-4 * frameRate
        for scene in allCases {
            let start = Double(scene.firstFrame)
            if frames < start + Double(scene.frameCount) {
                return (scene, max(0, t - scene.reelStart))
            }
        }
        let last = allCases[allCases.count - 1]
        return (last, last.duration)
    }
}

/// Renders one scene at scene-local time `t` (seconds), with the reel title on top.
public struct GlowSceneView: View {
    public var scene: GlowScene
    public var t: Double
    public var showsTitle: Bool

    public init(scene: GlowScene, t: Double, showsTitle: Bool = true) {
        self.scene = scene
        self.t = t
        self.showsTitle = showsTitle
    }

    public var body: some View {
        ZStack {
            content
            if showsTitle { ReelTitle() }
        }
        .frame(width: 720, height: 1280)
    }

    @ViewBuilder
    private var content: some View {
        switch scene {
        case .spark: SparkScene(t: t)
        case .grow: GrowScene(t: t)
        case .shape: ShapeScene(t: t)
        case .details: DetailsScene(t: t)
        case .rhythm: RhythmScene(t: t)
        case .workflow: WorkflowScene(t: t)
        case .connects: ConnectsScene(t: t)
        case .flow: FlowScene(t: t)
        case .outro: OutroScene(t: t)
        }
    }
}

/// Plays all nine scenes back to back at reel time `t`.
public struct GlowReelView: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        let (scene, local) = GlowScene.locate(reelTime: t)
        GlowSceneView(scene: scene, t: local)
    }
}
