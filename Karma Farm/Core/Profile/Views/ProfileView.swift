//
//  ProfileView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingKarmaHistory = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = authManager.currentUser {
                        // Profile Header
                        ProfileHeaderView(user: user, showingKarmaHistory: $showingKarmaHistory)
                        
                        // Stats Section
                        StatsCardView(stats: viewModel.userStats)
                        
                        // Skills & Interests
                        SkillsInterestsView(user: user)
                        
                        // Badges
                        BadgesView(badges: user.badges)
                        
                        // Recent Posts
                        RecentPostsView()
                    } else {
                        // Loading or error state
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            
                            Text("Loading profile...")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditProfile = true }) {
                            Label("Edit Profile", systemImage: "pencil")
                        }
                        
                        Button(action: { showingSettings = true }) {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Divider()
                        
                        Button(action: { authManager.signOut() }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingKarmaHistory) {
                 KarmaHistoryView()
            }
        }
        .onAppear {
            viewModel.loadUserStats()
        }
    }
}

struct ProfileHeaderView: View {
    let user: User
    @Binding var showingKarmaHistory: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Picture
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 120, height: 120)
                .overlay(
                    Group {
                        if let profilePicture = user.profilePicture {
                            AsyncImage(url: URL(string: profilePicture)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        } else {
                            Text(user.username.prefix(1).uppercased())
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                )
                .overlay(
                    Circle()
                        .stroke(Color.purple, lineWidth: 3)
                )
            
            // User Info
            VStack(spacing: 8) {
                Text(user.username)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Karma Balance
                Button {
                    showingKarmaHistory = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        
                        Text("\(user.karmaBalance) Karma")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.orange)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
    }
}

struct StatsCardView: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("My Impact")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            HStack {
                StatItemView(
                    title: "Posts Created",
                    value: "\(stats.postsCreated)",
                    icon: "plus.circle.fill",
                    color: .blue
                )
                
                StatItemView(
                    title: "Karma Earned",
                    value: "\(stats.karmaEarned)",
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
                
                StatItemView(
                    title: "Karma Given",
                    value: "\(stats.karmaGiven)",
                    icon: "arrow.down.circle.fill",
                    color: .red
                )
                
                StatItemView(
                    title: "Connections",
                    value: "\(stats.connections)",
                    icon: "person.2.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SkillsInterestsView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 20) {
            if !user.skills.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Skills")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100), spacing: 8)
                    ], spacing: 8) {
                        ForEach(user.skills, id: \.self) { skill in
                            SkillChip(text: skill, color: .blue)
                        }
                    }
                }
            }
            
            if !user.interests.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Interests")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100), spacing: 8)
                    ], spacing: 8) {
                        ForEach(user.interests, id: \.self) { interest in
                            SkillChip(text: interest, color: .green)
                        }
                    }
                }
            }
        }
    }
}

struct SkillChip: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 1)
            )
    }
}

struct BadgesView: View {
    let badges: [Badge]
    
    var body: some View {
        if !badges.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Badges")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150), spacing: 12)
                ], spacing: 12) {
                    ForEach(badges) { badge in
                        BadgeCardView(badge: badge)
                    }
                }
            }
        }
    }
}

struct BadgeCardView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.system(size: 32))
                .foregroundColor(badge.color)
            
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(badge.value)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentPostsView: View {
    @State private var recentPosts: [Post] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Posts")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("See All") {
                    // TODO: Navigate to user's posts
                }
                .font(.system(size: 14))
                .foregroundColor(.purple)
            }
            
            if recentPosts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No posts yet")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(recentPosts.prefix(3)) { post in
                    PostSummaryView(post: post)
                }
            }
        }
        .onAppear {
            loadRecentPosts()
        }
    }
    
    private func loadRecentPosts() {
        // TODO: Load user's recent posts
        recentPosts = []
    }
}

struct PostSummaryView: View {
    let post: Post
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(post.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(post.karmaValue)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                
                if let timeRemaining = post.timeRemaining {
                    Text(timeRemaining)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Placeholder views
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Profile")
                    .font(.title)
                
                Text("Profile editing functionality will be implemented here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(AuthManager.mockAuthenticated)
} 
