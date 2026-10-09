import CoreText
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Bundled typefaces (both SIL OFL 1.1): Outfit for sans captions, Instrument Serif
/// for the italic accent word.
public enum GlowFonts {
    public enum SansWeight: Sendable {
        case light, regular, medium

        var postScriptName: String {
            switch self {
            case .light: "Outfit-Light"
            case .regular: "Outfit-Regular"
            case .medium: "Outfit-Medium"
            }
        }

        var fallback: Font.Weight {
            switch self {
            case .light: .light
            case .regular: .regular
            case .medium: .medium
            }
        }
    }

    static let serifItalicName = "InstrumentSerif-Italic"
    static let serifRegularName = "InstrumentSerif-Regular"

    private static let fileNames = [
        "Outfit-Light", "Outfit-Regular", "Outfit-Medium",
        "InstrumentSerif-Regular", "InstrumentSerif-Italic",
    ]

    private static let registration: [String: Bool] = {
        var result: [String: Bool] = [:]
        for name in fileNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                result[name] = false
                continue
            }
            var error: Unmanaged<CFError>?
            let ok = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            // A second registration of the same URL reports "already registered"; that is fine.
            result[name] = ok || isAvailable(name)
        }
        return result
    }()

    /// Registers the bundled fonts with Core Text once per process. Safe to call repeatedly.
    @discardableResult
    public static func registerIfNeeded() -> [String: Bool] { registration }

    /// True when a font with this PostScript name can be instantiated.
    public static func isAvailable(_ postScriptName: String) -> Bool {
        #if canImport(UIKit)
        UIFont(name: postScriptName, size: 12) != nil
        #else
        CTFontCreateWithName(postScriptName as CFString, 12, nil).postScriptName == postScriptName
        #endif
    }

    /// Outfit at `size` points (design units inside a `GlowStage`).
    public static func sans(weight: SansWeight = .regular, size: CGFloat) -> Font {
        registerIfNeeded()
        guard isAvailable(weight.postScriptName) else {
            return .system(size: size, weight: weight.fallback, design: .rounded)
        }
        return .custom(weight.postScriptName, fixedSize: size)
    }

    /// Instrument Serif Italic at `size` points.
    public static func serifItalic(size: CGFloat) -> Font {
        registerIfNeeded()
        guard isAvailable(serifItalicName) else {
            return .system(size: size, design: .serif).italic()
        }
        return .custom(serifItalicName, fixedSize: size)
    }

    /// Instrument Serif Regular at `size` points.
    public static func serif(size: CGFloat) -> Font {
        registerIfNeeded()
        guard isAvailable(serifRegularName) else {
            return .system(size: size, design: .serif)
        }
        return .custom(serifRegularName, fixedSize: size)
    }
}

private extension CTFont {
    var postScriptName: String { CTFontCopyPostScriptName(self) as String }
}
