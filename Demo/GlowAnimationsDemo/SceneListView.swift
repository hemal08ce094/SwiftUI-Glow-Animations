import GlowAnimations
import SwiftUI

struct SceneListView: View {
    @State private var presented: PlayerItem?

    init(initialProgram: GlowPlayer.Program?) {
        _presented = State(initialValue: initialProgram.map(PlayerItem.init))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { presented = PlayerItem(.reel) } label: {
                        ProgramRow(
                            title: Text("Play full reel"),
                            duration: GlowScene.reelDuration,
                            symbol: "play.fill",
                            accent: true
                        )
                    }
                }

                Section("Scenes") {
                    ForEach(Array(GlowScene.allCases.enumerated()), id: \.element) { index, scene in
                        Button { presented = PlayerItem(.scene(scene)) } label: {
                            ProgramRow(
                                title: scene.localizedName,
                                duration: scene.duration,
                                number: index + 1
                            )
                        }
                    }
                }
            }
            .navigationTitle("Glow Animations")
        }
        .preferredColorScheme(.dark)
        .tint(GlowTheme.gold)
        .fullScreenCover(item: $presented) { item in
            PlayerScreen(program: item.program, chromeless: false) { presented = nil }
        }
    }
}

struct PlayerItem: Identifiable {
    var program: GlowPlayer.Program
    init(_ program: GlowPlayer.Program) { self.program = program }

    var id: String {
        switch program {
        case .reel: "reel"
        case .scene(let scene): scene.rawValue
        }
    }
}

private struct ProgramRow: View {
    var title: Text
    var duration: Double
    var number: Int? = nil
    var symbol: String? = nil
    var accent = false

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if let symbol {
                    Image(systemName: symbol)
                        .foregroundStyle(GlowTheme.gold)
                } else if let number {
                    Text(number, format: .number.precision(.integerLength(2)))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 26, alignment: .leading)
            .accessibilityHidden(true)

            title
                .foregroundStyle(.primary)
                .fontWeight(accent ? .semibold : .regular)

            Spacer(minLength: 12)

            Text(Measurement(value: duration, unit: UnitDuration.seconds),
                 format: .measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1))))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

extension GlowScene {
    var localizedName: Text {
        switch self {
        case .spark: Text("Spark")
        case .grow: Text("Grow")
        case .shape: Text("Shape")
        case .details: Text("Details")
        case .rhythm: Text("Rhythm")
        case .workflow: Text("Workflow")
        case .connects: Text("Connects")
        case .flow: Text("Flow")
        case .outro: Text("Outro")
        }
    }
}

extension GlowPlayer.Program {
    var localizedName: Text {
        switch self {
        case .reel: Text("Full reel")
        case .scene(let scene): scene.localizedName
        }
    }
}
