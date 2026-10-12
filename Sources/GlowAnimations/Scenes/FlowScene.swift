import SwiftUI

/// Scene 8, "Stay in *flow*" (reference f0736–f0855): the orange ball swells into a sphere,
/// dances as a metaball blob that buds a red ball and a gold lobe, rounds back up and shrinks
/// to the ball the outro sprouts from.
public struct FlowScene: View {
    public var t: Double

    public init(t: Double) { self.t = t }

    public var body: some View {
        ZStack {
            Canvas { context, _ in
                FlowBlob.draw(in: context, balls: FlowTimeline.balls(at: t), bounds: FlowTimeline.blobBounds)
            }
            .frame(width: 720, height: 1280)
            FlowCaption(t: t)
        }
        .frame(width: 720, height: 1280)
    }
}

enum FlowTimeline {
    static let center = CGPoint(x: 360, y: 640)
    static let blobBounds = CGRect(x: 100, y: 330, width: 520, height: 640)
    static let restRadius: CGFloat = 117
    static let handOffRadius: CGFloat = 25.5

    /// Sphere radius while the blob is a single ball. Grows 25.5 → 117 (f0735 → f0751), shrinks 123 → 33 (f0846 → f0858).
    static func sphereRadius(at t: Double) -> CGFloat {
        if t < 2 {
            let u = Ease.clamp01((t + 0.012) / 0.55)
            return handOffRadius + (restRadius - handOffRadius) * CGFloat(1 - pow(1 - u, 2.9))
        }
        let shrink = Ease.easeInOut((t - 3.654) / 0.415)
        return finalRadius - (finalRadius - 33) * CGFloat(shrink)
    }

    static let finalRadius: CGFloat = 125

    struct Key {
        var t: Double
        var balls: [BlobBall]
    }

    private static func key(_ frame: Int, _ values: [(CGFloat, CGFloat, CGFloat)]) -> Key {
        Key(t: Double(frame - 736) / 30, balls: values.map { BlobBall(center: CGPoint(x: $0.0, y: $0.1), radius: $0.2) })
    }

    /// Six lobes fitted to the reference silhouette every second frame (f0752–f0840) with the `Metaballs`
    /// field, tracked both ways from f0806 where every lobe is distinct, then smoothed [1 2 1].
    /// A lobe that has merged keeps moving inside the body.
    static let keys: [Key] = [
        key(752, [(329, 677, 65), (363, 633, 118), (369, 708, 34), (391, 596, 82), (362, 572, 61), (367, 713, 22)]),
        key(754, [(331, 680, 67), (363, 634, 118), (370, 711, 36), (396, 587, 84), (362, 568, 63), (367, 715, 23)]),
        key(756, [(332, 684, 70), (362, 637, 120), (370, 714, 39), (402, 578, 85), (362, 567, 64), (367, 717, 24)]),
        key(758, [(332, 688, 74), (361, 639, 121), (372, 717, 41), (409, 569, 85), (361, 567, 64), (368, 719, 25)]),
        key(760, [(330, 692, 77), (360, 640, 122), (374, 718, 43), (418, 563, 85), (360, 568, 64), (369, 719, 25)]),
        key(762, [(327, 697, 78), (360, 642, 123), (377, 719, 44), (427, 560, 85), (358, 570, 63), (370, 719, 25)]),
        key(764, [(320, 702, 78), (360, 645, 123), (381, 719, 46), (436, 560, 85), (356, 571, 63), (370, 719, 25)]),
        key(766, [(311, 704, 78), (359, 650, 122), (386, 719, 48), (444, 564, 85), (355, 569, 63), (371, 718, 25)]),
        key(768, [(300, 704, 77), (359, 657, 123), (391, 721, 52), (449, 572, 86), (356, 564, 64), (372, 717, 25)]),
        key(770, [(288, 701, 77), (362, 662, 125), (397, 727, 58), (452, 583, 87), (362, 555, 64), (373, 717, 25)]),
        key(772, [(277, 695, 77), (367, 661, 128), (403, 735, 66), (453, 596, 90), (372, 543, 64), (373, 717, 25)]),
        key(774, [(268, 688, 78), (374, 657, 129), (412, 745, 71), (450, 613, 93), (382, 529, 62), (373, 717, 25)]),
        key(776, [(260, 679, 78), (379, 651, 127), (423, 757, 72), (446, 632, 95), (393, 514, 60), (373, 717, 25)]),
        key(778, [(253, 670, 79), (379, 644, 120), (434, 768, 72), (444, 652, 96), (404, 499, 57), (373, 717, 25)]),
        key(780, [(246, 660, 79), (374, 640, 111), (445, 776, 72), (442, 672, 96), (415, 487, 54), (373, 716, 25)]),
        key(782, [(240, 649, 78), (367, 638, 104), (453, 780, 73), (441, 691, 94), (424, 478, 53), (372, 715, 25)]),
        key(784, [(235, 637, 77), (362, 637, 100), (459, 778, 75), (441, 706, 91), (433, 470, 51), (370, 716, 26)]),
        key(786, [(232, 624, 77), (359, 637, 97), (462, 773, 79), (440, 720, 88), (441, 463, 50), (368, 718, 28)]),
        key(788, [(231, 611, 77), (358, 636, 96), (463, 768, 82), (436, 736, 83), (448, 458, 49), (366, 720, 30)]),
        key(790, [(233, 599, 77), (358, 635, 95), (462, 762, 84), (429, 753, 77), (453, 454, 48), (364, 721, 32)]),
        key(792, [(237, 587, 77), (357, 634, 95), (464, 756, 84), (422, 766, 74), (456, 452, 48), (361, 720, 33)]),
        key(794, [(242, 575, 77), (357, 631, 94), (466, 748, 82), (415, 775, 74), (457, 452, 48), (358, 718, 33)]),
        key(796, [(249, 565, 77), (357, 629, 94), (470, 736, 79), (407, 783, 74), (457, 452, 49), (355, 715, 33)]),
        key(798, [(258, 556, 77), (357, 626, 94), (472, 720, 77), (399, 790, 73), (455, 454, 49), (352, 712, 33)]),
        key(800, [(270, 547, 78), (357, 623, 95), (473, 703, 76), (390, 794, 73), (452, 458, 50), (350, 709, 33)]),
        key(802, [(283, 541, 81), (361, 622, 98), (472, 685, 77), (380, 797, 73), (445, 464, 52), (349, 706, 33)]),
        key(804, [(297, 535, 83), (368, 624, 104), (471, 667, 76), (370, 798, 72), (437, 472, 56), (348, 704, 32)]),
        key(806, [(310, 529, 83), (376, 623, 111), (472, 649, 75), (359, 799, 71), (429, 478, 59), (347, 704, 33)]),
        key(808, [(322, 523, 83), (377, 616, 114), (472, 630, 74), (349, 797, 70), (421, 485, 62), (346, 706, 39)]),
        key(810, [(334, 519, 83), (374, 611, 112), (470, 611, 74), (339, 793, 70), (414, 492, 65), (346, 708, 48)]),
        key(812, [(347, 516, 83), (370, 610, 108), (467, 593, 75), (329, 787, 70), (409, 498, 66), (344, 709, 55)]),
        key(814, [(359, 514, 84), (368, 611, 105), (463, 576, 77), (319, 778, 69), (408, 502, 66), (339, 708, 60)]),
        key(816, [(368, 516, 84), (366, 611, 104), (458, 561, 78), (310, 768, 69), (410, 504, 66), (333, 705, 65)]),
        key(818, [(372, 521, 84), (367, 610, 104), (454, 547, 80), (301, 757, 69), (412, 503, 67), (326, 700, 69)]),
        key(820, [(374, 528, 83), (367, 606, 107), (448, 538, 84), (292, 743, 68), (413, 502, 69), (319, 694, 74)]),
        key(822, [(374, 535, 81), (366, 602, 110), (442, 537, 91), (283, 729, 68), (418, 502, 72), (313, 687, 78)]),
        key(824, [(377, 539, 77), (361, 604, 112), (438, 546, 96), (276, 713, 68), (426, 503, 76), (306, 677, 83)]),
        key(826, [(381, 541, 75), (354, 609, 112), (437, 560, 98), (269, 697, 65), (430, 506, 79), (299, 666, 87)]),
        key(828, [(384, 541, 74), (350, 615, 112), (436, 575, 98), (267, 684, 60), (425, 512, 79), (294, 654, 89)]),
        key(830, [(384, 541, 74), (348, 619, 113), (431, 589, 98), (270, 674, 52), (418, 521, 75), (293, 643, 90)]),
        key(832, [(381, 542, 73), (348, 620, 115), (422, 603, 98), (274, 668, 47), (413, 532, 67), (297, 634, 88)]),
        key(834, [(375, 548, 69), (349, 621, 119), (411, 614, 98), (279, 666, 43), (411, 543, 57), (302, 628, 85)]),
        key(836, [(370, 555, 63), (352, 623, 121), (400, 622, 98), (283, 665, 40), (410, 553, 49), (307, 624, 80)]),
        key(838, [(366, 561, 58), (355, 627, 122), (393, 626, 97), (286, 665, 37), (409, 560, 43), (312, 622, 76)]),
        key(840, [(364, 565, 54), (357, 630, 122), (389, 628, 94), (289, 664, 35), (407, 566, 39), (315, 621, 73)]),
    ]

    static func balls(at t: Double) -> [BlobBall] {
        guard let first = keys.first, let last = keys.last else { return [] }
        if t <= first.t || t >= last.t {
            return [BlobBall(center: center, radius: sphereRadius(at: t))]
        }
        let i = keys.lastIndex { $0.t <= t } ?? 0
        let u = (t - keys[i].t) / (keys[i + 1].t - keys[i].t)
        let p0 = keys[max(0, i - 1)].balls
        let p1 = keys[i].balls
        let p2 = keys[i + 1].balls
        let p3 = keys[min(keys.count - 1, i + 2)].balls
        return (0..<p1.count).map { k in
            BlobBall(
                center: CGPoint(
                    x: catmullRom(p0[k].center.x, p1[k].center.x, p2[k].center.x, p3[k].center.x, u),
                    y: catmullRom(p0[k].center.y, p1[k].center.y, p2[k].center.y, p3[k].center.y, u)
                ),
                radius: max(0, catmullRom(p0[k].radius, p1[k].radius, p2[k].radius, p3[k].radius, u))
            )
        }
    }

    static func catmullRom(_ p0: CGFloat, _ p1: CGFloat, _ p2: CGFloat, _ p3: CGFloat, _ u: Double) -> CGFloat {
        let u = CGFloat(u)
        let u2 = u * u
        let u3 = u2 * u
        return 0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u2 + (-p0 + 3 * p1 - 3 * p2 + p3) * u3)
    }
}

/// "Stay in *flow*" in cream white over the blob: wipes in f0757 → f0771, out f0840 → f0847.
struct FlowCaption: View {
    var t: Double

    static let fontSize: CGFloat = 46
    static let baselineY: CGFloat = 653

    var body: some View {
        let reveal = Ease.clamp01((t - 0.55) / 0.6)
        let exit = Ease.clamp01((t - 3.48) / 0.27)
        let line = HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: "Stay in")
                .font(GlowFonts.sans(weight: .regular, size: Self.fontSize))
            Color.clear.frame(width: CaptionReveal.spaceWidth(fontSize: Self.fontSize), height: 1)
            Text(verbatim: "flow")
                .font(GlowFonts.serifItalic(size: Self.fontSize))
        }
        .foregroundStyle(Color(hex: 0xFEF8EA))
        .fixedSize()

        Group {
            if exit > 0 {
                line.blurWipe(progress: 1 - exit, edgeWidth: 60, reversed: true)
            } else {
                line.blurWipe(progress: reveal, edgeWidth: 60)
            }
        }
        .alignmentGuide(VerticalAlignment.top) { $0[.firstTextBaseline] }
        .frame(width: 720, height: 1280, alignment: .top)
        .offset(y: Self.baselineY)
        .allowsHitTesting(false)
    }
}
