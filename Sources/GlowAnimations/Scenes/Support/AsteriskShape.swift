import SwiftUI

/// Six petal arms at 60° steps plus a round hub, centred on the origin. Arm 0 points along +x
/// before `rotation` (radians, clockwise on screen) is applied. Matched to f0866–f0930: tip at 41 px,
/// arms 12 px wide at their middle, hub 9 px.
struct Asterisk {
    var armLength: CGFloat = 41
    var armWidth: CGFloat = 12
    var hubRadius: CGFloat = 9

    func path(center: CGPoint, rotation: Double, scale: CGFloat = 1) -> Path {
        let length = armLength * scale
        let halfWidth = armWidth / 2 * scale
        let inner = length * 0.1
        var path = Path()
        for i in 0..<6 {
            let angle = rotation + Double(i) * .pi / 3
            let arm = Path(ellipseIn: CGRect(x: inner, y: -halfWidth, width: length - inner, height: halfWidth * 2))
            let transform = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: CGFloat(angle))
            path.addPath(arm, transform: transform)
        }
        let hub = hubRadius * scale
        path.addEllipse(in: CGRect(x: center.x - hub, y: center.y - hub, width: hub * 2, height: hub * 2))
        return path
    }
}
