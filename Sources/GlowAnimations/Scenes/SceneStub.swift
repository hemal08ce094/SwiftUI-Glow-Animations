import SwiftUI

/// Temporary placeholder drawn by every scene until it is implemented: a blooming gold
/// dot crossing the stage over the scene's duration, the scene name and a time readout.
/// Delete a scene's use of it once the real scene lands.
struct SceneStub: View {
    var scene: GlowScene
    var t: Double

    var body: some View {
        let p = Ease.easeInOut(t / scene.duration)
        let x = Ease.lerp(120, 600, p)
        let y = 640 + 180 * sin(p * .pi * 2)

        ZStack {
            Circle()
                .fill(GlowTheme.gold)
                .frame(width: 36, height: 36)
                .bloom(radius: 60, intensity: 1.2)
                .position(x: x, y: y)

            CaptionText("Stub:", accent: scene.displayName.lowercased(), fontSize: 52)
                .position(x: 360, y: 300)

            Text(verbatim: String(format: "t = %.2f s", t))
                .font(GlowFonts.sans(weight: .light, size: 32))
                .monospacedDigit()
                .foregroundStyle(GlowTheme.cream.opacity(0.7))
                .position(x: 360, y: 1040)
        }
        .frame(width: 720, height: 1280)
    }
}
