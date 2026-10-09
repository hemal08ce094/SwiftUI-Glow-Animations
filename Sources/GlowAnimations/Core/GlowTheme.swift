import SwiftUI

/// Palette sampled from the reference reel. Values other than black are placeholders
/// until the storyboard specs land.
public enum GlowTheme {
    public static let black = Color(hex: 0x000000)
    public static let cream = Color(hex: 0xF6EFE6)
    public static let gold = Color(hex: 0xFFC24A)
    public static let orange = Color(hex: 0xFF8A3D)
    public static let pink = Color(hex: 0xFF4D6D)
}

public extension Color {
    /// Builds an sRGB colour from a 0xRRGGBB literal.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
