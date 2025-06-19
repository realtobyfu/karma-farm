//
//  Badge.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation
import SwiftUI

struct Badge: Codable, Identifiable {
    let id: String
    let type: String
    let value: String
    let verifiedAt: Date
    
    var title: String {
        switch type {
        case "student": return "College Student"
        case "professional": return "Professional"
        case "local": return "Local Resident"
        case "volunteer": return "Active Volunteer"
        case "verified": return "Verified User"
        case "college": return "College Student"
        default: return type
        }
    }
    
    var icon: String {
        switch type {
        case "student", "college": return "graduationcap.fill"
        case "professional": return "briefcase.fill"
        case "local": return "location.fill"
        case "volunteer": return "heart.fill"
        case "verified": return "checkmark.seal.fill"
        default: return "rosette"
        }
    }
    
    var color: Color {
        switch type {
        case "student", "college": return Color("5B4FE5")
        case "professional": return Color("2196F3")
        case "local": return Color("4CAF50")
        case "volunteer": return Color("FF6B6B")
        case "verified": return Color("FF9800")
        default: return Color.gray
        }
    }
}

// MARK: - Mock Data
extension Badge {
    static let mockCollegeBadge = Badge(
        id: "badge-college-1",
        type: "college",
        value: "Tufts University",
        verifiedAt: Date().addingTimeInterval(-86400 * 15)
    )
    
    static let mockVerifiedBadge = Badge(
        id: "badge-verified-1",
        type: "verified",
        value: "Phone Verified",
        verifiedAt: Date().addingTimeInterval(-86400 * 30)
    )
    
    static let mockProfessionalBadge = Badge(
        id: "badge-professional-1",
        type: "professional",
        value: "Software Engineer",
        verifiedAt: Date().addingTimeInterval(-86400 * 10)
    )
    
    static let mockLocalBadge = Badge(
        id: "badge-local-1",
        type: "local",
        value: "Boston Resident",
        verifiedAt: Date().addingTimeInterval(-86400 * 5)
    )
    
    static let mockVolunteerBadge = Badge(
        id: "badge-volunteer-1",
        type: "volunteer",
        value: "Community Helper",
        verifiedAt: Date().addingTimeInterval(-86400 * 20)
    )
    
    static let mockBadges: [Badge] = [
        mockCollegeBadge,
        mockVerifiedBadge,
        mockProfessionalBadge,
        mockLocalBadge,
        mockVolunteerBadge
    ]
}
