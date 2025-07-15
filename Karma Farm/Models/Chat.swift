import Foundation

struct Chat: Codable, Identifiable {
    let id: String
    let postId: String
    let post: Post?
    let requesterId: String
    let requester: User?
    let offererId: String
    let offerer: User?
    let status: String
    let lastMessage: String?
    let lastMessageAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    var otherUser: User? {
        guard let currentUserId = AuthManager.shared.currentUser?.id else { return nil }
        if requesterId == currentUserId {
            return offerer
        } else {
            return requester
        }
    }
    
    var isActive: Bool {
        return status == "active"
    }
}

struct Message: Codable, Identifiable {
    let id: String
    let chatId: String
    let senderId: String
    let sender: User?
    let content: String
    let metadata: MessageMetadata?
    let isRead: Bool
    let readAt: Date?
    let createdAt: Date
    
    var isFromCurrentUser: Bool {
        return senderId == AuthManager.shared.currentUser?.id
    }
}

struct MessageMetadata: Codable {
    let edited: Bool?
    let editedAt: Date?
    let attachments: [MessageAttachment]?
}

struct MessageAttachment: Codable {
    let type: String
    let url: String
    let name: String
    let size: Int
}

struct CreateChatRequest: Codable {
    let postId: String
}

struct CreateMessageRequest: Codable {
    let chatId: String
    let content: String
    let attachments: [MessageAttachment]?
}

struct UnreadCountResponse: Codable {
    let count: Int
}

// MARK: - Mock Data
extension Chat {
    static let mockChats: [Chat] = [
        Chat(
            id: "chat-1",
            postId: "post-1",
            post: nil,
            requesterId: "user-1",
            requester: nil,
            offererId: "mock-user-id",
            offerer: nil,
            status: "active",
            lastMessage: "Hey! Are you still available to help with cooking today?",
            lastMessageAt: Date().addingTimeInterval(-3600 * 2),
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: Date().addingTimeInterval(-3600 * 2)
        ),
        Chat(
            id: "chat-2",
            postId: "post-2",
            post: nil,
            requesterId: "mock-user-id",
            requester: nil,
            offererId: "user-2",
            offerer: nil,
            status: "active",
            lastMessage: "Thanks for the programming help yesterday!",
            lastMessageAt: Date().addingTimeInterval(-86400),
            createdAt: Date().addingTimeInterval(-86400 * 3),
            updatedAt: Date().addingTimeInterval(-86400)
        )
    ]
}

extension Message {
    static let mockMessages: [Message] = [
        Message(
            id: "msg-1",
            chatId: "chat-1",
            senderId: "user-1",
            sender: nil,
            content: "Hey! Are you still available to help with cooking today?",
            metadata: nil,
            isRead: false,
            readAt: nil,
            createdAt: Date().addingTimeInterval(-3600 * 2)
        ),
        Message(
            id: "msg-2",
            chatId: "chat-2",
            senderId: "mock-user-id",
            sender: nil,
            content: "Thanks for the programming help yesterday!",
            metadata: nil,
            isRead: true,
            readAt: Date().addingTimeInterval(-86400),
            createdAt: Date().addingTimeInterval(-86400)
        )
    ]
}