import SwiftUI

/// Palette sampled from the reference reel.
public enum GlowTheme {
    public static let black = Color(hex: 0x010101)
    public static let cream = Color(hex: 0xF6EFE6)
    /// Caption accent gold.
    public static let gold = Color(hex: 0xE9A94C)
    /// Inner halo of a point light.
    public static let goldHot = Color(hex: 0xFFD36A)
    /// Outer halo of a point light.
    public static let amber = Color(hex: 0xF0A030)
    public static let pinkPill = Color(hex: 0xFD7B80)
    public static let orangePill = Color(hex: 0xDE802D)
    public static let orange = orangePill
    public static let pink = pinkPill
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
