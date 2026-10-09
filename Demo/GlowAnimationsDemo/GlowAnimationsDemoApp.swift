import GlowAnimations
import SwiftUI

@main
struct GlowAnimationsDemoApp: App {
    private let launch = LaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    init() {
        let registered = GlowFonts.registerIfNeeded()
        for (name, ok) in registered.sorted(by: { $0.key < $1.key }) {
            print("GLOW_FONT \(name) \(ok ? "ok" : "missing")")
        }
    }

    var body: some Scene {
        WindowGroup {
            if launch.chromeless, let program = launch.program {
                PlayerScreen(program: program, chromeless: true, onClose: nil)
            } else {
                SceneListView(initialProgram: launch.program)
            }
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
