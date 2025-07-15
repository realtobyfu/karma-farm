import Foundation
import Combine
import FirebaseDatabase

class ChatService: ObservableObject {
    static let shared = ChatService()
    private let apiService = APIService.shared
    private var database: DatabaseReference!
    
    @Published var unreadCount: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupFirebaseDatabase()
        startUnreadCountMonitoring()
    }
    
    private func setupFirebaseDatabase() {
        database = Database.database().reference()
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
        Task {
            do {
                let _: EmptyResponse = try await apiService.request(
                    endpoint: "/chats/\(chatId)/typing",
                    method: .put,
                    body: ["isTyping": isTyping],
                    responseType: EmptyResponse.self
                )
            } catch {
                print("Failed to update typing status: \(error)")
            }
        }
    }
    
    func observeTypingStatus(chatId: String, completion: @escaping ([String: Bool]) -> Void) -> DatabaseHandle {
        let typingRef = database.child("typing").child(chatId)
        
        return typingRef.observe(.value) { snapshot in
            var typingUsers: [String: Bool] = [:]
            
            if let value = snapshot.value as? [String: Any] {
                for (userId, data) in value {
                    if let typingData = data as? [String: Any],
                       let isTyping = typingData["isTyping"] as? Bool {
                        typingUsers[userId] = isTyping
                    }
                }
            }
            
            completion(typingUsers)
        }
    }
    
    func removeTypingObserver(chatId: String, handle: DatabaseHandle) {
        database.child("typing").child(chatId).removeObserver(withHandle: handle)
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
    
    // MARK: - Presence
    
    func updateUserPresence(isOnline: Bool) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        
        let presenceRef = database.child("presence").child(userId)
        
        if isOnline {
            presenceRef.setValue([
                "online": true,
                "lastSeen": ServerValue.timestamp()
            ])
            
            // Set up disconnect handler
            presenceRef.onDisconnectSetValue([
                "online": false,
                "lastSeen": ServerValue.timestamp()
            ])
        } else {
            presenceRef.setValue([
                "online": false,
                "lastSeen": ServerValue.timestamp()
            ])
        }
    }
    
    func observeUserPresence(userId: String, completion: @escaping (Bool, Date?) -> Void) -> DatabaseHandle {
        let presenceRef = database.child("presence").child(userId)
        
        return presenceRef.observe(.value) { snapshot in
            if let value = snapshot.value as? [String: Any],
               let online = value["online"] as? Bool {
                let lastSeen: Date? = {
                    if let timestamp = value["lastSeen"] as? TimeInterval {
                        return Date(timeIntervalSince1970: timestamp / 1000)
                    }
                    return nil
                }()
                completion(online, lastSeen)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func removePresenceObserver(userId: String, handle: DatabaseHandle) {
        database.child("presence").child(userId).removeObserver(withHandle: handle)
    }
}