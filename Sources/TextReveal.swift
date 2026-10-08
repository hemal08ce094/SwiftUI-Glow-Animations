import SwiftUI

public struct TextReveal: View {
    let text: String
    let colors: [Color]
    @State private var revealWidth: CGFloat = 0

    public init(text: String, colors: [Color] = [Color(red: 1, green: 0.4, blue: 0.6), Color(red: 1, green: 0.7, blue: 0.2)]) {
        self.text = text
        self.colors = colors
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(.system(size: 32, weight: .light, design: .default))
                .foregroundColor(.gray.opacity(0.3))

            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(
                Text(text)
                    .font(.system(size: 32, weight: .light, design: .default))
                    .lineLimit(1)
            )
            .frame(width: revealWidth, alignment: .leading)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                revealWidth = 400
            }
        }
    }
}

public struct CharacterReveal: View {
    let text: String
    @State private var visibleCharacters: Int = 0
    let duration: Double
    let gradient: LinearGradient

    public init(
        text: String,
        duration: Double = 2.0,
        gradient: LinearGradient = LinearGradient(
            gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.6), Color(red: 1, green: 0.7, blue: 0.2)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    ) {
        self.text = text
        self.duration = duration
        self.gradient = gradient
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<text.count, id: \.self) { index in
                Text(String(text[text.index(text.startIndex, offsetBy: index)]))
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .foregroundColor(index < visibleCharacters ? .clear : .white)
                    .background(
                        index < visibleCharacters
                            ? gradient
                            : LinearGradient(gradient: Gradient(colors: [.clear]), startPoint: .leading, endPoint: .trailing)
                    )
                    .mask(
                        index < visibleCharacters
                            ? Text(String(text[text.index(text.startIndex, offsetBy: index)]))
                                .font(.system(size: 28, weight: .semibold, design: .default))
                            : Text("")
                    )
            }
        }
        .onAppear {
            animateCharacters()
        }
    }

    private func animateCharacters() {
        let delayPerCharacter = duration / Double(text.count)
        for i in 0...text.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayPerCharacter * Double(i)) {
                withAnimation(.easeOut(duration: 0.3)) {
                    visibleCharacters = i
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ZStack {
            Color.black.ignoresSafeArea()
            TextReveal(text: "Opus 5.5 is cooking")
        }

        ZStack {
            Color.black.ignoresSafeArea()
            CharacterReveal(text: "Build it")
        }
    }
}
