import Foundation

/// Easing helpers. Every function takes and returns plain `Double`s so scenes
/// stay pure functions of time.
public enum Ease {
    @inlinable
    public static func clamp01(_ x: Double) -> Double { min(max(x, 0), 1) }

    /// Maps `t` from `a...b` to `c...d`, clamped to the output range.
    @inlinable
    public static func remap(_ t: Double, from a: Double, _ b: Double, to c: Double = 0, _ d: Double = 1) -> Double {
        guard b != a else { return t >= b ? d : c }
        return c + (d - c) * clamp01((t - a) / (b - a))
    }

    /// Normalised progress of `t` through the window `a...b`, clamped to 0...1.
    @inlinable
    public static func progress(_ t: Double, _ a: Double, _ b: Double) -> Double {
        remap(t, from: a, b)
    }

    @inlinable
    public static func lerp(_ a: Double, _ b: Double, _ p: Double) -> Double { a + (b - a) * p }

    public static func easeIn(_ x: Double) -> Double {
        let p = clamp01(x); return p * p * p
    }

    public static func easeOut(_ x: Double) -> Double {
        let p = 1 - clamp01(x); return 1 - p * p * p
    }

    public static func easeInOut(_ x: Double) -> Double {
        let p = clamp01(x)
        return p < 0.5 ? 4 * p * p * p : 1 - pow(-2 * p + 2, 3) / 2
    }

    public static func smoothstep(_ x: Double) -> Double {
        let p = clamp01(x); return p * p * (3 - 2 * p)
    }

    /// Ease-out that overshoots past 1 before settling. `overshoot` 1.70158 is the classic value.
    public static func easeOutBack(_ x: Double, overshoot s: Double = 1.70158) -> Double {
        let p = clamp01(x) - 1
        return 1 + (s + 1) * p * p * p + s * p * p
    }

    /// Damped-oscillator ease: reaches 1 with a small wobble. `damping` higher = calmer,
    /// `frequency` is the number of oscillations over the 0...1 range.
    public static func spring(_ x: Double, damping: Double = 6, frequency: Double = 1.6) -> Double {
        let p = clamp01(x)
        if p >= 1 { return 1 }
        return 1 - exp(-damping * p) * cos(2 * .pi * frequency * p)
    }
}
