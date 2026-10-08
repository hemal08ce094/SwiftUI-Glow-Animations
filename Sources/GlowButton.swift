import SwiftUI

public struct GlowButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let action: () -> Void
    @State private var isPressed = false
    @State private var showGlow = false

    public init(title: String, icon: String? = nil, gradient: LinearGradient, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: 16))
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(gradient)
            .cornerRadius(28)
            .shadow(color: Color(red: 1, green: 0.5, blue: 0).opacity(0.6), radius: showGlow ? 20 : 10)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

#Preview {
    GlowButton(
        title: "Details",
        icon: "✨",
        gradient: LinearGradient(
            gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.6), Color(red: 1, green: 0.6, blue: 0.2)]),
            startPoint: .leading,
            endPoint: .trailing
        ),
        action: {}
    )
    .padding()
}
