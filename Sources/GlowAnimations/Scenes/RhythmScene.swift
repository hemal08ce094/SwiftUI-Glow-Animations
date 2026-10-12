import SwiftUI

/// Scene "rhythm" as a pure function of scene-local time `t` (seconds), in 720 x 1280 design units.
/// The edge-on card swings down into a baseline, eight dots and arcs appear, a pendulum wave runs
/// under "Find your *rhythm*", then everything collapses into one gold dot at the stage centre.
/// Spec: docs/storyboard/05-rhythm.md (geometry and swing law re-measured, see RhythmModel).
public struct RhythmScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        let model = RhythmModel(t: t)
        ZStack {
            Canvas { context, _ in
                RhythmRenderer(model: model).draw(in: &context)
            }
            RhythmCaption(frame: model.frame)
        }
        .frame(width: 720, height: 1280)
    }
}
