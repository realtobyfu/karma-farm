import SwiftUI

struct NotificationBellButton: View {
    @State private var hasNotifications = true // Mock state
    @State private var isAnimating = false
    @State private var bellRotation: Double = 0
    
    var body: some View {
        Button(action: {
            // Trigger bell animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                bellRotation = 15
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    bellRotation = -15
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    bellRotation = 0
                }
            }
            
            // Haptic feedback
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .rotationEffect(.degrees(bellRotation))
                
                if hasNotifications {
                    Circle()
                        .fill(DesignSystem.Colors.primaryOrange)
                        .frame(width: 8, height: 8)
                        .offset(x: 6, y: -2)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear { isAnimating = true }
                }
            }
        }
    }
}