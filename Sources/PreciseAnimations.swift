import SwiftUI

// ANIMATION 1: 3D Spiral/Vortex - "Start with a spark"
public struct SpiralVortexAnimation: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Opus 5.5 is cooking")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)

                Spacer()

                VStack(spacing: 20) {
                    Text("Start with a")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .light))

                    Text("spark")
                        .foregroundColor(Color(red: 1, green: 0.65, blue: 0.2))
                        .font(.system(size: 20, weight: .light))
                        .italic()
                }

                Spacer()

                ZStack {
                    // Central glowing sphere
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.9, blue: 0.4),
                                    Color(red: 1, green: 0.7, blue: 0.2)
                                ]),
                                center: .center,
                                radius: 30
                            )
                        )
                        .frame(width: 40, height: 40)
                        .blur(radius: 8)
                        .shadow(color: Color(red: 1, green: 0.7, blue: 0.2).opacity(0.8), radius: 20)

                    // Concentric ellipse rings (3D perspective)
                    VStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Ellipse()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.65, blue: 0.2),
                                            Color(red: 1, green: 0.4, blue: 0.2).opacity(0.5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(width: 100 + CGFloat(index) * 50, height: 30 + CGFloat(index) * 15)
                                .blur(radius: CGFloat(index) * 0.5)
                                .opacity(1.0 - Double(index) * 0.15)
                        }
                    }

                    // Vertical light streaks
                    VStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.7, blue: 0.2),
                                            Color(red: 1, green: 0.7, blue: 0.2).opacity(0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 2, height: 60)
                        }
                    }
                }
                .frame(height: 200)
                .scaleEffect(scale)
                .opacity(opacity)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scale = 1.2
                opacity = 0.7
            }
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// ANIMATION 2: Rotating Circle with Nodes - "Let it"
public struct RotatingCircleWithNodes: View {
    @State private var rotation: Double = 0
    @State private var nodeOpacity: [Double] = Array(repeating: 1.0, count: 6)
    let nodeCount = 6

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Opus 5.5 is cooking")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)

                Spacer()

                ZStack {
                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.5, blue: 0.3).opacity(0.1),
                                    Color.black.opacity(0)
                                ]),
                                center: .center,
                                radius: 150
                            )
                        )
                        .frame(width: 300, height: 300)

                    // Main circle
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.65, blue: 0.2),
                                    Color(red: 1, green: 0.4, blue: 0.3),
                                    Color(red: 1, green: 0.65, blue: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: Color(red: 1, green: 0.65, blue: 0.2).opacity(0.6), radius: 15)

                    // Glowing nodes around circle
                    ForEach(0..<nodeCount, id: \.self) { index in
                        let angle = Double(index) * (360.0 / Double(nodeCount))
                        let radians = angle * .pi / 180
                        let x = cos(radians) * 100
                        let y = sin(radians) * 100

                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.8, blue: 0.3),
                                            Color(red: 1, green: 0.65, blue: 0.2)
                                        ]),
                                        center: .center,
                                        radius: 12
                                    )
                                )
                                .frame(width: 20, height: 20)

                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.8, blue: 0.3).opacity(0.6),
                                            Color(red: 1, green: 0.65, blue: 0.2).opacity(0)
                                        ]),
                                        center: .center,
                                        radius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .blur(radius: 8)
                        }
                        .offset(x: x, y: y)
                        .opacity(nodeOpacity[index])
                    }

                    Text("Let it")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(rotation))

                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            for i in 0..<nodeCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                    withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                        nodeOpacity[i] = 0.4
                    }
                }
            }
        }
    }
}

// ANIMATION 3: Morphing Shape (Flower/Cloud) - Rotating petals
public struct MorphingFlowerShape: View {
    @State private var rotation: Double = 0
    @State private var petalOpacity: [Double] = Array(repeating: 1.0, count: 6)
    let petalCount = 6

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Opus 5.5 is cooking")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)

                Spacer()

                ZStack {
                    // Flower shape made of circles
                    ForEach(0..<petalCount, id: \.self) { index in
                        let angle = Double(index) * (360.0 / Double(petalCount))
                        let radians = angle * .pi / 180
                        let x = cos(radians) * 70
                        let y = sin(radians) * 70

                        ZStack {
                            // Petal circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.75, blue: 0.25),
                                            Color(red: 1, green: 0.6, blue: 0.2)
                                        ]),
                                        center: .center,
                                        radius: 50
                                    )
                                )
                                .frame(width: 80, height: 80)

                            // Petal glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.75, blue: 0.25).opacity(0.4),
                                            Color(red: 1, green: 0.75, blue: 0.25).opacity(0)
                                        ]),
                                        center: .center,
                                        radius: 70
                                    )
                                )
                                .frame(width: 140, height: 140)
                        }
                        .offset(x: x, y: y)
                        .opacity(petalOpacity[index])
                    }

                    // Center node
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1, green: 0.85, blue: 0.35),
                                        Color(red: 1, green: 0.7, blue: 0.2)
                                    ]),
                                    center: .center,
                                    radius: 15
                                )
                            )
                            .frame(width: 30, height: 30)

                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1, green: 0.85, blue: 0.35).opacity(0.5),
                                        Color(red: 1, green: 0.85, blue: 0.35).opacity(0)
                                    ]),
                                    center: .center,
                                    radius: 30
                                )
                            )
                            .frame(width: 70, height: 70)
                            .blur(radius: 10)
                    }
                }
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(rotation))

                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            for i in 0..<petalCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        petalOpacity[i] = 0.3
                    }
                }
            }
        }
    }
}

// ANIMATION 4: Gradient Pill Button
public struct GradientPillAnimation: View {
    @State private var scale: CGFloat = 1.0
    @State private var shadowBlur: CGFloat = 15

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Opus 5.5 is cooking")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)

                Spacer()

                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1, green: 0.5, blue: 0.6),
                                Color(red: 1, green: 0.65, blue: 0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 280, height: 60)
                    .shadow(color: Color(red: 1, green: 0.5, blue: 0.6).opacity(0.7), radius: shadowBlur)
                    .scaleEffect(scale)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                scale = 1.05
                shadowBlur = 30
            }
        }
    }
}

// ANIMATION 5: Diagonal Glowing Line
public struct DiagonalGlowingLine: View {
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.5

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Opus 5.5 is cooking")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)

                Spacer()

                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.7, blue: 0.2),
                                    Color(red: 1, green: 0.5, blue: 0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 8, height: 250)
                        .blur(radius: 12)

                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.8, blue: 0.3),
                                    Color(red: 1, green: 0.6, blue: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 3, height: 250)
                }
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

