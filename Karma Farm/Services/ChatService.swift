import Foundation
import Combine

@MainActor
class ChatService: ObservableObject {
    static let shared = ChatService()
    private let apiService = APIService.shared
    private let socketService = SocketService.shared

    @Published var unreadCount: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private var typingHandlers: [String: (String, Bool) -> Void] = [:]

    private init() {
        setupSocketHandlers()
        startUnreadCountMonitoring()

        // Connect socket when user is authenticated
        Task {
            if let userId = AuthManager.shared.currentUser?.id {
                socketService.connect(userId: userId)
            }
        }
    }
    
    private func setupSocketHandlers() {
        // Listen for authentication changes
        NotificationCenter.default.publisher(for: .userDidLogin)
            .sink { [weak self] _ in
                Task { @MainActor in
                    if let userId = AuthManager.shared.currentUser?.id {
                        self?.socketService.connect(userId: userId)
                    }
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userDidLogout)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.socketService.disconnect()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Chat Management
    
    func createChat(postId: String) async throws -> Chat {
        let request = CreateChatRequest(postId: postId)
        return try await apiService.request(
            endpoint: "/chats",
            method: .post,
            body: request,
            responseType: Chat.self
        )
    }
    
    func getUserChats() async throws -> [Chat] {
        return try await apiService.request(
            endpoint: "/chats",
            method: .get,
            responseType: [Chat].self
        )
    }
    
    func getChatById(_ chatId: String) async throws -> Chat {
        return try await apiService.request(
            endpoint: "/chats/\(chatId)",
            method: .get,
            responseType: Chat.self
        )
    }
    
    // MARK: - Message Management
    
    func getChatMessages(chatId: String, limit: Int = 50, offset: Int = 0) async throws -> [Message] {
        return try await apiService.request(
            endpoint: "/chats/\(chatId)/messages?limit=\(limit)&offset=\(offset)",
            method: .get,
            responseType: [Message].self
        )
    }
    
    func sendMessage(chatId: String, content: String, attachments: [MessageAttachment]? = nil) async throws -> Message {
        guard let userId = AuthManager.shared.currentUser?.id else {
            throw NSError(domain: "ChatService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        // Send via socket for real-time delivery
        if await socketService.isSocketConnected {
            socketService.sendMessage(chatId: chatId, userId: userId, content: content)
        }

        // Send via API for persistence
        let request = CreateMessageRequest(
            chatId: chatId,
            content: content,
            attachments: attachments
        )

        return try await apiService.request(
            endpoint: "/chats/messages",
            method: .post,
            body: request,
            responseType: Message.self
        )
    }
    
    // MARK: - Typing Indicators
    
    func updateTypingStatus(chatId: String, isTyping: Bool) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }

        // Send via socket for real-time updates
        socketService.updateTypingStatus(chatId: chatId, userId: userId, isTyping: isTyping)
    }
    
    func observeTypingStatus(chatId: String, completion: @escaping ([String: Bool]) -> Void) -> String {
        let handlerId = UUID().uuidString
        var typingUsers: [String: Bool] = [:]

        // Store the handler
        typingHandlers[handlerId] = { userId, isTyping in
            typingUsers[userId] = isTyping
            // Remove users who stopped typing
            if !isTyping {
                typingUsers.removeValue(forKey: userId)
            }
            completion(typingUsers)
        }

        // Register socket handler
        socketService.onTypingUpdate { [weak self] (receivedChatId: String, userId: String, isTyping: Bool) in
            if receivedChatId == chatId,
               let handler = self?.typingHandlers[handlerId] {
                Task { @MainActor in
                    handler(userId, isTyping)
                }
            }
        }

        return handlerId
    }
    
    func removeTypingObserver(chatId: String, handlerId: String) {
        typingHandlers.removeValue(forKey: handlerId)
    }
    
    // MARK: - Unread Count

    private func startUnreadCountMonitoring() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task { @MainActor in
                    await self.fetchUnreadCount()
                }
            }
            .store(in: &cancellables)

        // Initial fetch
        Task { @MainActor in
            await fetchUnreadCount()
        }
    }

    private func fetchUnreadCount() async {
        do {
            let response: UnreadCountResponse = try await apiService.request(
                endpoint: "/chats/unread-count",
                method: .get,
                responseType: UnreadCountResponse.self
            )
            self.unreadCount = response.count
        } catch {
            print("Failed to fetch unread count: \(error)")
        }
    }
    
    // MARK: - Real-time Message Handling

    func joinChat(chatId: String) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        socketService.joinChat(chatId: chatId, userId: userId)
    }

    func leaveChat(chatId: String) {
        socketService.leaveChat(chatId: chatId)
    }

    func markMessageAsRead(chatId: String, messageId: String) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        socketService.markMessageAsRead(chatId: chatId, userId: userId, messageId: messageId)
    }

    func observeNewMessages(for chatId: String, completion: @escaping (Message) -> Void) {
        socketService.onNewMessage { receivedChatId, message in
            if receivedChatId == chatId {
                Task { @MainActor in
                    completion(message)
                }
            }
        }
    }

    func observeReadReceipts(for chatId: String, completion: @escaping (String, String) -> Void) {
        socketService.onReadUpdate { receivedChatId, userId, messageId in
            if receivedChatId == chatId {
                Task { @MainActor in
                    completion(userId, messageId)
                }
            }
        }
    }

    // MARK: - Concurrent Operations

    /// Load chat details with concurrent fetching of chat data and recent messages
    func loadChatWithMessages(chatId: String) async throws -> (chat: Chat, messages: [Message]) {
        return try await withThrowingTaskGroup(of: Any.self) { group in
            var chat: Chat?
            var messages: [Message] = []

            // Add task to fetch chat details
            group.addTask {
                try await self.getChatById(chatId)
            }

            // Add task to fetch chat messages
            group.addTask {
                try await self.getChatMessages(chatId: chatId, limit: 50, offset: 0)
            }

            // Collect results
            for try await result in group {
                if let chatResult = result as? Chat {
                    chat = chatResult
                } else if let messagesResult = result as? [Message] {
                    messages = messagesResult
                }
            }

            guard let finalChat = chat else {
                throw NSError(domain: "ChatService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load chat"])
            }

            return (chat: finalChat, messages: messages)
        }
    }

    /// Load multiple chats concurrently with their metadata
    func loadChatsWithUnreadCount() async throws -> (chats: [Chat], unreadCount: Int) {
        return try await withThrowingTaskGroup(of: Any.self) { group in
            var chats: [Chat] = []
            var unreadCount = 0

            // Add task to fetch user chats
            group.addTask {
                try await self.getUserChats()
            }

            // Add task to fetch unread count
            group.addTask {
                let response: UnreadCountResponse = try await self.apiService.request(
                    endpoint: "/chats/unread-count",
                    method: .get,
                    responseType: UnreadCountResponse.self
                )
                return response.count
            }

            // Collect results
            for try await result in group {
                if let chatsResult = result as? [Chat] {
                    chats = chatsResult
                } else if let countResult = result as? Int {
                    unreadCount = countResult
                }
            }

            return (chats: chats, unreadCount: unreadCount)
        }
    }
}