import Foundation
import Combine

class ChatService: ObservableObject {
    static let shared = ChatService()
    private let apiService = APIService.shared
    // TODO: Uncomment when SocketService is implemented
    // private let socketService = SocketService.shared
    
    @Published var unreadCount: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private var typingHandlers: [String: (String, Bool) -> Void] = [:]
    
    private init() {
        // TODO: Uncomment when SocketService is implemented
        // setupSocketHandlers()
        startUnreadCountMonitoring()
        
        // Connect socket when user is authenticated
        // if let userId = AuthManager.shared.currentUser?.id {
        //     socketService.connect(userId: userId)
        // }
    }
    
    private func setupSocketHandlers() {
        // TODO: Implement when SocketService is available
        /*
        // Listen for authentication changes
        NotificationCenter.default.publisher(for: .userDidLogin)
            .sink { [weak self] _ in
                if let userId = AuthManager.shared.currentUser?.id {
                    self?.socketService.connect(userId: userId)
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .userDidLogout)
            .sink { [weak self] _ in
                self?.socketService.disconnect()
            }
            .store(in: &cancellables)
        */
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
        
        // TODO: Send via socket for real-time delivery when SocketService is implemented
        // if socketService.isSocketConnected() {
        //     socketService.sendMessage(chatId: chatId, userId: userId, content: content)
        // }
        
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
        
        // TODO: Send via socket for real-time updates when SocketService is implemented
        // socketService.updateTypingStatus(chatId: chatId, userId: userId, isTyping: isTyping)
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
        
        // TODO: Register socket handler when SocketService is implemented
        /*
        socketService.onTypingUpdate { [weak self] (receivedChatId: String, userId: String, isTyping: Bool) in
            if receivedChatId == chatId,
               let handler = self?.typingHandlers[handlerId] {
                handler(userId, isTyping)
            }
        }
        */
        
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
                Task {
                    await self.fetchUnreadCount()
                }
            }
            .store(in: &cancellables)
        
        // Initial fetch
        Task {
            await fetchUnreadCount()
        }
    }
    
    @MainActor
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
        // TODO: Implement when SocketService is available
        // socketService.joinChat(chatId: chatId, userId: userId)
    }
    
    func leaveChat(chatId: String) {
        // TODO: Implement when SocketService is available
        // socketService.leaveChat(chatId: chatId)
    }
    
    func markMessageAsRead(chatId: String, messageId: String) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        // TODO: Implement when SocketService is available
        // socketService.markMessageAsRead(chatId: chatId, userId: userId, messageId: messageId)
    }
    
    func observeNewMessages(for chatId: String, completion: @escaping (Message) -> Void) {
        // TODO: Implement when SocketService is available
        /*
        socketService.onNewMessage { receivedChatId, message in
            if receivedChatId == chatId {
                completion(message)
            }
        }
        */
    }
    
    func observeReadReceipts(for chatId: String, completion: @escaping (String, String) -> Void) {
        // TODO: Implement when SocketService is available
        /*
        socketService.onReadUpdate { receivedChatId, userId, messageId in
            if receivedChatId == chatId {
                completion(userId, messageId)
            }
        }
        */
    }
}