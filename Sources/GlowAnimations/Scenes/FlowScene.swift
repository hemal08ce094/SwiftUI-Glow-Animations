import SwiftUI

/// Scene "flow" as a pure function of scene-local time `t` (seconds), in 720 x 1280 design units.
/// Spec: docs/storyboard/. Currently a stub.
public struct FlowScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        SceneStub(scene: .flow, t: t)
    }
}
