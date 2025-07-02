import SwiftUI

struct GamifiedPostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    @State private var isInterested = false
    @State private var isBookmarked = false
    @State private var showKarmaAnimation = false
    @State private var interestedCount = Int.random(in: 0...15)
    @State private var viewCount = Int.random(in: 10...100)
    @State private var upvotes = Int.random(in: 0...25)
    @State private var hasUpvoted = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        // Enhanced Header with Stats
                        PostHeaderSection(post: post)
                        
                        // Gamified User Profile Section
                        if let user = post.user {
                            GamifiedUserCard(
                                user: user,
                                isAnonymous: post.isAnonymous ?? false,
                                anonymousName: post.anonymousDisplayName
                            )
                        }
                        
                        // Social Proof Indicators
                        SocialProofBar(
                            viewCount: viewCount,
                            interestedCount: interestedCount,
                            upvotes: upvotes,
                            hasUpvoted: $hasUpvoted
                        )
                        
                        // Description with enhanced typography
                        PostDescriptionSection(description: post.description)
                        
                        // Gamified Details Section
                        PostDetailsCard(post: post)
                        
                        // Interactive Action Buttons
                        ActionButtonsSection(
                            post: post,
                            isInterested: $isInterested,
                            isBookmarked: $isBookmarked,
                            showKarmaAnimation: $showKarmaAnimation,
                            interestedCount: $interestedCount
                        )
                        
                        Spacer(minLength: 20)
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Quest Details")
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
        .overlay(
            KarmaAnimationOverlay(show: $showKarmaAnimation, karmaValue: post.karmaValue)
        )
    }
}

// MARK: - Header Section
struct PostHeaderSection: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: post.isRequest ? "questionmark.circle.fill" : "gift.fill")
                            .font(.caption)
                        Text(post.isRequest ? "Request" : "Offer")
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                AnimatedTaskBadge(taskType: post.taskType, value: post.displayValue)
            }
            
            // Location and Time Pills
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let locationName = post.locationName {
                    InfoPill(icon: "location.fill", text: locationName, color: .blue)
                }
                
                InfoPill(
                    icon: "clock.fill",
                    text: post.timeRemaining ?? "Just now",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - Gamified User Card
struct GamifiedUserCard: View {
    let user: User
    let isAnonymous: Bool
    let anonymousName: String?
    @State private var showProfileSheet = false
    
    private var displayName: String {
        isAnonymous ? (anonymousName ?? "Anonymous Hero") : user.username
    }
    
    private var karmaLevel: (level: Int, progress: Double, title: String) {
        let karma = user.karmaBalance
        switch karma {
        case 0..<100:
            return (1, Double(karma) / 100.0, "Novice Helper")
        case 100..<500:
            return (2, Double(karma - 100) / 400.0, "Rising Star")
        case 500..<1000:
            return (3, Double(karma - 500) / 500.0, "Community Hero")
        case 1000..<2500:
            return (4, Double(karma - 1000) / 1500.0, "Karma Master")
        default:
            return (5, 1.0, "Legendary Giver")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Enhanced Avatar
                ZStack {
                    Circle()
                        .fill(isAnonymous ? Color.gray : DesignSystem.Colors.primaryGreen.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    if isAnonymous {
                        Image(systemName: "person.fill.questionmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    } else {
                        Text(user.username.prefix(1).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryGreen)
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
                    
                    // Karma Display with Progress
                    if !isAnonymous {
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text("\(user.karmaBalance)")
                                    .font(DesignSystem.Typography.bodySemibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 4)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(DesignSystem.Colors.primaryGreen)
                                        .frame(width: geometry.size.width * karmaLevel.progress, height: 4)
                                }
                            }
                            .frame(width: 60, height: 4)
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
            
            // Achievement Badges
            if !isAnonymous && !user.badges.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(user.badges.prefix(5), id: \.id) { badge in
                            BadgeChip(badge: badge.type)
                        }
                        
                        if user.badges.count > 5 {
                            Text("+\(user.badges.count - 5)")
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
    @Binding var hasUpvoted: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Views
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.caption)
                Text("\(viewCount)")
                    .font(DesignSystem.Typography.caption)
            }
            .foregroundColor(DesignSystem.Colors.textSecondary)
            
            // Interested
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                Text("\(interestedCount) interested")
                    .font(DesignSystem.Typography.caption)
            }
            .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Spacer()
            
            // Upvote Button
            Button(action: {
                withAnimation(.spring()) {
                    hasUpvoted.toggle()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: hasUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.caption)
                    Text("\(upvotes + (hasUpvoted ? 1 : 0))")
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(hasUpvoted ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(hasUpvoted ? DesignSystem.Colors.primaryGreen.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(16)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Description Section
struct PostDescriptionSection: View {
    let description: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Quest Details")
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
                        Image(systemName: post.isRequest ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .foregroundColor(post.isRequest ? .red : .green)
                        Text("\(post.isRequest ? "-" : "+")\(post.karmaValue)")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                Spacer()
                
                // Difficulty Badge
                DifficultyBadge(karma: post.karmaValue)
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
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Primary Action Button
            Button(action: {
                withAnimation(.spring()) {
                    isInterested = true
                    interestedCount += 1
                    showKarmaAnimation = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }) {
                HStack {
                    Image(systemName: isInterested ? "checkmark.circle.fill" : "hand.raised.fill")
                    Text(isInterested ? "Interested!" : "I'm Interested")
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
    let taskType: TaskType
    let value: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: taskType.icon)
                .font(.system(size: 14, weight: .semibold))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(taskType.gradient)
        .cornerRadius(20)
        .shadow(color: taskType.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(DesignSystem.Typography.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
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
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct BadgeChip: View {
    let badge: String
    
    private var badgeInfo: (icon: String, color: Color) {
        switch badge.lowercased() {
        case "verified": return ("checkmark.seal.fill", .blue)
        case "college": return ("graduationcap.fill", .purple)
        case "professional": return ("briefcase.fill", .orange)
        case "trusted": return ("shield.fill", .green)
        default: return ("star.fill", .yellow)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: badgeInfo.icon)
                .font(.system(size: 10))
            Text(badge)
                .font(.system(size: 11))
        }
        .foregroundColor(badgeInfo.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeInfo.color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DifficultyBadge: View {
    let karma: Int
    
    private var difficulty: (text: String, color: Color) {
        switch karma {
        case 0..<10: return ("Easy", .green)
        case 10..<25: return ("Medium", .orange)
        case 25..<50: return ("Hard", .red)
        default: return ("Epic", .purple)
        }
    }
    
    var body: some View {
        Text(difficulty.text)
            .font(DesignSystem.Typography.caption)
            .foregroundColor(difficulty.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(difficulty.color.opacity(0.1))
            .cornerRadius(8)
    }
}

struct SkillTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.caption)
            .foregroundColor(DesignSystem.Colors.primaryGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(DesignSystem.Colors.primaryGreen.opacity(0.1))
            .cornerRadius(16)
    }
}

// MARK: - Karma Animation Overlay
struct KarmaAnimationOverlay: View {
    @Binding var show: Bool
    let karmaValue: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        if show {
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    
                    Text("+\(karmaValue)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryGreen)
                    
                    Text("Karma")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .offset(y: offset)
                
                Spacer()
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.2
                    opacity = 1
                }
                
                withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
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