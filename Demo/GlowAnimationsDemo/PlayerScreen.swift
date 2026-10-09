import GlowAnimations
import SwiftUI

/// Full-screen black player. Tap toggles a small overlay; chromeless mode (recording) shows
/// nothing but the stage after a 1 s green sync pre-roll and logs the stage rect for tools/record.sh.
struct PlayerScreen: View {
    var program: GlowPlayer.Program
    var chromeless: Bool
    var onClose: (() -> Void)?

    @State private var loop = true
    @State private var showsControls = false
    @State private var runID = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GlowPlayer(program, loop: loop, onStageRect: { rect in
                guard chromeless else { return }
                HarnessLog.line(String(format: "GLOW_STAGE_RECT %.2f %.2f %.2f %.2f", rect.minX, rect.minY, rect.width, rect.height))
            }, onStart: { date in
                guard chromeless else { return }
                HarnessLog.line(String(format: "GLOW_T0 %.4f", date.timeIntervalSince1970))
            }, leadIn: chromeless ? 1.0 : 0, leadInColor: HarnessLog.syncGreen)
            .id(runID)
            .ignoresSafeArea()
            .accessibilityElement()
            .accessibilityLabel(program.localizedName)
            .accessibilityHint(chromeless ? Text(verbatim: "") : Text("Shows or hides the playback controls"))
            .accessibilityAddTraits(.isButton)

            if showsControls && !chromeless {
                controls
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !chromeless else { return }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) { showsControls.toggle() }
        }
        .statusBarHidden(chromeless || !showsControls)
        .persistentSystemOverlays(chromeless ? .hidden : .automatic)
        .preferredColorScheme(.dark)
    }

    private var controls: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(Text("Close"))
                }

                program.localizedName
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Button { runID += 1 } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(Text("Restart"))

                Toggle(isOn: $loop) { Text("Loop") }
                    .toggleStyle(.button)
                    .fixedSize()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)

            Spacer()
        }
        .tint(GlowTheme.gold)
    }
}

/// Unbuffered stderr lines parsed by tools/record.sh.
enum HarnessLog {
    /// Pre-roll colour tools/record.sh detects; the first non-green frame is t = 0.
    static let syncGreen = Color(.sRGB, red: 0, green: 1, blue: 0)

    static func line(_ text: String) {
        FileHandle.standardError.write(Data((text + "\n").utf8))
    }
}
