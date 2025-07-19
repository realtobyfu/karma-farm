import SwiftUI

// MARK: - Demo View showcasing the new UI components
struct ModernUIDemo: View {
    @State private var selectedTab = 0
    @State private var selectedFilter = "All"
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Good morning! 👋")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["All", "Karma", "Paid", "Fun", "Nearby"], id: \.self) { filter in
                            FilterChip(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, DesignSystem.Spacing.md)
                
                // Sample task cards
                ScrollView {
                    VStack(spacing: 16) {
                        // Karma task
                        ModernTaskCard(
                            rewardType: .karma,
                            postType: .task,
                            title: "Help me move furniture",
                            description: "Need 2 people to help move some furniture to my new apartment. Should take about 2 hours.",
                            value: "25 karma",
                            location: "Cambridge, MA",
                            timeAgo: "2h ago",
                            userName: "John Doe",
                            userAvatar: nil
                        ) {
                            print("Karma task tapped")
                        }
                        
                        // Cash task
                        ModernTaskCard(
                            rewardType: .cash,
                            postType: .skillShare,
                            title: "iOS App Development",
                            description: "Looking for developer to build a simple app for my small business. Experience with SwiftUI preferred.",
                            value: "$150",
                            location: "Remote",
                            timeAgo: "4h ago",
                            userName: "Sarah Smith",
                            userAvatar: nil
                        ) {
                            print("Cash task tapped")
                        }
                        
                        // Fun task
                        ModernTaskCard(
                            rewardType: .fun,
                            postType: .social,
                            title: "Basketball Pickup Game",
                            description: "Join us for friendly basketball this weekend! All skill levels welcome. We play every Saturday morning.",
                            value: "Just for fun",
                            location: "MIT Courts",
                            timeAgo: "1d ago",
                            userName: "Mike Johnson",
                            userAvatar: nil
                        ) {
                            print("Fun task tapped")
                        }
                        
                        // Buttons demo
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Button("Primary Karma Button") {}
                                .buttonStyle(PrimaryButtonStyle(rewardType: .karma))
                            
                            Button("Primary Cash Button") {}
                                .buttonStyle(PrimaryButtonStyle(rewardType: .cash))
                            
                            Button("Primary Fun Button") {}
                                .buttonStyle(PrimaryButtonStyle(rewardType: .fun))
                            
                            Button("Secondary Button") {}
                                .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, 120) // Space for floating button and tab bar
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingCreateButton { type in
                        print("Selected reward type: \(type)")
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
            
            // Modern Tab Bar
            VStack {
                Spacer()
                ModernTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Color Palette Demo
struct ColorPaletteDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("Design System Colors")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                // Primary Colors
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Primary Colors")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ColorSwatch(color: DesignSystem.Colors.primaryGreen, name: "Green")
                        ColorSwatch(color: DesignSystem.Colors.primaryBlue, name: "Blue")
                        ColorSwatch(color: DesignSystem.Colors.primaryOrange, name: "Orange")
                        ColorSwatch(color: DesignSystem.Colors.primaryPurple, name: "Purple")
                    }
                }
                
                // Gradients
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Task Type Gradients")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        GradientSwatch(gradient: DesignSystem.Colors.karmaGradient, name: "Karma Gradient")
                        GradientSwatch(gradient: DesignSystem.Colors.cashGradient, name: "Cash Gradient")
                        GradientSwatch(gradient: DesignSystem.Colors.funGradient, name: "Fun Gradient")
                    }
                }
                
                // Typography Demo
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Typography Scale")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Large Title")
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Title 1")
                            .font(DesignSystem.Typography.title1)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Title 2")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Body Text")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Body Medium")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Caption Text")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.backgroundPrimary)
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(color)
                .frame(width: 60, height: 60)
            
            Text(name)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

struct GradientSwatch: View {
    let gradient: LinearGradient
    let name: String
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(gradient)
                .frame(width: 100, height: 40)
            
            Text(name)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
        }
    }
}

#Preview("Modern UI Demo") {
    ModernUIDemo()
}

#Preview("Color Palette Demo") {
    ColorPaletteDemo()
}