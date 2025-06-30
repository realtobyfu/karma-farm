import Foundation
import CoreLocation
import FirebaseAuth

enum PostType: String, Codable, CaseIterable {
    case general = "general"
    case skillShare = "skill_share"
    case task = "task"
    case interest = "interest"
    case transportation = "transportation"
    case food = "food"
    case technology = "technology"
    case education = "education"
    case events = "events"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .skillShare: return "Skill Share"
        case .task: return "Task"
        case .interest: return "Interest"
        case .transportation: return "Transportation"
        case .food: return "Food"
        case .technology: return "Technology"
        case .education: return "Education"
        case .events: return "Events"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "star.fill"
        case .skillShare: return "lightbulb.fill"
        case .task: return "checkmark.circle.fill"
        case .interest: return "heart.fill"
        case .transportation: return "car.fill"
        case .food: return "fork.knife"
        case .technology: return "laptopcomputer"
        case .education: return "book.fill"
        case .events: return "calendar"
        }
    }
}

enum PostStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let user: User?
    let type: PostType
    let taskType: TaskType
    let title: String
    let description: String
    let karmaValue: Int
    let paymentAmount: Double? // For cash tasks
    let isRequest: Bool
    let location: Location?
    let locationName: String?
    let status: PostStatus
    let createdAt: Date
    let expiresAt: Date?
    let completedByUserId: String?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let location = location else { return nil }
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var timeRemaining: String? {
        guard let expiresAt = expiresAt, !isExpired else { return nil }
        let timeInterval = expiresAt.timeIntervalSince(Date())
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "< 1h"
        }
    }
    
    var isCurrentUserPost: Bool {
        // Check if this post belongs to the current user
        guard let currentUserId = AuthManager.shared.currentUser?.id else { return false }
        return userId == currentUserId
    }
    
    var displayValue: String {
        switch taskType {
        case .karma:
            return "\(karmaValue) karma"
        case .cash:
            if let amount = paymentAmount {
                return String(format: "$%.0f", amount)
            }
            return "$0"
        case .fun:
            return "Just for fun"
        }
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Mock Data
extension Post {
    static let mockPosts: [Post] = [
        Post(
            id: "post-1",
            userId: "user-1",
            user: User.mockUsers[0],
            type: .skillShare,
            taskType: .karma,
            title: "Learn to Cook Italian Pasta",
            description: "I'll teach you how to make authentic Italian pasta from scratch! We'll cover different types of pasta, sauces, and cooking techniques. Perfect for beginners.",
            karmaValue: 25,
            paymentAmount: nil,
            isRequest: false,
            location: Location(latitude: 42.3651, longitude: -71.0540),
            locationName: "North End, Boston",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            expiresAt: Date().addingTimeInterval(86400 * 5),
            completedByUserId: nil
        ),
        Post(
            id: "post-2",
            userId: "mock-user-id",
            user: User.mockUser,
            type: .task,
            taskType: .cash,
            title: "Need Help Moving Furniture",
            description: "Looking for someone to help me move a couch and some boxes to my new apartment. Should take about 2 hours. I have a truck already. Cash payment.",
            karmaValue: 0,
            paymentAmount: 50.0,
            isRequest: true,
            location: Location(latitude: 42.3601, longitude: -71.0589),
            locationName: "Back Bay, Boston",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400),
            expiresAt: Date().addingTimeInterval(86400 * 3),
            completedByUserId: nil
        ),
        Post(
            id: "post-3",
            userId: "user-2",
            user: User.mockUsers[1],
            type: .skillShare,
            taskType: .karma,
            title: "iOS Development Mentoring",
            description: "Experienced iOS developer offering mentoring sessions. I can help with Swift, SwiftUI, app architecture, and App Store submission process.",
            karmaValue: 40,
            paymentAmount: nil,
            isRequest: false,
            location: Location(latitude: 42.3581, longitude: -71.0636),
            locationName: "Cambridge, MA",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            expiresAt: Date().addingTimeInterval(86400 * 7),
            completedByUserId: nil
        ),
        Post(
            id: "post-4",
            userId: "mock-user-id",
            user: User.mockUser,
            type: .interest,
            taskType: .fun,
            title: "Looking for Guitar Practice Partner",
            description: "Intermediate guitar player looking for someone to practice with. I play folk and indie rock mostly. Would love to jam together!",
            karmaValue: 0,
            paymentAmount: nil,
            isRequest: true,
            location: Location(latitude: 42.3601, longitude: -71.0589),
            locationName: "Back Bay, Boston",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 4),
            expiresAt: Date().addingTimeInterval(86400 * 10),
            completedByUserId: nil
        ),
        Post(
            id: "post-5",
            userId: "user-1",
            user: User.mockUsers[0],
            type: .task,
            taskType: .karma,
            title: "Completed: Garden Setup Help",
            description: "Thanks to Alex for helping me set up my herb garden! Great work and very knowledgeable about plants.",
            karmaValue: 20,
            paymentAmount: nil,
            isRequest: true,
            location: Location(latitude: 42.3651, longitude: -71.0540),
            locationName: "North End, Boston",
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400 * 10),
            expiresAt: nil,
            completedByUserId: "user-2"
        )
    ]
    
    static let mockPost = mockPosts[0]
}

