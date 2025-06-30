import Foundation

// MARK: - Task Completion Models
struct TaskCompletion: Codable {
    let id: String
    let postId: String
    let completedByUserId: String
    let confirmedByUserId: String
    let status: CompletionStatus
    let rating: TaskRating?
    let notes: String?
    let completedAt: Date
    let confirmedAt: Date?
}

enum CompletionStatus: String, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case awaitingConfirmation = "awaiting_confirmation"
    case confirmed = "confirmed"
    case disputed = "disputed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .awaitingConfirmation: return "Awaiting Confirmation"
        case .confirmed: return "Confirmed"
        case .disputed: return "Disputed"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .awaitingConfirmation: return "hourglass"
        case .confirmed: return "checkmark.circle.fill"
        case .disputed: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Task Rating
struct TaskRating: Codable {
    let id: String
    let rating: Int // 1-5 stars
    let review: String?
    let helpfulnessTags: [HelpfulnessTag]
    let createdAt: Date
}

enum HelpfulnessTag: String, Codable, CaseIterable {
    case onTime = "on_time"
    case friendly = "friendly"
    case skilled = "skilled"
    case communicative = "communicative"
    case reliable = "reliable"
    case efficient = "efficient"
    
    var displayName: String {
        switch self {
        case .onTime: return "On Time"
        case .friendly: return "Friendly"
        case .skilled: return "Skilled"
        case .communicative: return "Communicative"
        case .reliable: return "Reliable"
        case .efficient: return "Efficient"
        }
    }
    
    var icon: String {
        switch self {
        case .onTime: return "clock.badge.checkmark"
        case .friendly: return "face.smiling"
        case .skilled: return "star.circle.fill"
        case .communicative: return "bubble.left.and.bubble.right.fill"
        case .reliable: return "shield.checkered"
        case .efficient: return "bolt.fill"
        }
    }
}

// MARK: - Task Acceptance
struct TaskAcceptance: Codable {
    let postId: String
    let acceptedByUserId: String
    let proposedCompletionDate: Date?
    let message: String?
    let acceptedAt: Date
}