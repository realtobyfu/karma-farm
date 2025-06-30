import SwiftUI

// MARK: - Task Card Component with Enhanced Animations
struct ModernTaskCard: View {
    let taskType: TaskType
    let title: String
    let description: String
    let value: String
    let location: String
    let timeAgo: String
    let userName: String
    let userAvatar: String?
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showingHeart = false
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Avatar with pulse animation on tap
                Circle()
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(userName.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    )
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Task Type Badge with bounce effect
                TaskTypeBadge(taskType: taskType, value: value)
                    .bounceEffect(trigger: isPressed)
            }
            .padding(16)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(3)
            }
            .padding(.horizontal, 16)
            
            // Footer
            HStack(spacing: 16) {
                Label(location, systemImage: "location.fill")
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    action()
                }) {
                    HStack(spacing: 4) {
                        Text("View Details")
                            .font(.system(size: 14, weight: .medium))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .offset(x: isPressed ? 3 : 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                    }
                    .foregroundStyle(taskType.gradient)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: taskType.primaryColor.opacity(0.15), radius: isPressed ? 15 : 10, x: 0, y: isPressed ? 8 : 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(dragAmount)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: dragAmount)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Haptic feedback
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragAmount = CGSize(width: value.translation.width * 0.1, height: 0)
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        dragAmount = .zero
                    }
                }
        )
    }
}

// MARK: - Task Type Badge with Animation
struct TaskTypeBadge: View {
    let taskType: TaskType
    let value: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: taskType.icon)
                .font(.system(size: 14, weight: .semibold))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(taskType.gradient)
        .cornerRadius(20)
        .onAppear {
            if taskType == .fun {
                isAnimating = true
            }
        }
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? DesignSystem.Colors.primaryGradient : LinearGradient(colors: [Color(UIColor.systemGray6)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(UIColor.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodySemibold)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(DesignSystem.Colors.primaryGradient)
            .cornerRadius(DesignSystem.Radius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: DesignSystem.Colors.primaryGreen.opacity(configuration.isPressed ? 0.2 : 0.3), 
                    radius: configuration.isPressed ? 4 : 8, 
                    x: 0, 
                    y: configuration.isPressed ? 2 : 4)
    }
}