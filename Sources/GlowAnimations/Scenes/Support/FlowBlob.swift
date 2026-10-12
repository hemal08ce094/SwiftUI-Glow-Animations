import SwiftUI

struct BlobBall: Equatable {
    var center: CGPoint
    var radius: CGFloat
}

/// The scene-8 liquid sphere: the metaball union of `BlobBall`s, filled with a screen-space
/// red→orange→gold vertical ramp and shaded as one glossy body lit from the upper left.
/// The union is contoured on the CPU and shaded with vector fills and strokes, so the only
/// offscreen pass is the edge softening.
enum FlowBlob {
    static func draw(in context: GraphicsContext, balls: [BlobBall], bounds: CGRect, opacity: Double = 1) {
        let balls = balls.filter { $0.radius > 0.5 }
        guard opacity > 0, !balls.isEmpty else { return }
        let shape = balls.count == 1 ? disc(balls[0].center, balls[0].radius) : Metaballs.contour(balls, in: bounds)
        let size = min(1, max(0.25, balls.map(\.radius).max()! / 117))
        var ctx = context
        ctx.opacity = opacity

        drawFeatherAndGlow(shape, in: ctx, size: size)

        var body = ctx
        body.addFilter(.blur(radius: edgeSoftness * max(size, 0.35)))
        body.drawLayer { layer in
            layer.fill(shape, with: verticalRamp())
            var inside = layer
            inside.clip(to: shape)
            for ball in balls { drawDome(ball, in: inside) }
            drawHighlight(shape, in: inside, size: size)
            drawRim(shape, in: inside, size: size)
            drawEdgeBand(shape, in: inside, toward: CGVector(dx: -0.707, dy: -0.707), steps: [3, 6, 9, 12, 15, 18, 21, 24],
                         size: size, color: Color(hex: 0xB06038), alpha: 0.15)
            drawRimLight(shape, in: inside, size: size)
            drawSeams(balls, near: shape, in: inside)
        }
    }

    static let edgeSoftness: CGFloat = 3.4

    /// Inner rim light on the lit (left and upper-left) edges, f0770 row 600: the reference holds 187–192 luma
    /// for ≈ 16 px inside the left edge against 156–166 in the interior, while the far edge falls off with no rim.
    /// Screened pale peach (`#FFAC80` sampled in the band) over the part a right-shifted copy no longer covers.
    private static func drawRimLight(_ shape: Path, in context: GraphicsContext, size: CGFloat) {
        let direction = CGVector(dx: 0.94, dy: 0.34)
        for step: CGFloat in [4, 8, 12, 16, 20, 24, 28] {
            let offset = step * max(size, 0.5)
            var band = context
            band.opacity *= 0.075
            band.blendMode = .screen
            band.clip(to: shape.applying(CGAffineTransform(translationX: direction.dx * offset, y: direction.dy * offset)), options: .inverse)
            band.fill(shape, with: .color(Color(hex: 0xFFE2C4)))
        }
    }

    /// Where two lobes meet at the surface, each lobe's outline inside the other reads as a faint 1 px seam
    /// at 85 %, kept to the outer 22 px so buried lobes leave no lines.
    private static func drawSeams(_ balls: [BlobBall], near shape: Path, in context: GraphicsContext) {
        guard balls.count > 1 else { return }
        var context = context
        context.clip(to: shape.strokedPath(StrokeStyle(lineWidth: 44, lineJoin: .round)))
        for (i, ball) in balls.enumerated() {
            for (j, other) in balls.enumerated() where i != j {
                let gap = hypot(ball.center.x - other.center.x, ball.center.y - other.center.y)
                guard gap < ball.radius + other.radius, gap + ball.radius > other.radius + 4 else { continue }
                var seam = context
                seam.blendMode = .multiply
                seam.clip(to: disc(other.center, other.radius - 4))
                seam.stroke(disc(ball.center, ball.radius), with: .color(Color(white: 0.85)), lineWidth: 1)
            }
        }
    }

    /// Pale band inside the rim from the top round to the left (normals ≈ 60°–200°, peak `#F9BFA1` 7–17 px
    /// inside on f0748): the body minus two copies slid along directions whose half-planes intersect there.
    private static func drawHighlight(_ shape: Path, in context: GraphicsContext, size: CGFloat) {
        let first = CGVector(dx: 0.34, dy: 0.94)
        let second = CGVector(dx: 0.87, dy: 0.5)
        for step: CGFloat in [5, 8, 11, 14, 17, 20, 23] {
            let offset = step * size
            var band = context
            band.opacity *= 0.19
            band.clip(to: shape.applying(CGAffineTransform(translationX: first.dx * offset, y: first.dy * offset)), options: .inverse)
            band.clip(to: shape.applying(CGAffineTransform(translationX: second.dx * offset, y: second.dy * offset)), options: .inverse)
            band.fill(shape, with: .color(Color(hex: 0xFFD4BE)))
        }
    }

    /// Each lobe reads as its own soft dome: a faint lightening toward its upper-left centre.
    private static func drawDome(_ ball: BlobBall, in context: GraphicsContext) {
        let c = CGPoint(x: ball.center.x - 0.15 * ball.radius, y: ball.center.y - 0.2 * ball.radius)
        let gradient = Gradient(stops: [
            .init(color: Color(hex: 0xFFE0A8, opacity: 0.07), location: 0),
            .init(color: Color(hex: 0xFFE0A8, opacity: 0), location: 1),
        ])
        context.fill(disc(c, ball.radius * 0.85), with: .radialGradient(gradient, center: c, startRadius: 0, endRadius: ball.radius * 0.85))
    }

    /// Screen-space fill, sampled on f0770/f0792/f0812: `#FC5A40` at y 450, `#FE7634` 560, `#FD9E46` 660, `#FFBC5A` 800.
    static func verticalRamp() -> GraphicsContext.Shading {
        let top: CGFloat = 450
        let bottom: CGFloat = 800
        let stops: [(y: CGFloat, hex: UInt32)] = [(450, 0xFC5A40), (560, 0xFE7634), (660, 0xFD9E46), (800, 0xFFBC5A)]
        let gradient = Gradient(stops: stops.map { .init(color: Color(hex: $0.hex), location: ($0.y - top) / (bottom - top)) })
        return .linearGradient(gradient, startPoint: CGPoint(x: 0, y: top), endPoint: CGPoint(x: 0, y: bottom))
    }

    private static func disc(_ center: CGPoint, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    /// Outside the edge (on top of the 4.5 px body softening): a warm halo 0.3·e^(−x/5) + 0.16·e^(−x/25),
    /// fitted to the f0748 radial profiles (≈ 0.25 at 9 px out, 0.16 at 15, 0.08 at 23).
    static func glowLevel(_ x: CGFloat) -> CGFloat { 0.3 * exp(-x / 5) + 0.16 * exp(-x / 25) }

    /// Inside the edge: multiply toward `#FCC48E` (keeps red, drops green and blue), 0.6 for the outer
    /// 15 px fading to 0 at 60 px (f0750: `#FA892F` just inside the rim vs `#FDAA4F` at the centre).
    static func rimLevel(_ x: CGFloat) -> CGFloat { x <= 15 ? 0.6 : max(0, 0.6 * (60 - x) / 45) }

    /// Alphas for nested strokes at `distances` (widest first) whose source-over stack reaches `level(x)` at each reach.
    static func nestedAlphas(_ distances: [CGFloat], _ level: (CGFloat) -> CGFloat) -> [(distance: CGFloat, alpha: Double)] {
        var rings: [(CGFloat, Double)] = []
        var outer: CGFloat = 0
        for x in distances.sorted(by: >) {
            let value = level(x)
            rings.append((x, Double(max(0, 1 - (1 - value) / (1 - outer)))))
            outer = max(outer, value)
        }
        return rings
    }

    static let glowRings = nestedAlphas((0..<16).map { pow(1.3, CGFloat($0)) }, glowLevel)
    static let rimRings = nestedAlphas((1...16).map { CGFloat($0) * 6 }, rimLevel)

    private static func drawFeatherAndGlow(_ shape: Path, in context: GraphicsContext, size: CGFloat) {
        for ring in glowRings {
            var stroke = context
            stroke.opacity *= ring.alpha
            let reach = ring.distance * (0.55 + 0.45 * size)
            stroke.stroke(shape, with: verticalRamp(), style: StrokeStyle(lineWidth: reach * 2, lineJoin: .round))
        }
    }

    private static func drawRim(_ shape: Path, in context: GraphicsContext, size: CGFloat) {
        for ring in rimRings {
            var stroke = context
            stroke.opacity *= ring.alpha * Double(size)
            stroke.blendMode = .multiply
            stroke.stroke(shape, with: .color(Color(hex: 0xFCC48E)), style: StrokeStyle(lineWidth: ring.distance * size * 2, lineJoin: .round))
        }
    }

    /// The part of the body that the shape, slid by `step` along `direction`, no longer covers:
    /// a band hugging the opposite edge. Stacked steps give a soft falloff.
    private static func drawEdgeBand(
        _ shape: Path, in context: GraphicsContext, toward direction: CGVector, steps: [CGFloat], size: CGFloat,
        color: Color, alpha: Double
    ) {
        for step in steps {
            let offset = step * size
            var band = context
            band.opacity *= alpha
            band.blendMode = .multiply
            let moved = shape.applying(CGAffineTransform(translationX: direction.dx * offset, y: direction.dy * offset))
            band.clip(to: moved, options: .inverse)
            band.fill(shape, with: .color(color))
        }
    }
}

/// Marching-squares contour of Σ exp((r² − ρ²) / 2s²) = 1, so a lone ball's edge is exactly its radius
/// and two balls fuse once their gap is under ≈ 1.2·s.
enum Metaballs {
    static let reach: CGFloat = 24
    static let cell: CGFloat = 5

    static func field(_ p: CGPoint, _ balls: [BlobBall]) -> CGFloat {
        var sum: CGFloat = 0
        let k = 1 / (2 * reach * reach)
        for ball in balls {
            let dx = p.x - ball.center.x
            let dy = p.y - ball.center.y
            let e = (ball.radius * ball.radius - dx * dx - dy * dy) * k
            if e > -12 { sum += exp(e) }
        }
        return sum
    }

    static func contour(_ balls: [BlobBall], in bounds: CGRect) -> Path {
        let nx = Int(ceil(bounds.width / cell))
        let ny = Int(ceil(bounds.height / cell))
        let stride = nx + 1
        var values = [CGFloat](repeating: 0, count: stride * (ny + 1))
        for j in 0...ny {
            for i in 0...nx {
                let p = CGPoint(x: bounds.minX + CGFloat(i) * cell, y: bounds.minY + CGFloat(j) * cell)
                values[j * stride + i] = (i == 0 || j == 0 || i == nx || j == ny) ? 0 : field(p, balls)
            }
        }

        // Edge keys: horizontal edge from node (i, j) is 2·node, vertical edge from node (i, j) is 2·node + 1.
        func point(onEdge key: Int) -> CGPoint {
            let node = key / 2
            let i = node % stride
            let j = node / stride
            let a = values[node]
            let b = key % 2 == 0 ? values[node + 1] : values[node + stride]
            let f = (1 - a) / (b - a)
            let x = bounds.minX + CGFloat(i) * cell
            let y = bounds.minY + CGFloat(j) * cell
            return key % 2 == 0 ? CGPoint(x: x + f * cell, y: y) : CGPoint(x: x, y: y + f * cell)
        }

        var next: [Int: Int] = [:]
        for j in 0..<ny {
            for i in 0..<nx {
                let n = j * stride + i
                let tl = values[n] >= 1, tr = values[n + 1] >= 1
                let bl = values[n + stride] >= 1, br = values[n + stride + 1] >= 1
                let top = 2 * n, bottom = 2 * (n + stride), left = 2 * n + 1, right = 2 * (n + 1) + 1
                let code = (tl ? 8 : 0) | (tr ? 4 : 0) | (br ? 2 : 0) | (bl ? 1 : 0)
                // Segments run with the inside on the right-hand side, so chains are consistently oriented.
                switch code {
                case 1: next[left] = bottom
                case 2: next[bottom] = right
                case 3: next[left] = right
                case 4: next[right] = top
                case 5:
                    let centre = (values[n] + values[n + 1] + values[n + stride] + values[n + stride + 1]) / 4 >= 1
                    if centre { next[left] = top; next[right] = bottom } else { next[left] = bottom; next[right] = top }
                case 6: next[bottom] = top
                case 7: next[left] = top
                case 8: next[top] = left
                case 9: next[top] = bottom
                case 10:
                    let centre = (values[n] + values[n + 1] + values[n + stride] + values[n + stride + 1]) / 4 >= 1
                    if centre { next[top] = right; next[bottom] = left } else { next[top] = left; next[bottom] = right }
                case 11: next[top] = right
                case 12: next[right] = left
                case 13: next[right] = bottom
                case 14: next[bottom] = left
                default: break
                }
            }
        }

        var path = Path()
        var visited = Set<Int>()
        for start in next.keys.sorted() where !visited.contains(start) {
            var loop: [CGPoint] = []
            var key = start
            while !visited.contains(key), let following = next[key] {
                visited.insert(key)
                loop.append(point(onEdge: key))
                key = following
            }
            guard loop.count > 2 else { continue }
            addSmoothLoop(loop, to: &path)
        }
        return path
    }

    /// Quadratic B-spline through the loop's edge midpoints, which hides the grid facets.
    private static func addSmoothLoop(_ points: [CGPoint], to path: inout Path) {
        func mid(_ a: CGPoint, _ b: CGPoint) -> CGPoint { CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2) }
        let n = points.count
        path.move(to: mid(points[n - 1], points[0]))
        for i in 0..<n {
            path.addQuadCurve(to: mid(points[i], points[(i + 1) % n]), control: points[i])
        }
        path.closeSubpath()
    }
}
