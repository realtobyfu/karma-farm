import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var showFilters = false
    @FocusState private var isSearchFocused: Bool
    
    private func formatTimeAgo(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBarView(
                        text: $searchText,
                        onSearch: performSearch,
                        showFilters: $showFilters
                    )
                    .focused($isSearchFocused)
                    
                    // Recent Searches / Results
                    if searchText.isEmpty && !viewModel.isSearching {
                        RecentSearchesView(
                            searches: viewModel.recentSearches,
                            onSelect: { search in
                                searchText = search
                                performSearch()
                            }
                        )
                    } else if viewModel.isSearching {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.searchResults.isEmpty {
                        SearchResultsView(results: viewModel.searchResults)
                    } else if viewModel.hasSearched {
                        EmptySearchResultsView(query: searchText)
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilters) {
                SearchFiltersView(filters: $viewModel.filters) {
                    performSearch()
                }
            }
        }
    }
    
    private func performSearch() {
        isSearchFocused = false
        Task {
            await viewModel.search(query: searchText)
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    let onSearch: () -> Void
    @Binding var showFilters: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                TextField("Search posts, skills, or people...", text: $text)
                    .font(DesignSystem.Typography.body)
                    .onSubmit {
                        onSearch()
                    }
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(10)
            
            Button(action: { showFilters = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

struct RecentSearchesView: View {
    let searches: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Recent Searches")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                
                ForEach(searches, id: \.self) { search in
                    Button(action: { onSelect(search) }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text(search)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.backward")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }
                }
                
                // Suggested Tags
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Popular Tags")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(["Tutoring", "Moving Help", "Tech Support", "Language Exchange", "Gardening"], id: \.self) { tag in
                                TagChip(text: tag) {
                                    onSelect(tag)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
    }
}

struct SearchResultsView: View {
    let results: [Post]
    @State private var selectedPost: Post?
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(results, id: \.id) { post in
                    Button(action: {
                        selectedPost = post
                    }) {
                        createTaskCard(for: post)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .sheet(item: $selectedPost) { post in
            GamifiedPostDetailView(post: post)
        }
    }
    
    @ViewBuilder
    private func createTaskCard(for post: Post) -> some View {
        let rewardType = getRewardType(for: post.type)
        let value = post.displayValue
        let location = post.locationName ?? "Unknown"
        let timeAgo = formatTimeAgo(post.createdAt)
        let userName = post.user?.username ?? "Anonymous"
        let userAvatar = post.user?.profilePicture
        let isPrivate = post.user?.isPrivateProfile ?? false
        
        ModernTaskCard(
            rewardType: rewardType,
            title: post.title,
            description: post.description,
            value: value,
            location: location,
            timeAgo: timeAgo,
            userName: userName,
            userAvatar: userAvatar,
            isPrivateProfile: isPrivate
        ) {
            selectedPost = post
        }
    }
    
    private func getRewardType(for postType: PostType) -> RewardType {
        switch postType {
        case .skillShare:
            return .karma
        case .task:
            return .cash
        case .social:
            return .fun
        default:
            return .fun
        }
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptySearchResultsView: View {
    let query: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("No results for \"\(query)\"")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("Try adjusting your search or filters")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TagChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.primaryGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DesignSystem.Colors.primaryGreen.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

#Preview {
    SearchView()
}