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

    /// Scene length in seconds. Placeholders until each scene is implemented from its storyboard.
    public var duration: Double {
        switch self {
        case .spark: 3.5
        case .grow: 3.2
        case .shape: 1.6
        case .details: 2.3
        case .rhythm: 5.0
        case .workflow: 5.2
        case .connects: 3.8
        case .flow: 4.2
        case .outro: 3.0
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

/// Renders one scene at scene-local time `t` (seconds).
public struct GlowSceneView: View {
    public var scene: GlowScene
    public var t: Double

    public init(scene: GlowScene, t: Double) {
        self.scene = scene
        self.t = t
    }

    public var body: some View {
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
