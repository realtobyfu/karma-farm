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
    @State private var selectedTaskType: TaskType?
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Header
                    HStack {
                        Text(greetingText())
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                        
                        // Notification bell
                        Button(action: {}) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
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
                        // Task cards
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(viewModel.posts) { post in
                                PostCardView(post: post)
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
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
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingCreateButton { type in
                        selectedTaskType = type
                        showingCreatePost = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(selectedTaskType: selectedTaskType)
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
                            selectedFilter = filter
                        }
                    )
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
            taskType: post.taskType,
            title: post.title,
            description: post.description,
            value: formatValue(for: post),
            location: post.locationName ?? "Unknown",
            timeAgo: timeAgoText(for: post),
            userName: post.user?.username ?? "Anonymous",
            userAvatar: nil
        ) {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            PostDetailView(post: post)
        }
    }
    
    private func formatValue(for post: Post) -> String {
        switch post.taskType {
        case .cash:
            return "$\(post.karmaValue)"
        case .karma:
            return "\(post.karmaValue)"
        case .fun:
            return "Fun!"
        }
    }
    
    private func timeAgoText(for post: Post) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: post.createdAt, relativeTo: Date())
    }
}


struct EmptyFeedView: View {
    let onCreatePost: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            VStack(spacing: 8) {
                Text("No Posts Yet")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Be the first to share a post in your community!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button("Create Your First Post") {
                onCreatePost()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(DesignSystem.Colors.primaryGreen)
            
            Text("Loading posts...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
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
                            Text(post.title)
                                .font(DesignSystem.Typography.largeTitle)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
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
                            DetailRow(icon: "star.fill", title: "Karma Value", value: "\(post.karmaValue)")
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
