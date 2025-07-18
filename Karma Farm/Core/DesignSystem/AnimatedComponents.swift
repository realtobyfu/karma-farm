import SwiftUI

// MARK: - Animated Floating Action Button
struct AnimatedFAB: View {
    @State private var isExpanded = false
    @State private var showOptions = false
    let rewardTypes: [RewardType] = RewardType.allCases
    let onRewardTypeSelected: (RewardType) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background overlay when expanded
            if isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        collapse()
                    }
                    .transition(.opacity)
            }
            
            // Reward type options
            if showOptions {
                VStack(alignment: .trailing, spacing: 16) {
                    ForEach(rewardTypes.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            Text(rewardTypes[index].description)
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(DesignSystem.Colors.surface)
                                .cornerRadius(DesignSystem.Radius.medium)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            Button(action: {
                                onRewardTypeSelected(rewardTypes[index])
                                collapse()
                            }) {
                                Image(systemName: rewardTypes[index].icon)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(rewardTypes[index].gradient)
                                    .clipShape(Circle())
                                    .shadow(color: rewardTypes[index].primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .scaleEffect(showOptions ? 1 : 0.5)
                            .opacity(showOptions ? 1 : 0)
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                value: showOptions
                            )
                        }
                    }
                }
                .padding(.bottom, 80)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Main FAB button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                
                if isExpanded {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showOptions = true
                        }
                    }
                } else {
                    collapse()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(DesignSystem.Colors.primaryGradient)
                    .clipShape(Circle())
                    .shadow(color: DesignSystem.Colors.primaryGreen.opacity(0.4), radius: 12, x: 0, y: 6)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    .scaleEffect(isExpanded ? 0.9 : 1.0)
            }
        }
    }
    
    private func collapse() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showOptions = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded = false
            }
        }
    }
}

// MARK: - Pull to Refresh
struct PullToRefresh: View {
    let isRefreshing: Binding<Bool>
    let onRefresh: () async -> Void
    
    @State private var pullProgress: CGFloat = 0
    @State private var isTriggered = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Refresh indicator
                RefreshIndicator(progress: pullProgress, isRefreshing: isRefreshing.wrappedValue)
                    .frame(height: 80)
                    .offset(y: -80 + (pullProgress * 80))
            }
        }
    }
}

struct RefreshIndicator: View {
    let progress: CGFloat
    let isRefreshing: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primaryGreen))
                    .scaleEffect(1.2)
            } else {
                Image(systemName: "arrow.down")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
                    .rotationEffect(.degrees(progress * 180))
                    .opacity(progress)
            }
        }
        .onAppear {
            if isRefreshing {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}

// MARK: - Animated Tab Bar
struct AnimatedTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, title: String)]
    
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTab = index
                        }
                        
                        // Haptic feedback
                        #if os(iOS)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        #endif
                    }
                )
            }
        }
        .padding(.vertical, 8)
        .background(DesignSystem.Colors.surface)
        .overlay(
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// TabBarItem is now defined in ModernUIComponents.swift

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(25))
                .offset(x: phase * 200 - 100)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Bounce Animation
struct BounceAnimationModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                    scale = 1.2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
    }
}

extension View {
    func bounceEffect(trigger: Bool) -> some View {
        modifier(BounceAnimationModifier(trigger: trigger))
    }
}

// MARK: - Sliding Card Animation
struct SlidingCardModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: appeared ? 0 : 100)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func slideInAnimation(delay: Double = 0) -> some View {
        modifier(SlidingCardModifier(delay: delay))
    }
}