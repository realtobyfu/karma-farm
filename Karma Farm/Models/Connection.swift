import Foundation

// MARK: - Connection Status
enum ConnectionStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case blocked = "blocked"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .accepted:
            return "Connected"
        case .declined:
            return "Declined"
        case .blocked:
            return "Blocked"
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .accepted:
            return "checkmark.circle.fill"
        case .declined:
            return "xmark.circle.fill"
        case .blocked:
            return "nosign"
        }
    }
}

// MARK: - Connection Model
struct Connection: Codable, Identifiable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let status: ConnectionStatus
    let message: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Related entities
    let fromUser: User?
    let toUser: User?
    
    // Computed properties
    var otherUser: User? {
        guard let currentUserId = AuthManager.shared.currentUser?.id else { return nil }
        
        if fromUserId == currentUserId {
            return toUser
        } else if toUserId == currentUserId {
            return fromUser
        }
        return nil
    }
    
    var isIncoming: Bool {
        guard let currentUserId = AuthManager.shared.currentUser?.id else { return false }
        return toUserId == currentUserId
    }
    
    var displayStatus: String {
        if status == .pending {
            return isIncoming ? "Wants to connect" : "Request sent"
        }
        return status.displayName
    }
}

// MARK: - Connection Request
struct ConnectionRequest: Codable {
    let toUserId: String
    let message: String?
}

// MARK: - Connection Check Response
struct ConnectionCheckResponse: Codable {
    let isConnected: Bool
}