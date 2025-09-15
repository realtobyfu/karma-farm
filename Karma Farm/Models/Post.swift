import Foundation
import CoreLocation
import FirebaseAuth
import SwiftUI

enum PostType: String, Codable, CaseIterable {
    case skillShare = "skill_share"
    case task = "task"
    case social = "social" // Social activities, no reward
    
    var displayName: String {
        switch self {
        case .skillShare: return "Skill Share"
        case .task: return "Task"
        case .social: return "Social Activity"
        }
    }
    
    var icon: String {
        switch self {
        case .skillShare: return "lightbulb.fill"
        case .task: return "checkmark.circle.fill"
        case .social: return "heart.fill"
        }
    }
}

enum PostCategory: String, Codable, CaseIterable {
    // Skill Share Categories
    case education = "education"
    case technology = "technology"
    case creative = "creative"
    case language = "language"
    
    // Task Categories
    case transportation = "transportation"
    case shopping = "shopping"
    case homeServices = "home_services"
    case petCare = "pet_care"
    
    // Social Categories
    case sports = "sports"
    case food = "food"
    case events = "events"
    case hobbies = "hobbies"
    
    // General
    case other = "other"
    
    var displayName: String {
        switch self {
        case .education: return "Education"
        case .technology: return "Technology"
        case .creative: return "Creative"
        case .language: return "Language"
        case .transportation: return "Transportation"
        case .shopping: return "Shopping"
        case .homeServices: return "Home Services"
        case .petCare: return "Pet Care"
        case .sports: return "Sports"
        case .food: return "Food"
        case .events: return "Events"
        case .hobbies: return "Hobbies"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .education: return "book.fill"
        case .technology: return "laptopcomputer"
        case .creative: return "paintbrush.fill"
        case .language: return "globe"
        case .transportation: return "car.fill"
        case .shopping: return "cart.fill"
        case .homeServices: return "house.fill"
        case .petCare: return "pawprint.fill"
        case .sports: return "sportscourt.fill"
        case .food: return "fork.knife"
        case .events: return "calendar"
        case .hobbies: return "star.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    // Helper to get appropriate categories for each post type
    static func categories(for postType: PostType) -> [PostCategory] {
        switch postType {
        case .skillShare:
            return [.education, .technology, .creative, .language, .other]
        case .task:
            return [.transportation, .shopping, .homeServices, .petCare, .other]
        case .social:
            return [.sports, .food, .events, .hobbies, .other]
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
    let userId: String?
    let user: User?
    let type: PostType
    let category: PostCategory
    let rewardType: RewardType
    let title: String
    let description: String
    let karmaValue: Int? // Only for karma-based posts
    let paymentAmount: Double? // For cash tasks
    let location: Location?
    let locationName: String?
    let status: PostStatus
    let createdAt: Date
    let expiresAt: Date?
    let completedByUserId: String?
    let acceptedByUserId: String?
    let completionRating: Int?
    let completionReview: String?
    let ratedByUserId: String?
    let isAnonymous: Bool?
    let anonymousDisplayName: String?
    let tags: [String]
    let isRequest: Bool
    let isRemote: Bool
    
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
        guard let userId = userId else { return false }

        // Access main actor-isolated currentUser property safely
        let currentUserId = MainActor.assumeIsolated {
            AuthManager.shared.currentUser?.id
        }

        guard let currentUserId = currentUserId else { return false }
        return userId == currentUserId
    }
    
    var displayValue: String {
        switch rewardType {
        case .karma:
            if let karmaValue = karmaValue {
                return "\(karmaValue) karma"
            }
            return "0 karma"
        case .cash:
            if let amount = paymentAmount {
                return String(format: "$%.0f", amount.rounded())
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
            category: .creative,
            rewardType: .karma,
            title: "Learn to Cook Italian Pasta",
            description: "I'll teach you how to make authentic Italian pasta from scratch! We'll cover different types of pasta, sauces, and cooking techniques. Perfect for beginners.",
            karmaValue: 90,
            paymentAmount: nil,
            location: Location(latitude: 42.3651, longitude: -71.0540),
            locationName: "North End, Boston",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            expiresAt: Date().addingTimeInterval(86400 * 5),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: false,
            anonymousDisplayName: nil,
            tags: ["cooking", "italian", "pasta"],
            isRequest: false,
            isRemote: false
        ),
        Post(
            id: "post-2",
            userId: "mock-user-id",
            user: User.mockUser,
            type: .task,
            category: .homeServices,
            rewardType: .cash,
            title: "Need Help Moving Furniture",
            description: "Looking for someone to help me move a couch and some boxes to my new apartment. Should take about 2 hours. I have a truck already. Cash payment.",
            karmaValue: nil,
            paymentAmount: 50.0,
            location: Location(latitude: 42.3601, longitude: -71.0589),
            locationName: "Back Bay, Boston",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400),
            expiresAt: Date().addingTimeInterval(86400 * 3),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: false,
            anonymousDisplayName: nil,
            tags: ["moving", "physical", "quick-task"],
            isRequest: true,
            isRemote: false
        ),
        Post(
            id: "post-3",
            userId: "user-2",
            user: User.mockUsers[1],
            type: .skillShare,
            category: .technology,
            rewardType: .karma,
            title: "iOS Development Mentoring",
            description: "Experienced iOS developer offering mentoring sessions. I can help with Swift, SwiftUI, app architecture, and App Store submission process.",
            karmaValue: 60,
            paymentAmount: nil,
            location: Location(latitude: 42.3581, longitude: -71.0636),
            locationName: "Cambridge, MA",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            expiresAt: Date().addingTimeInterval(86400 * 7),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: false,
            anonymousDisplayName: nil,
            tags: ["ios", "swift", "programming", "mentoring"],
            isRequest: false,
            isRemote: true
        ),
        Post(
            id: "post-4",
            userId: nil,
            user: nil,
            type: .social,
            category: .hobbies,
            rewardType: .fun,
            title: "Looking for Guitar Practice Partner",
            description: "Intermediate guitar player looking for someone to practice with. I play folk and indie rock mostly. Would love to jam together!",
            karmaValue: nil,
            paymentAmount: nil,
            location: Location(latitude: 42.3601, longitude: -71.0589),
            locationName: "Back Bay, Boston",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400 * 4),
            expiresAt: Date().addingTimeInterval(86400 * 10),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: true,
            anonymousDisplayName: "MusicLover42",
            tags: ["music", "guitar", "practice-buddy"],
            isRequest: false,
            isRemote: false
        ),
        Post(
            id: "post-5",
            userId: "user-1",
            user: User.mockUsers[0],
            type: .task,
            category: .homeServices,
            rewardType: .karma,
            title: "Completed: Garden Setup Help",
            description: "Thanks to Alex for helping me set up my herb garden! Great work and very knowledgeable about plants.",
            karmaValue: 120,
            paymentAmount: nil,
            location: Location(latitude: 42.3651, longitude: -71.0540),
            locationName: "North End, Boston",
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400 * 10),
            expiresAt: nil,
            completedByUserId: "user-2",
            acceptedByUserId: "user-2",
            completionRating: 5,
            completionReview: "Alex was amazing! Very knowledgeable about plants.",
            ratedByUserId: "user-1",
            isAnonymous: false,
            anonymousDisplayName: nil,
            tags: ["gardening", "outdoor", "plants"],
            isRequest: true,
            isRemote: false
        ),
        Post(
            id: "post-6",
            userId: "user-2",
            user: User.mockUsers[1],
            type: .skillShare,
            category: .technology,
            rewardType: .karma,
            title: "Python Tutoring for Beginners",
            description: "Online Python programming lessons for absolute beginners. We'll start with basics and build up to simple projects. Screen sharing via Zoom.",
            karmaValue: 60,
            paymentAmount: nil,
            location: nil,
            locationName: "Remote",
            status: .active,
            createdAt: Date().addingTimeInterval(-86400),
            expiresAt: Date().addingTimeInterval(86400 * 14),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: false,
            anonymousDisplayName: nil,
            tags: ["python", "programming", "remote", "tutoring"],
            isRequest: false,
            isRemote: true
        ),
        Post(
            id: "post-7",
            userId: "user-1",
            user: User.mockUsers[0],
            type: .skillShare,
            category: .language,
            rewardType: .karma,
            title: "Practice Spanish Conversation",
            description: "Native Spanish speaker offering conversation practice. 30-minute sessions to help improve your speaking confidence. Video call preferred.",
            karmaValue: 30,
            paymentAmount: nil,
            location: nil,
            locationName: "Remote",
            status: .active,
            createdAt: Date().addingTimeInterval(-3600 * 6),
            expiresAt: Date().addingTimeInterval(86400 * 7),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: false,
            anonymousDisplayName: nil,
            tags: ["spanish", "language", "conversation", "remote"],
            isRequest: false,
            isRemote: true
        ),
        Post(
            id: "post-8",
            userId: nil,
            user: nil,
            type: .task,
            category: .other,
            rewardType: .karma,
            title: "Review My Resume",
            description: "Recent grad looking for someone to review my software engineering resume. Should take about 30 minutes. Can share via Google Docs.",
            karmaValue: 30,
            paymentAmount: nil,
            location: nil,
            locationName: "Remote",
            status: .active,
            createdAt: Date().addingTimeInterval(-3600 * 12),
            expiresAt: Date().addingTimeInterval(86400 * 3),
            completedByUserId: nil,
            acceptedByUserId: nil,
            completionRating: nil,
            completionReview: nil,
            ratedByUserId: nil,
            isAnonymous: true,
            anonymousDisplayName: "JobSeeker2025",
            tags: ["resume", "career", "review", "remote"],
            isRequest: true,
            isRemote: true
        )
    ]
    
    static let mockPost = mockPosts[0]
}

