import SwiftUI

// MARK: - Reward Type Badge
struct RewardTypeBadge: View {
    let rewardType: RewardType
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rewardType.icon)
                .font(.system(size: 14, weight: .semibold))
            
            Text(value)
                .font(DesignSystem.Typography.numberSmall)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(rewardType.gradient)
        .cornerRadius(DesignSystem.Radius.extraLarge)
    }
}

// MARK: - Modern Task Card
struct ModernTaskCard: View {
    let rewardType: RewardType
    let title: String
    let description: String
    let value: String
    let location: String
    let timeAgo: String
    let userName: String
    let userAvatar: String?
    let isPrivateProfile: Bool
    let onTap: () -> Void
    
    init(rewardType: RewardType,
         title: String,
         description: String,
         value: String,
         location: String,
         timeAgo: String,
         userName: String,
         userAvatar: String? = nil,
         isPrivateProfile: Bool = false,
         onTap: @escaping () -> Void) {
        self.rewardType = rewardType
        self.title = title
        self.description = description
        self.value = value
        self.location = location
        self.timeAgo = timeAgo
        self.userName = userName
        self.userAvatar = userAvatar
        self.isPrivateProfile = isPrivateProfile
        self.onTap = onTap
    }
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(userName.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(userName)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        if isPrivateProfile {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    Text(timeAgo)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Reward Type Badge
                RewardTypeBadge(rewardType: rewardType, value: value)
            }
            .padding(DesignSystem.Spacing.md)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(3)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            
            // Footer
            HStack(spacing: 16) {
                Label(location, systemImage: "location.fill")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Button(action: onTap) {
                    Text("View Details")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(rewardType.primaryColor)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                onTap()
            }
        }
    }
}

// MARK: - Reward Type Option
struct RewardTypeOption: View {
    let type: RewardType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(type.displayName)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(type.gradient)
                    .clipShape(Circle())
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.Radius.pill)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Floating Action Button
struct FloatingCreateButton: View {
    @State private var isExpanded = false
    @State private var selectedType: RewardType?
    let onSelectType: (RewardType) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background overlay when expanded
            if isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }
            }
            
            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.md) {
                // Reward type options
                if isExpanded {
                    ForEach(RewardType.allCases, id: \.self) { type in
                        RewardTypeOption(type: type) {
                            selectedType = type
                            withAnimation(.spring()) {
                                isExpanded = false
                            }
                            onSelectType(type)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Main button
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Group {
                                if isExpanded {
                                    Color.gray
                                } else {
                                    DesignSystem.Colors.primaryGradient
                                }
                            }
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .rotationEffect(.degrees(isExpanded ? 45 : 0))
                }
            }
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.textSecondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                if isSelected {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGreen)
                        .frame(width: 5, height: 5)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }
}

// MARK: - Modern Tab Bar
struct ModernTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                if index == 2 {
                    // Empty space for floating button
                    Spacer()
                        .frame(width: 56)
                } else {
                    TabBarItem(
                        icon: tabIcon(for: index),
                        isSelected: selectedTab == index
                    ) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Colors.surface
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
        )
    }
    
    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "map.fill"
        case 3: return "bubble.left.fill"
        case 4: return "person.crop.circle.fill"
        default: return ""
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    isSelected ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.surface
                )
                .cornerRadius(DesignSystem.Radius.extraLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge)
                        .stroke(isSelected ? Color.clear : DesignSystem.Colors.backgroundSecondary, lineWidth: 1)
                )
        }
    }
}

// MARK: - Modern Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    let rewardType: RewardType?
    
    init(rewardType: RewardType? = nil) {
        self.rewardType = rewardType
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                rewardType?.gradient ?? DesignSystem.Colors.primaryGradient
            )
            .cornerRadius(DesignSystem.Radius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(DesignSystem.Colors.primaryGreen)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .stroke(DesignSystem.Colors.primaryGreen, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}