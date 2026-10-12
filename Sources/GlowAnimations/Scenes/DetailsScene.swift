import SwiftUI

/// Scene "details" as a pure function of scene-local time `t` (seconds), in 720 x 1280 design units.
/// The pill left by "shape" grows into a glowing card, gains its text, rocks in 3-D, catches a sheen
/// and swings edge-on. Spec: docs/storyboard/04-details.md (times there start two frames earlier).
public struct DetailsScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    /// From f0313 the swing is fast enough that the reference shows a smeared, multi-exposure card;
    /// the shutter is centred on the frame time.
    private static let motionBlurFrom = 312.5
    private static let shutterFrames = 0.35
    private static let shutterSamples = 4

    public var body: some View {
        let state = DetailsCardState(t: t)
        ZStack {
            if state.frame < Self.motionBlurFrom {
                DetailsCardLayer(state: state)
            } else {
                ForEach(0..<Self.shutterSamples, id: \.self) { i in
                    let offset = Self.shutterFrames * (Double(i) / Double(Self.shutterSamples - 1) - 0.5)
                    DetailsCardLayer(state: DetailsCardState(frame: state.frame + offset))
                        .compositingGroup()
                        .opacity(1 / Double(i + 1))
                }
            }
        }
        .frame(width: 720, height: 1280)
    }
}
