import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @State private var selectedChat: Chat?
    @State private var showChatDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.chats.isEmpty {
                    ProgressView("Loading chats...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.chats.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.chats) { chat in
                                ChatRowView(chat: chat)
                                    .onTapGesture {
                                        selectedChat = chat
                                        showChatDetail = true
                                    }
                                
                                if chat.id != viewModel.chats.last?.id {
                                    Divider()
                                        .padding(.leading, 76)
                                }
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.unreadCount > 0 {
                        Text("\(viewModel.unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.primaryOrange)
                            .cornerRadius(10)
                    }
                }
            }
            .refreshable {
                await viewModel.loadChats()
            }
        }
        .sheet(item: $selectedChat) { chat in
            ChatDetailView(chat: chat)
        }
        .onAppear {
            Task {
                await viewModel.loadChats()
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    @State private var isOnline = false
    @State private var lastSeen: Date?
    
    private var formattedTime: String {
        let date = chat.lastMessageAt ?? chat.createdAt
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(DesignSystem.Colors.primaryGreen.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(chat.otherUser?.username.prefix(1).uppercased() ?? "?")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primaryGreen)
                    )
                
                // Online indicator
                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(DesignSystem.Colors.backgroundPrimary, lineWidth: 2)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Name and time
                HStack {
                    Text(chat.otherUser?.username ?? "Unknown User")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(formattedTime)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                // Post title
                if let postTitle = chat.post?.title {
                    Text(postTitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.primaryGreen)
                        .lineLimit(1)
                }
                
                // Last message
                Text(chat.lastMessage ?? "Start a conversation")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(chat.lastMessage != nil ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textTertiary)
                    .lineLimit(2)
            }
            
            // Unread indicator (placeholder for now)
            if chat.lastMessage != nil && Bool.random() {
                Circle()
                    .fill(DesignSystem.Colors.primaryOrange)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.backgroundPrimary)
        .onAppear {
            if let userId = chat.otherUser?.id {
                observePresence(userId: userId)
            }
        }
    }
    
    private func observePresence(userId: String) {
        _ = ChatService.shared.observeUserPresence(userId: userId) { online, lastSeenDate in
            isOnline = online
            lastSeen = lastSeenDate
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text("No messages yet")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("When you connect with someone about a post, your conversation will appear here")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ChatListView()
}