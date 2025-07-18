//
//  FeedView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedFilter: FeedFilter = .all
    @State private var showingCreatePost = false
    @State private var selectedRewardType: RewardType?
    @State private var showingSearch = false
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Header with animation
                    HStack {
                        Text(greetingText())
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .transition(.opacity.combined(with: .scale))
                            .id(greetingText()) // Force re-animation on text change
                        
                        Spacer()
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            // Search button
                            Button(action: { showingSearch = true }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .frame(width: 44, height: 44)
                                    .background(DesignSystem.Colors.backgroundSecondary)
                                    .clipShape(Circle())
                            }
                            
                            // Notification bell with bounce animation
                            NotificationBellButton()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Filter chips
                    FilterPickerView(selectedFilter: $selectedFilter)
                    
                    // Feed content
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        LoadingView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                    } else if viewModel.posts.isEmpty {
                        EmptyFeedView { showingCreatePost = true }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                    } else {
                        // Task cards with staggered animation
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                                PostCardView(post: post)
                                    .slideInAnimation(delay: Double(index) * 0.1)
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                                    .scaleEffect(1.2)
                                    .tint(DesignSystem.Colors.primaryGreen)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            
            // Animated Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AnimatedFAB { type in
                        selectedRewardType = type
                        showingCreatePost = true
                        
                        // Haptic feedback
                        #if os(iOS)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        #endif
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(selectedRewardType: selectedRewardType)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
        .onChange(of: selectedFilter) { newFilter in
            viewModel.filterChanged(to: newFilter)
        }
    }
    
    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        return "\(greeting)!"
    }
}

struct FilterPickerView: View {
    @Binding var selectedFilter: FeedFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FeedFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedFilter = filter
                            }
                            
                            // Haptic feedback
                            #if os(iOS)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            #endif
                        }
                    )
                    .scaleEffect(selectedFilter == filter ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedFilter)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct PostCardView: View {
    let post: Post
    @State private var showingDetail = false
    
    var body: some View {
        ModernTaskCard(
            rewardType: post.rewardType,
            title: post.title,
            description: post.description,
            value: formatValue(for: post),
            location: post.locationName ?? "Unknown",
            timeAgo: timeAgoText(for: post),
            userName: post.user?.username ?? "Anonymous",
            userAvatar: nil,
            isPrivateProfile: post.user?.isPrivateProfile ?? false
        ) {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            GamifiedPostDetailView(post: post)
        }
    }
    
    private func formatValue(for post: Post) -> String {
        return post.displayValue
    }
    
    private func timeAgoText(for post: Post) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: post.createdAt, relativeTo: Date())
    }
}


struct EmptyFeedView: View {
    let onCreatePost: () -> Void
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .rotationEffect(.degrees(animateIcon ? -10 : 10))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
                .onAppear { animateIcon = true }
            
            VStack(spacing: 8) {
                Text("No Posts Yet")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .transition(.scale.combined(with: .opacity))
                
                Text("Be the first to share a post in your community!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .transition(.slide)
            }
            
            Button("Create Your First Post") {
                onCreatePost()
            }
            .buttonStyle(PrimaryButtonStyle())
            .shimmer()
        }
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.primaryGreen.opacity(0.3), lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(DesignSystem.Colors.primaryGradient, lineWidth: 4)
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            .onAppear { isAnimating = true }
            
            Text("Loading posts...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .opacity(isAnimating ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
        }
    }
}

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Text(post.title)
                                    .font(DesignSystem.Typography.largeTitle)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Spacer()
                                
                                RewardTypeBadge(rewardType: post.rewardType, value: post.displayValue)
                            }
                            
                            if let user = post.user {
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    Circle()
                                        .fill(DesignSystem.Colors.backgroundSecondary)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(user.username.prefix(1).uppercased())
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user.username)
                                            .font(DesignSystem.Typography.bodyMedium)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                        
                                        Text("Karma: \(user.karmaBalance)")
                                            .font(DesignSystem.Typography.footnote)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        // Description
                        Text(post.description)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        // Details
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            DetailRow(icon: post.rewardType.icon, title: "\(post.rewardType.displayName) Value", value: post.displayValue)
                            DetailRow(icon: "clock.fill", title: "Posted", value: post.timeRemaining ?? "Just now")
                            
                            if let locationName = post.locationName {
                                DetailRow(icon: "location.fill", title: "Location", value: locationName)
                            }
                            
                            DetailRow(icon: "tag.fill", title: "Type", value: post.isRequest ? "Request" : "Offer")
                        }
                        
                        Spacer()
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.Colors.primaryGreen)
                .frame(width: 20)
            
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

#Preview {
    FeedView()
} 
