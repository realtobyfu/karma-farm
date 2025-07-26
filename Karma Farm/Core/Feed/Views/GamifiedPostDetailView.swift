import SwiftUI
import MapKit

struct GamifiedPostDetailView: View {
    let post: Post
    @State private var isInterested = false
    @State private var isBookmarked = false
    @State private var showKarmaAnimation = false
    @State private var interestedCount = 42
    @State private var showingMap = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Hero Header
                    HeroHeaderView(post: post)
                        .padding(.bottom, DesignSystem.Spacing.md)
                    
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Post Main Content Card
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            // Reward Type Badge with Post Type
                            HStack(spacing: 12) {
                                AnimatedTaskBadge(
                                    rewardType: post.rewardType,
                                    value: post.displayValue
                                )
                                
                                if post.type != .social {
                                    Text(post.type.postTypeLabel)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(post.type.postTypeColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(post.type.postTypeColor.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                            }
                            
                            // Title and Description
                            PostContentSection(
                                title: post.title,
                                description: post.description
                            )
                            
                            // Location Section
                            if let locationName = post.locationName {
                                LocationSection(locationName: locationName) {
                                    showingMap = true
                                }
                            }
                            
                            // Expiration Timer
                            if let timeRemaining = post.timeRemaining {
                                ExpirationTimer(timeRemaining: timeRemaining)
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // User Profile Card (Gamified)
                        if let user = post.user {
                            GamifiedUserCard(
                                user: user,
                                isAnonymous: post.isAnonymous ?? false,
                                anonymousDisplayName: post.anonymousDisplayName
                            )
                        }
                        
                        // Social Proof Bar
                        SocialProofBar(
                            viewCount: 128,
                            interestedCount: interestedCount,
                            upvotes: 89
                        )
                        
                        // Post Details Card
                        PostDetailsCard(post: post)
                        
                        // Action Buttons
                        ActionButtonsSection(
                            post: post,
                            isInterested: $isInterested,
                            isBookmarked: $isBookmarked,
                            showKarmaAnimation: $showKarmaAnimation,
                            interestedCount: $interestedCount,
                            onInterestAction: handleInterestAction
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, 32)
                }
            }
            .background(DesignSystem.Colors.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            MapView()
        }
        .overlay(
            KarmaAnimation(show: $showKarmaAnimation)
        )
    }
    
    private func handleInterestAction() async {
        withAnimation(.spring()) {
            isInterested = true
            interestedCount += 1
            showKarmaAnimation = true
        }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Here you would typically:
        // 1. Send interest notification to post creator
        // 2. Create or open chat
        // 3. Update backend
    }
}

// MARK: - Hero Header
struct HeroHeaderView: View {
    let post: Post
    @State private var gradientOffset: CGFloat = -200
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Animated Background Gradient
            LinearGradient(
                colors: [
                    rewardTypeColor(post.rewardType),
                    rewardTypeColor(post.rewardType).opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            .overlay(
                LinearGradient(
                    colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 150)
                .offset(x: gradientOffset)
                .blur(radius: 20)
            )
            
            // Post Type Icon
            Image(systemName: post.type.icon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.2))
                .offset(x: 80, y: -10)
                .rotationEffect(.degrees(15))
            
            // Status Badge if not active
            if post.status != .active {
                HStack {
                    Image(systemName: post.status == .completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(post.status.displayName.uppercased())
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(post.status == .completed ? Color.green : Color.red)
                .cornerRadius(20)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                gradientOffset = 200
            }
        }
    }
    
    private func rewardTypeColor(_ type: RewardType) -> Color {
        switch type {
        case .karma:
            return DesignSystem.Colors.primaryBlue
        case .cash:
            return DesignSystem.Colors.primaryOrange
        case .fun:
            return DesignSystem.Colors.primaryPurple
        }
    }
}

// MARK: - Gamified User Card
struct GamifiedUserCard: View {
    let user: User
    let isAnonymous: Bool
    let anonymousDisplayName: String?
    
    private var displayName: String {
        isAnonymous ? (anonymousDisplayName ?? "Anonymous Helper") : user.username
    }
    
    // Karma level calculation
    private var karmaLevel: (level: Int, title: String, progress: Double) {
        let karma = user.karmaBalance
        let level = min(karma / 100 + 1, 50) // Max level 50
        let progressInCurrentLevel = Double((karma % 100)) / 100.0
        
        let title: String
        switch level {
        case 1...5: title = "Novice Helper"
        case 6...10: title = "Community Friend"
        case 11...20: title = "Karma Warrior"
        case 21...30: title = "Local Hero"
        case 31...40: title = "Master Helper"
        case 41...50: title = "Karma Legend"
        default: title = "Beginner"
        }
        
        return (level, title, progressInCurrentLevel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                // Profile Picture with Level Badge
                ZStack(alignment: .bottomTrailing) {
                    if let profilePicture = user.profilePicture {
                        AsyncImage(url: URL(string: profilePicture)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(DesignSystem.Colors.primaryGreen.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(displayName.prefix(2).uppercased())
                                    .font(DesignSystem.Typography.bodySemibold)
                                    .foregroundColor(DesignSystem.Colors.primaryGreen)
                            )
                    }
                    
                    // Level Badge
                    if !isAnonymous {
                        Circle()
                            .fill(DesignSystem.Colors.primaryGreen)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(karmaLevel.level)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 20, y: -20)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Name and Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayName)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        if !isAnonymous {
                            Text(karmaLevel.title)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.primaryGreen)
                        }
                    }
                    
                    // Karma Display - Simplified
                    if !isAnonymous {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(user.karmaBalance) karma")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Stats Column
                if !isAnonymous {
                    VStack(spacing: 4) {
                        StatBadge(value: "95%", label: "Success", color: .green)
                        StatBadge(value: "42", label: "Helped", color: .blue)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            
            // Achievement Badges - Limited to top 3
            if !isAnonymous && !user.badges.isEmpty {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(user.badges.prefix(3), id: \.id) { badge in
                        BadgeChip(badge: badge)
                    }
                    
                    if user.badges.count > 3 {
                        Text("+\(user.badges.count - 3)")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Social Proof Bar
struct SocialProofBar: View {
    let viewCount: Int
    let interestedCount: Int
    let upvotes: Int
    
    var body: some View {
        HStack(spacing: 20) {
            SocialProofItem(icon: "eye.fill", value: "\(viewCount)", label: "views")
            SocialProofItem(icon: "person.2.fill", value: "\(interestedCount)", label: "interested", highlighted: true)
            SocialProofItem(icon: "hand.thumbsup.fill", value: "\(upvotes)", label: "upvotes")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(30)
    }
}

struct SocialProofItem: View {
    let icon: String
    let value: String
    let label: String
    var highlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(highlighted ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.textSecondary)
            
            VStack(spacing: 0) {
                Text(value)
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(highlighted ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.textPrimary)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Post Content Section
struct PostContentSection: View {
    let title: String
    let description: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Details")
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text(description)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut, value: isExpanded)
            
            if description.count > 150 {
                Button(action: { isExpanded.toggle() }) {
                    Text(isExpanded ? "Show less" : "Read more")
                        .font(DesignSystem.Typography.bodySemibold)
                        .foregroundColor(DesignSystem.Colors.primaryGreen)
                }
            }
        }
    }
}

// MARK: - Details Card
struct PostDetailsCard: View {
    let post: Post
    
    var body: some View {
        VStack(spacing: 0) {
            // Karma Impact Preview
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Karma Impact")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: getKarmaIcon(for: post))
                            .foregroundColor(getKarmaColor(for: post))
                        Text(post.displayValue)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                Spacer()
                
                // Difficulty Badge (only for karma posts)
                if let karmaValue = post.karmaValue {
                    DifficultyBadge(karma: karmaValue)
                }
            }
            .padding(DesignSystem.Spacing.md)
            
            Divider()
            
            // Skills Required
            if !post.tags.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Skills Involved")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(post.tags, id: \.self) { tag in
                                SkillTag(text: tag)
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(12)
    }
}

// MARK: - Action Buttons
struct ActionButtonsSection: View {
    let post: Post
    @Binding var isInterested: Bool
    @Binding var isBookmarked: Bool
    @Binding var showKarmaAnimation: Bool
    @Binding var interestedCount: Int
    let onInterestAction: () async -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Primary Action Button
            Button(action: {
                Task {
                    await onInterestAction()
                }
            }) {
                HStack {
                    Image(systemName: isInterested ? "message.fill" : "hand.raised.fill")
                    Text(isInterested ? "Chat Started" : "I'm Interested")
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isInterested ? 
                            [DesignSystem.Colors.primaryGreen, DesignSystem.Colors.primaryGreen.opacity(0.8)] :
                            [DesignSystem.Colors.primaryGreen, DesignSystem.Colors.primaryBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .scaleEffect(isInterested ? 0.95 : 1.0)
            }
            .disabled(isInterested)
            
            // Bookmark Button
            Button(action: {
                withAnimation(.spring()) {
                    isBookmarked.toggle()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.title2)
                    .foregroundColor(isBookmarked ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.textSecondary)
                    .frame(width: 56, height: 56)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .cornerRadius(12)
                    .scaleEffect(isBookmarked ? 1.1 : 1.0)
            }
        }
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Helper Components
struct AnimatedTaskBadge: View {
    let rewardType: RewardType
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: rewardType.icon)
                .font(.system(size: 14, weight: .semibold))
            
            Text(value)
                .font(DesignSystem.Typography.bodySemibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [rewardType.primaryColor, rewardType.primaryColor.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .shadow(color: rewardType.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct LocationSection: View {
    let locationName: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Location")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(locationName)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "map.fill")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
            }
            .padding()
            .background(DesignSystem.Colors.primaryGreen.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct ExpirationTimer: View {
    let timeRemaining: String
    @State private var isUrgent = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundColor(isUrgent ? .red : DesignSystem.Colors.primaryOrange)
            
            Text("Expires in")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text(timeRemaining)
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(isUrgent ? .red : DesignSystem.Colors.primaryOrange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background((isUrgent ? Color.red : DesignSystem.Colors.primaryOrange).opacity(0.1))
        .cornerRadius(20)
        .onAppear {
            isUrgent = timeRemaining.contains("h") && !timeRemaining.contains("d")
        }
    }
}

struct DifficultyBadge: View {
    let karma: Int
    
    private var difficulty: (text: String, color: Color) {
        switch karma {
        case 0...20:
            return ("Easy", .green)
        case 21...50:
            return ("Medium", .orange)
        case 51...100:
            return ("Hard", .red)
        default:
            return ("Expert", .purple)
        }
    }
    
    var body: some View {
        Text(difficulty.text)
            .font(DesignSystem.Typography.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(difficulty.color)
            .cornerRadius(12)
    }
}

struct SkillTag: View {
    let text: String
    
    var body: some View {
        Text("#\(text)")
            .font(DesignSystem.Typography.caption)
            .foregroundColor(DesignSystem.Colors.primaryBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(DesignSystem.Colors.primaryBlue.opacity(0.1))
            .cornerRadius(15)
    }
}

struct BadgeChip: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: badge.icon)
                .font(.system(size: 20))
                .foregroundColor(badge.color)
            
            Text(badge.title)
                .font(.system(size: 10))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 60, height: 60)
        .background(badge.color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

// MARK: - Karma Animation
struct KarmaAnimation: View {
    @Binding var show: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if show {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                        
                        Text("+5")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryGreen)
                        
                        Text("karma")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primaryGreen)
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(y: offset)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .onChange(of: show) { newValue in
            if newValue {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.2
                    opacity = 1
                }
                
                withAnimation(.easeOut(duration: 1).delay(0.5)) {
                    offset = -100
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    show = false
                    scale = 0.5
                    offset = 0
                }
            }
        }
    }
}

// MARK: - Helper Functions
private func getKarmaIcon(for post: Post) -> String {
    switch post.rewardType {
    case .karma:
        return "star.fill"
    case .cash:
        return "dollarsign.circle.fill"
    case .fun:
        return "heart.fill"
    }
}

private func getKarmaColor(for post: Post) -> Color {
    switch post.rewardType {
    case .karma:
        return DesignSystem.Colors.primaryBlue
    case .cash:
        return DesignSystem.Colors.primaryOrange
    case .fun:
        return DesignSystem.Colors.primaryPurple
    }
}
