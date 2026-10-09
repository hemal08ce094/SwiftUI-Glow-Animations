import SwiftUI

/// Drives a scene or the whole reel from the display clock and shows it in a `GlowStage`.
/// Time starts at `startOffset` when the player first appears.
public struct GlowPlayer: View {
    public enum Program: Hashable, Sendable {
        case scene(GlowScene)
        case reel

        public var duration: Double {
            switch self {
            case .scene(let scene): scene.duration
            case .reel: GlowScene.reelDuration
            }
        }
    }

    public var program: Program
    public var loop: Bool
    public var startOffset: Double
    public var onStageRect: ((CGRect) -> Void)?
    /// Called with the wall-clock date that maps to program time `startOffset`.
    public var onStart: ((Date) -> Void)?

    @State private var startDate = Date()

    public init(
        _ program: Program,
        loop: Bool = true,
        startOffset: Double = 0,
        onStageRect: ((CGRect) -> Void)? = nil,
        onStart: ((Date) -> Void)? = nil
    ) {
        self.program = program
        self.loop = loop
        self.startOffset = startOffset
        self.onStageRect = onStageRect
        self.onStart = onStart
    }

    public init(scene: GlowScene, loop: Bool = true, startOffset: Double = 0) {
        self.init(.scene(scene), loop: loop, startOffset: startOffset)
    }

    /// Plays the full reel. Pass `GlowPlayer(reel: (), loop: ...)` or use `GlowPlayer(.reel)`.
    public init(reel: Void, loop: Bool = true, startOffset: Double = 0) {
        self.init(.reel, loop: loop, startOffset: startOffset)
    }

    public var body: some View {
        TimelineView(.animation) { context in
            GlowStage(onStageRect: onStageRect) {
                frame(at: time(at: context.date))
            }
        }
        .onAppear { restart() }
        .onChange(of: program) { _, _ in restart() }
    }

    private func restart() {
        let now = Date()
        startDate = now
        onStart?(now)
    }

    /// Program time for a display-clock date, wrapped or clamped to the program duration.
    func time(at date: Date) -> Double {
        let elapsed = max(0, date.timeIntervalSince(startDate)) + startOffset
        let duration = program.duration
        guard duration > 0 else { return 0 }
        return loop ? elapsed.truncatingRemainder(dividingBy: duration) : min(elapsed, duration)
    }

    @ViewBuilder
    private func frame(at t: Double) -> some View {
        switch program {
        case .scene(let scene): GlowSceneView(scene: scene, t: t)
        case .reel: GlowReelView(t: t)
        }
    }
}
