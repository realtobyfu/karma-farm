import Foundation

// MARK: - Transaction Type
enum TransactionType: String, Codable, CaseIterable {
    case reward = "reward"
    case postCreation = "post_creation"
    case postCompletion = "post_completion"
    case transfer = "transfer"
    case systemBonus = "system_bonus"
    case referral = "referral"
    
    var displayName: String {
        switch self {
        case .reward:
            return "Reward"
        case .postCreation:
            return "Post Creation"
        case .postCompletion:
            return "Task Completion"
        case .transfer:
            return "Transfer"
        case .systemBonus:
            return "System Bonus"
        case .referral:
            return "Referral Bonus"
        }
    }
    
    var icon: String {
        switch self {
        case .reward:
            return "gift.fill"
        case .postCreation:
            return "square.and.pencil"
        case .postCompletion:
            return "checkmark.circle.fill"
        case .transfer:
            return "arrow.left.arrow.right"
        case .systemBonus:
            return "star.fill"
        case .referral:
            return "person.2.fill"
        }
    }
}

// MARK: - Karma Transaction
struct KarmaTransaction: Codable, Identifiable {
    let id: String
    let fromUserId: String?
    let toUserId: String?
    let amount: Int
    let type: TransactionType
    let description: String?
    let relatedPostId: String?
    let createdAt: Date
    
    // Related entities (populated by backend)
    let fromUser: User?
    let toUser: User?
    let relatedPost: Post?
    
    // Computed properties
    var isIncoming: Bool {
        // Transaction is incoming if current user is the recipient
        guard let currentUserId = AuthManager.shared.currentUser?.id else { return false }
        return toUserId == currentUserId
    }
    
    var displayAmount: String {
        let sign = isIncoming ? "+" : "-"
        return "\(sign)\(amount)"
    }
    
    var displayDescription: String {
        if let desc = description {
            return desc
        }
        
        switch type {
        case .reward:
            return "Karma reward"
        case .postCreation:
            return "Created a post"
        case .postCompletion:
            if let postTitle = relatedPost?.title {
                return "Completed: \(postTitle)"
            }
            return "Completed a task"
        case .transfer:
            if isIncoming {
                return "Received from \(fromUser?.name ?? "someone")"
            } else {
                return "Sent to \(toUser?.name ?? "someone")"
            }
        case .systemBonus:
            return "System bonus"
        case .referral:
            return "Referral bonus"
        }
    }
}

// MARK: - Transaction History Response
struct KarmaTransactionResponse: Codable {
    let transactions: [KarmaTransaction]
    let total: Int
}