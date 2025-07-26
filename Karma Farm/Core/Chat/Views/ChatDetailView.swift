import SwiftUI
import Combine

struct ChatDetailView: View {
    let chat: Chat
    @StateObject private var viewModel = ChatDetailViewModel()
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var otherUserTyping = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Messages List
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if otherUserTyping {
                                    TypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: otherUserTyping) { _ in
                            if otherUserTyping {
                                withAnimation {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Message Input
                    MessageInputView(
                        text: $messageText,
                        isTyping: $isTyping,
                        onSend: sendMessage
                    )
                    .focused($isTextFieldFocused)
                }
            }
            .navigationTitle(chat.otherUser?.username ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(chat.otherUser?.username ?? "Unknown")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        if let postTitle = chat.post?.title {
                            Text(postTitle)
                                .font(.caption2)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.setupChat(chat)
            Task {
                await viewModel.loadMessages()
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        Task {
            await viewModel.sendMessage(content: trimmedText)
            messageText = ""
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(message.isFromCurrentUser ? .white : DesignSystem.Colors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isFromCurrentUser ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.backgroundSecondary)
                    )
                
                Text(formatMessageTime(message.createdAt))
                    .font(.caption2)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            if !message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageInputView: View {
    @Binding var text: String
    @Binding var isTyping: Bool
    let onSend: () -> Void
    
    private let typingDebouncer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State private var lastTypingUpdate = Date()
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .font(DesignSystem.Typography.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(DesignSystem.Colors.backgroundSecondary)
                .cornerRadius(20)
                .lineLimit(1...4)
                .onChange(of: text) { _ in
                    updateTypingStatus(true)
                }
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.primaryGreen)
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.backgroundPrimary)
        .onReceive(typingDebouncer) { _ in
            if isTyping && Date().timeIntervalSince(lastTypingUpdate) > 2 {
                updateTypingStatus(false)
            }
        }
    }
    
    private func updateTypingStatus(_ typing: Bool) {
        isTyping = typing
        lastTypingUpdate = Date()
        
        if !typing {
            // Stop typing after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if Date().timeIntervalSince(lastTypingUpdate) >= 1 {
                    isTyping = false
                }
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(DesignSystem.Colors.textTertiary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount)
                        .opacity(0.7 + (0.3 * animationAmount))
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(DesignSystem.Colors.backgroundSecondary)
            )
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationAmount = 1.0
        }
    }
}

// MARK: - ViewModel
@MainActor
class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var chat: Chat?
    private let chatService = ChatService.shared
    private var typingObserver: String?
    private var typingTimer: Timer?
    
    func setupChat(_ chat: Chat) {
        self.chat = chat
        observeTyping()
    }
    
    func loadMessages() async {
        guard let chat = chat else { return }
        
        isLoading = true
        do {
            messages = try await chatService.getChatMessages(chatId: chat.id)
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
            print("Error loading messages: \(error)")
        }
        isLoading = false
    }
    
    func sendMessage(content: String) async {
        guard let chat = chat else { return }
        
        // Stop typing indicator
        chatService.updateTypingStatus(chatId: chat.id, isTyping: false)
        
        do {
            let message = try await chatService.sendMessage(
                chatId: chat.id,
                content: content
            )
            messages.append(message)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            print("Error sending message: \(error)")
        }
    }
    
    private func observeTyping() {
        guard let chat = chat else { return }
        
        typingObserver = chatService.observeTypingStatus(chatId: chat.id) { [weak self] typingUsers in
            guard let self = self,
                  let currentUserId = AuthManager.shared.currentUser?.id else { return }
            
            // Check if other user is typing
            let otherUserTyping = typingUsers.contains { userId, isTyping in
                userId != currentUserId && isTyping
            }
            
            // Update UI on main thread
            Task { @MainActor in
                // This would update a @Published property that the view observes
                // For now, we'll handle this in the view
            }
        }
    }
    
    func updateTypingStatus(_ isTyping: Bool) {
        guard let chat = chat else { return }
        
        typingTimer?.invalidate()
        
        if isTyping {
            chatService.updateTypingStatus(chatId: chat.id, isTyping: true)
            
            // Auto-stop typing after 3 seconds
            typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                self.chatService.updateTypingStatus(chatId: chat.id, isTyping: false)
            }
        } else {
            chatService.updateTypingStatus(chatId: chat.id, isTyping: false)
        }
    }
    
    func cleanup() {
        if let observer = typingObserver, let chat = chat {
            chatService.removeTypingObserver(chatId: chat.id, handlerId: observer)
        }
        typingTimer?.invalidate()
        
        // Mark as not typing when leaving
        if let chat = chat {
            chatService.updateTypingStatus(chatId: chat.id, isTyping: false)
        }
    }
}
#Preview {
    ChatDetailView(
        chat: Chat(
            id: "1",
            postId: "1",
            post: nil,
            requesterId: "1",
            requester: nil,
            offererId: "2",
            offerer: User(
                id: "2",
                firebaseUid: "2",
                username: "JohnDoe",
                profilePicture: nil,
                karmaBalance: 100,
                email: nil,
                phoneNumber: "+1234567890",
                isEmailVerified: false,
                isPhoneVerified: true,
                bio: nil,
                skills: [],
                interests: [],
                privateProfile: nil,
                lastLocation: nil,
                badges: [],
                createdAt: Date(),
                updatedAt: Date(),
                isDiscoverable: true,
                isPrivateProfile: false,
                privacySettings: nil
            ),
            status: "active",
            lastMessage: "Hey, I can help with that!",
            lastMessageAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
