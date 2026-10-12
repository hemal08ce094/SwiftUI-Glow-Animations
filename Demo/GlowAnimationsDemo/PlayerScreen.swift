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
            }, leadIn: chromeless ? 1.0 : 0, leadInColor: HarnessLog.syncGreen,
               timeOverlay: chromeless ? { time in AnyView(TimecodeStrip(time: time)) } : nil)
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

/// Frame clock tools/record.sh reads from the top letterbox bar, outside the 9:16 crop.
/// 24 cells, left to right: white, black, 20 bits of program time in 1/120 s (MSB first),
/// even parity, white. Hidden during the lead-in, so a frame with no valid clock is ignored.
struct TimecodeStrip: View {
    var time: Double?

    static let ticksPerSecond = 120.0
    static let bitCount = 20
    static let cellCount = bitCount + 4
    static let top: CGFloat = 8
    static let height: CGFloat = 32

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                guard let time else { return }
                let cellWidth = size.width / CGFloat(Self.cellCount)
                for (i, on) in Self.cells(for: time).enumerated() {
                    let rect = CGRect(x: CGFloat(i) * cellWidth, y: 0, width: cellWidth, height: size.height)
                    context.fill(Path(rect), with: .color(on ? .white : .black))
                }
            }
            .frame(width: geo.size.width, height: Self.height)
            .offset(y: Self.top)
            .onAppear {
                let frame = geo.frame(in: .global)
                HarnessLog.line(String(
                    format: "GLOW_TIMECODE_RECT %.0f %.0f %.0f %.0f",
                    frame.minX * displayScale, (frame.minY + Self.top) * displayScale,
                    frame.width * displayScale, Self.height * displayScale))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    static func cells(for time: Double) -> [Bool] {
        let ticks = max(0, Int((time * ticksPerSecond).rounded())) & ((1 << bitCount) - 1)
        let bits = (0..<bitCount).map { (ticks >> (bitCount - 1 - $0)) & 1 == 1 }
        let parity = bits.filter { $0 }.count % 2 == 1
        return [true, false] + bits + [parity, true]
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
