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

    /// Scene length in seconds: the reference frame count / 30.
    public var duration: Double {
        switch self {
        case .spark: 3.467
        case .grow: 2.867
        case .shape: 1.833
        case .details: 2.367
        case .rhythm: 5.133
        case .workflow: 5.1
        case .connects: 3.733
        case .flow: 4.0
        case .outro: 3.167
        }
    }

    /// Reel time at which this scene starts.
    public var reelStart: Double {
        Self.allCases.prefix { $0 != self }.reduce(0) { $0 + $1.duration }
    }

    public static var reelDuration: Double {
        allCases.reduce(0) { $0 + $1.duration }
    }

    /// Resolves a reel time to the scene playing then and the scene-local time.
    public static func locate(reelTime t: Double) -> (scene: GlowScene, localTime: Double) {
        var start = 0.0
        for scene in allCases {
            if t < start + scene.duration { return (scene, max(0, t - start)) }
            start += scene.duration
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
