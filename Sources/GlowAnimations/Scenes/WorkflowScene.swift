import SwiftUI

/// Scene "workflow" as a pure function of scene-local time `t` (seconds), in 720 x 1280 design units.
/// A cream wipe opens from the rhythm dot; "Dream it", "Build it" and "Ship it" pills grow, ignite and
/// get linked by drawn curves and travelling pulses while the camera follows; then the diagram collapses
/// into a point and a black wipe leaves a gold dot for "connects".
/// Spec: docs/storyboard/06-workflow.md (layout, camera and timings re-measured, see WorkflowModel).
public struct WorkflowScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    /// The collapse is fast enough that the reference shows doubled pill edges.
    private static let motionBlur: ClosedRange<Double> = 612.5...616.5

    public var body: some View {
        let model = WorkflowModel(t: t)
        ZStack {
            Color.black
            if model.blackRadius < Self.stageHalfDiagonal {
                diagram(model)
                    .mask {
                        Circle()
                            .frame(width: 2 * model.creamRadius, height: 2 * model.creamRadius)
                            .position(x: 360, y: 640)
                    }
            }
            if model.showsHandoffDot { WorkflowHandoffDot() }
            WorkflowFinale(model: model)
        }
        .frame(width: 720, height: 1280)
    }

    /// Distance from the stage centre to a corner: a wipe this large covers the stage.
    private static let stageHalfDiagonal = 735.0

    @ViewBuilder
    private func diagram(_ model: WorkflowModel) -> some View {
        if Self.motionBlur.contains(model.frame) {
            ForEach(0..<3, id: \.self) { i in
                WorkflowDiagram(model: WorkflowModel(frame: model.frame + 0.2 * Double(i - 1)))
                    .compositingGroup()
                    .opacity(1 / Double(i + 1))
            }
        } else {
            WorkflowDiagram(model: model)
        }
    }
}

/// Everything on the cream: backdrop, seed, links and pills.
private struct WorkflowDiagram: View {
    let model: WorkflowModel

    var body: some View {
        ZStack {
            WorkflowBackdrop()
            if model.showsSeed {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.45), lineWidth: 2).frame(width: 16, height: 16)
                    Circle().fill(WorkflowPalette.seed).frame(width: 11, height: 11)
                }
                .position(x: 360, y: 640)
            }
            Canvas { context, _ in
                WorkflowLinks(model: model).draw(in: &context)
            }
            ForEach(Array(WorkflowPill.all.enumerated().reversed()), id: \.offset) { _, pill in
                let state = model.state(of: pill)
                if state.visible && model.cameraScale > 0.001 {
                    WorkflowPillView(pill: pill, state: state, frame: model.frame, labelsOut: model.labelsOut)
                        .scaleEffect(state.scale)
                        .rotationEffect(.degrees(state.tilt))
                        .position(state.centre)
                }
            }
            mergeFlash
        }
        .frame(width: 720, height: 1280)
    }

    /// The merge flash at f0617, sampled outward from the centre (white to ~20 px, warm cream to ~80 px).
    private static let flashStops: [Gradient.Stop] = [
        .init(color: .white, location: 0), .init(color: .white, location: 0.22),
        .init(color: Color(hex: 0xFFFBE1), location: 0.33), .init(color: Color(hex: 0xFEF3DC), location: 0.49),
        .init(color: Color(hex: 0xFDECDB).opacity(0.85), location: 0.62),
        .init(color: Color(hex: 0xF9E8D8).opacity(0.5), location: 0.78), .init(color: Color(hex: 0xF9E8D8).opacity(0), location: 1),
    ]

    @ViewBuilder
    private var mergeFlash: some View {
        if model.mergeFlash > 0 || model.mergeRing > 0 || model.mergeCore > 0 {
            ZStack {
                Circle()
                    .fill(RadialGradient(stops: Self.flashStops, center: .center, startRadius: 0, endRadius: 90))
                    .frame(width: 180, height: 180)
                    .opacity(model.mergeFlash)
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: 0xFFE798), Color(hex: 0xFBC25D), Color(hex: 0xCB944C).opacity(0)],
                                         center: .center, startRadius: 3, endRadius: 16))
                    .frame(width: 32, height: 32)
                    .opacity(model.mergeCore)
                Circle()
                    .stroke(Color(hex: 0xE4D860), lineWidth: 2.2)
                    .frame(width: 13, height: 13)
                    .opacity(model.mergeRing)
                Circle().fill(Color.white).frame(width: 6, height: 6)
                    .opacity(max(model.mergeFlash, model.mergeRing, model.mergeCore))
            }
            .position(x: 360, y: 640)
        }
    }
}

/// Rhythm's last dot flashing white at t = 0.
private struct WorkflowHandoffDot: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color(hex: 0xE3A53B), Color(hex: 0x593716).opacity(0.6), .clear],
                                     center: .center, startRadius: 18, endRadius: 46))
                .frame(width: 92, height: 92)
            Circle().fill(Color(hex: 0xFFFAF5)).frame(width: 45, height: 45).blur(radius: 1)
            Circle().fill(Color(hex: 0xF8FF70)).frame(width: 12, height: 12).blur(radius: 2)
        }
        .position(x: 360, y: 640)
    }
}

/// The closing black wipe and the gold dot it leaves for "connects".
private struct WorkflowFinale: View {
    let model: WorkflowModel

    var body: some View {
        ZStack {
            if model.blackRadius > 0 {
                Circle().fill(Color.black)
                    .frame(width: 2 * model.blackRadius, height: 2 * model.blackRadius)
                    .position(x: 360, y: 640)
            }
            if model.finalDot > 0 {
                Circle()
                    .fill(RadialGradient(stops: Self.dotStops, center: .center, startRadius: 0, endRadius: 40))
                    .frame(width: 80, height: 80)
                    .opacity(model.finalDot)
                    .position(x: 360, y: 640)
            }
        }
        .frame(width: 720, height: 1280)
    }

    private static let dotStops: [Gradient.Stop] = WorkflowPalette.finalDot.map { r, hex in
        Gradient.Stop(color: Color(hex: hex), location: r / 40)
    }
}
