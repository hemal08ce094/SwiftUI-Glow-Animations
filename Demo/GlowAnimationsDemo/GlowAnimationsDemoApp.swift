import GlowAnimations
import SwiftUI

@main
struct GlowAnimationsDemoApp: App {
    private let launch = LaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    init() {
        let registered = GlowFonts.registerIfNeeded()
        for (name, ok) in registered.sorted(by: { $0.key < $1.key }) {
            HarnessLog.line("GLOW_FONT \(name) \(ok ? "ok" : "missing")")
        }
    }

    var body: some Scene {
        WindowGroup {
            if launch.chromeless, let program = launch.program {
                RecordingRoot(program: program)
            } else {
                SceneListView(initialProgram: launch.program)
            }
        }
    }
}

/// Holds sync green until the system launch transition has finished, then mounts the
/// player, which keeps green for its 1 s lead-in and cuts to the scene at t = 0.
private struct RecordingRoot: View {
    var program: GlowPlayer.Program
    @State private var ready = false

    var body: some View {
        ZStack {
            HarnessLog.syncGreen.ignoresSafeArea()
            if ready {
                PlayerScreen(program: program, chromeless: true, onClose: nil)
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .task {
            try? await Task.sleep(for: .milliseconds(800))
            ready = true
        }
    }
}

/// Launch arguments used by tools/record.sh:
/// `-glow-scene <case>` opens one scene, `-glow-reel` the whole reel,
/// `-glow-chromeless` hides every overlay and the status bar.
struct LaunchOptions {
    var program: GlowPlayer.Program?
    var chromeless: Bool

    init(arguments: [String]) {
        chromeless = arguments.contains("-glow-chromeless")
        if let i = arguments.firstIndex(of: "-glow-scene"), i + 1 < arguments.count,
           let scene = GlowScene(rawValue: arguments[i + 1]) {
            program = .scene(scene)
        } else if arguments.contains("-glow-reel") {
            program = .reel
        } else {
            program = nil
        }
    }
}
