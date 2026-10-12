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
    /// Seconds of solid `leadInColor` shown before t = 0; the cut to the scene is hard.
    public var leadIn: Double
    public var leadInColor: Color
    /// Drawn above the stage on every display frame with the program time of that frame
    /// (nil during the lead-in). The recording harness uses it for a frame clock.
    public var timeOverlay: ((Double?) -> AnyView)?

    @State private var clock = ProgramClock()

    public init(
        _ program: Program,
        loop: Bool = true,
        startOffset: Double = 0,
        onStageRect: ((CGRect) -> Void)? = nil,
        onStart: ((Date) -> Void)? = nil,
        leadIn: Double = 0,
        leadInColor: Color = .black,
        timeOverlay: ((Double?) -> AnyView)? = nil
    ) {
        self.program = program
        self.loop = loop
        self.startOffset = startOffset
        self.onStageRect = onStageRect
        self.onStart = onStart
        self.leadIn = leadIn
        self.leadInColor = leadInColor
        self.timeOverlay = timeOverlay
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
            let elapsed = clock.elapsed(at: context.date)
            ZStack {
                GlowStage(onStageRect: onStageRect) {
                    frame(at: time(elapsed: elapsed ?? 0))
                }
                if elapsed == nil {
                    leadInColor
                }
                if let timeOverlay {
                    timeOverlay(elapsed.map { time(elapsed: $0) })
                }
            }
        }
        .onAppear { restart() }
        .onChange(of: program) { _, _ in restart() }
    }

    private func restart() {
        let start = Date().addingTimeInterval(leadIn)
        clock.reset(start: start)
        onStart?(start)
    }

    /// Program time for seconds since t = 0, wrapped or clamped to the program duration.
    func time(elapsed seconds: Double) -> Double {
        let elapsed = seconds + startOffset
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

/// Anchors t = 0 to the first display frame at or after the scheduled start, so that frame renders exactly t = 0.
final class ProgramClock {
    private var scheduled = Date()
    private var anchor: Date?

    func reset(start: Date) {
        scheduled = start
        anchor = nil
    }

    /// Seconds since t = 0, or nil while still in the lead-in.
    func elapsed(at date: Date) -> Double? {
        if let anchor { return max(0, date.timeIntervalSince(anchor)) }
        guard date >= scheduled else { return nil }
        anchor = date
        return 0
    }
}
