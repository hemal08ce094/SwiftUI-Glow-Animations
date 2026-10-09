import SwiftUI

/// Hosts a scene drawn in the 720 x 1280 design-unit space and letterboxes it,
/// uniformly scaled and centred, inside whatever frame it is given.
public struct GlowStage<Content: View>: View {
    public static var designSize: CGSize { CGSize(width: 720, height: 1280) }

    private let background: Color
    private let onStageRect: ((CGRect) -> Void)?
    private let content: Content

    /// - Parameter onStageRect: receives the visible stage rect in global points
    ///   whenever layout changes (the recording harness logs it).
    public init(
        background: Color = GlowTheme.black,
        onStageRect: ((CGRect) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.background = background
        self.onStageRect = onStageRect
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geo in
            let design = Self.designSize
            let scale = min(geo.size.width / design.width, geo.size.height / design.height)
            let stageSize = CGSize(width: design.width * scale, height: design.height * scale)
            let frame = geo.frame(in: .global)
            let rect = CGRect(
                x: frame.minX + (geo.size.width - stageSize.width) / 2,
                y: frame.minY + (geo.size.height - stageSize.height) / 2,
                width: stageSize.width,
                height: stageSize.height
            )

            ZStack {
                ZStack {
                    background
                    content
                }
                .frame(width: design.width, height: design.height)
                .scaleEffect(scale)
                .frame(width: stageSize.width, height: stageSize.height)
                .clipped()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { onStageRect?(rect) }
            .onChange(of: rect) { _, new in onStageRect?(new) }
        }
        .onAppear { GlowFonts.registerIfNeeded() }
    }
}
