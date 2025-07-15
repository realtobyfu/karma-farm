//
//  ProfileDetailsView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 7/13/25.
//

import SwiftUI

struct ProfileDetailsView: View {
    let userId: String
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ProfileDetailsViewModel()
    @State private var showingChat = false
    
    var isOwnProfile: Bool {
        userId == authManager.currentUser?.id
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadUserProfile(userId: userId)
                        }
                    }
                    .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
                } else if let user = viewModel.user {
                    profileContent(for: user)
                }
            }
            .padding()
        }
        .navigationTitle(isOwnProfile ? "My Profile" : "Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !isOwnProfile && viewModel.user != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileActions
                }
            }
        }
        .sheet(isPresented: $showingChat) {
            if let user = viewModel.user {
                ChatDetailView(chat: createChatWithUser(user))
            }
        }
        .task {
            await viewModel.loadUserProfile(userId: userId)
        }
    }
    
    @ViewBuilder
    private func profileContent(for user: User) -> some View {
        // Profile Header
        ProfileHeaderSection(user: user, isPrivate: user.isPrivateProfile && !isOwnProfile)
        
        // Private Profile Notice
        if user.isPrivateProfile && !isOwnProfile && !viewModel.isConnected {
            PrivateProfileNotice()
        }
        
        // Show full content if own profile, public profile, or connected
        if isOwnProfile || !user.isPrivateProfile || viewModel.isConnected {
            // Stats Section
            if user.karmaBalance > 0 {
                StatsSection(karmaBalance: user.karmaBalance)
            }
            
            // Bio
            if let bio = user.bio, !bio.isEmpty {
                BioSection(bio: bio)
            }
            
            // Skills & Interests
            if !user.skills.isEmpty || !user.interests.isEmpty {
                SkillsInterestsSection(skills: user.skills, interests: user.interests)
            }
            
            // Badges
            if !user.badges.isEmpty {
                BadgesSection(badges: user.badges)
            }
            
            // Recent Posts
            if !user.isPrivateProfile || viewModel.isConnected || isOwnProfile {
                RecentPostsSection(userId: user.id)
            }
        }
    }
    
    @ViewBuilder
    private var profileActions: some View {
        Menu {
            if let user = viewModel.user {
                if user.privacySettings?.allowDirectMessages ?? true {
                    Button {
                        showingChat = true
                    } label: {
                        Label("Message", systemImage: "message")
                    }
                }
                
                if user.isPrivateProfile && !viewModel.isConnected {
                    Button {
                        Task {
                            await viewModel.sendConnectionRequest()
                        }
                    } label: {
                        Label("Send Connection Request", systemImage: "person.badge.plus")
                    }
                } else if viewModel.isConnected {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.removeConnection()
                        }
                    } label: {
                        Label("Remove Connection", systemImage: "person.badge.minus")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundColor(DesignSystem.Colors.primaryGreen)
        }
    }
    
    private func createChatWithUser(_ user: User) -> Chat {
        // Create a temporary chat object for the chat view
        Chat(
            id: UUID().uuidString,
            postId: "",  // No post associated with direct message
            post: nil,
            requesterId: authManager.currentUser!.id,
            requester: authManager.currentUser,
            offererId: user.id,
            offerer: user,
            status: "active",
            lastMessage: nil,
            lastMessageAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

struct ProfileHeaderSection: View {
    let user: User
    let isPrivate: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Profile Picture
            if isPrivate || user.profilePicture == nil {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: isPrivate ? "lock.fill" : "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            } else {
                AsyncImage(url: URL(string: user.profilePicture!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 120, height: 120)
                }
            }
            
            // Username and verification
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(user.username)
                    .font(DesignSystem.Typography.title2)
                
                if user.isPhoneVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(DesignSystem.Colors.primaryGreen)
                        .font(.system(size: 18))
                }
                
                if isPrivate {
                    Image(systemName: "lock.fill")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .font(.system(size: 16))
                }
            }
            
            // Member since
            Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

struct PrivateProfileNotice: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("This profile is private")
                .font(DesignSystem.Typography.title3)
            
            Text("Connect to see more information")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(DesignSystem.Radius.medium)
    }
}

struct StatsSection: View {
    let karmaBalance: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Karma Balance")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("\(karmaBalance)")
                .font(DesignSystem.Typography.numberLarge)
                .foregroundColor(DesignSystem.Colors.primaryGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(DesignSystem.Radius.medium)
    }
}

struct BioSection: View {
    let bio: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("About")
                .font(DesignSystem.Typography.title3)
            
            Text(bio)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SkillsInterestsSection: View {
    let skills: [String]
    let interests: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            if !skills.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Skills")
                        .font(DesignSystem.Typography.title3)
                    
                    FlowLayout(spacing: DesignSystem.Spacing.xs) {
                        ForEach(skills, id: \.self) { skill in
                            SimpleTagView(text: skill, style: .primary)
                        }
                    }
                }
            }
            
            if !interests.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Interests")
                        .font(DesignSystem.Typography.title3)
                    
                    FlowLayout(spacing: DesignSystem.Spacing.xs) {
                        ForEach(interests, id: \.self) { interest in
                            SimpleTagView(text: interest, style: .secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BadgesSection: View {
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Badges")
                .font(DesignSystem.Typography.title3)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DesignSystem.Spacing.md) {
                ForEach(badges) { badge in
                    BadgeView(badge: badge)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RecentPostsSection: View {
    let userId: String
    @State private var posts: [Post] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Recent Posts")
                .font(DesignSystem.Typography.title3)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if posts.isEmpty {
                Text("No posts yet")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(posts.prefix(5)) { post in
                    NavigationLink(destination: GamifiedPostDetailView(post: post)) {
                        MiniPostCard(post: post)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            // TODO: Load user's recent posts
            isLoading = false
            posts = [] // Will be populated when API is ready
        }
    }
}

struct MiniPostCard: View {
    let post: Post
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(post.title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                
                HStack {
                    Label("\(post.karmaValue)", systemImage: "star.fill")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.primaryOrange)
                    
                    Text("•")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(post.type.displayName)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding()
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(DesignSystem.Radius.small)
    }
}

// MARK: - View Model
@MainActor
class ProfileDetailsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isConnected = false
    
    func loadUserProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement API call to fetch user profile
            // For now, using mock data
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            if userId == User.mockUser.id {
                user = User.mockUser
            } else {
                user = User.mockUsers.first { $0.id == userId }
            }
            
            // TODO: Check connection status
            isConnected = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func sendConnectionRequest() async {
        // TODO: Implement connection request
        print("Sending connection request")
    }
    
    func removeConnection() async {
        // TODO: Implement remove connection
        print("Removing connection")
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content
    
    var body: some View {
        // Simple horizontal wrap implementation
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: spacing) {
            content
        }
    }
}

struct SimpleTagView: View {
    let text: String
    let style: TagStyle
    
    enum TagStyle {
        case primary, secondary
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.primaryGreen.opacity(0.15)
            case .secondary:
                return DesignSystem.Colors.primaryBlue.opacity(0.15)
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.primaryGreen
            case .secondary:
                return DesignSystem.Colors.primaryBlue
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.caption)
            .foregroundColor(style.textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(style.backgroundColor)
            .cornerRadius(DesignSystem.Radius.small)
    }
}

struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: badge.icon)
                .font(.system(size: 24))
                .foregroundColor(badgeColor)
            
            Text(badge.title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 70, height: 70)
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(DesignSystem.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(badgeColor.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var badgeColor: Color {
        switch badge.type {
        case "verified":
            return DesignSystem.Colors.primaryGreen
        case "college":
            return DesignSystem.Colors.primaryBlue
        case "helper":
            return DesignSystem.Colors.primaryOrange
        default:
            return DesignSystem.Colors.textSecondary
        }
    }
}

#Preview {
    NavigationView {
        ProfileDetailsView(userId: User.mockUser.id)
            .environmentObject(AuthManager.shared)
    }
}