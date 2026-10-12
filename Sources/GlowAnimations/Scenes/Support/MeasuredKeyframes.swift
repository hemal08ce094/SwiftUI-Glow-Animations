import Foundation

/// A value measured on reference frames, interpolated with a monotone cubic (Fritsch–Carlson),
/// so it passes through every sample without overshooting between them. Clamped outside the range.
struct MeasuredKeyframes {
    private let xs: [Double]
    private let ys: [Double]
    private let slopes: [Double]

    init(_ points: [(Double, Double)]) {
        precondition(points.count >= 2, "need at least two keyframes")
        xs = points.map(\.0)
        ys = points.map(\.1)
        slopes = Self.monotoneSlopes(xs: xs, ys: ys)
    }

    func callAsFunction(_ x: Double) -> Double {
        if x <= xs[0] { return ys[0] }
        let last = xs.count - 1
        if x >= xs[last] { return ys[last] }
        var i = 0
        while xs[i + 1] < x { i += 1 }
        let h = xs[i + 1] - xs[i]
        let s = (x - xs[i]) / h
        let s2 = s * s, s3 = s2 * s
        let h00 = 2 * s3 - 3 * s2 + 1
        let h10 = s3 - 2 * s2 + s
        let h01 = -2 * s3 + 3 * s2
        let h11 = s3 - s2
        return h00 * ys[i] + h10 * h * slopes[i] + h01 * ys[i + 1] + h11 * h * slopes[i + 1]
    }

    private static func monotoneSlopes(xs: [Double], ys: [Double]) -> [Double] {
        let n = xs.count
        var delta = [Double](repeating: 0, count: n - 1)
        for i in 0..<(n - 1) { delta[i] = (ys[i + 1] - ys[i]) / (xs[i + 1] - xs[i]) }
        var m = [Double](repeating: 0, count: n)
        m[0] = delta[0]
        m[n - 1] = delta[n - 2]
        for i in 1..<(n - 1) {
            m[i] = delta[i - 1] * delta[i] <= 0 ? 0 : (delta[i - 1] + delta[i]) / 2
        }
        for i in 0..<(n - 1) where delta[i] == 0 {
            m[i] = 0
            m[i + 1] = 0
        }
        for i in 0..<(n - 1) where delta[i] != 0 {
            let a = m[i] / delta[i], b = m[i + 1] / delta[i]
            let r = a * a + b * b
            if r > 9 {
                let k = 3 / r.squareRoot()
                m[i] = k * a * delta[i]
                m[i + 1] = k * b * delta[i]
            }
        }
        return m
    }
}
