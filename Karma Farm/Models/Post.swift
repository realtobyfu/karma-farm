import Foundation
import CoreLocation

enum PostType: String, Codable, CaseIterable {
    case skillShare = "skill_share"
    case task = "task"
    case interest = "interest"
    
    var displayName: String {
        switch self {
        case .skillShare: return "Skill Share"
        case .task: return "Task"
        case .interest: return "Interest"
        }
    }
    
    var icon: String {
        switch self {
        case .skillShare: return "lightbulb.fill"
        case .task: return "checkmark.circle.fill"
        case .interest: return "heart.fill"
        }
    }
}

struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let user: User?
    let type: PostType
    let title: String
    let description: String
    let karmaValue: Int
    let isRequest: Bool
    let location: Location?
    let locationName: String?
    let status: String
    let createdAt: Date
    let expiresAt: Date?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let location = location else { return nil }
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}
