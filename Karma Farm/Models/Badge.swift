//
//  Badge.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation
import SwiftUICore

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
        default: return type
        }
    }
    
    var icon: String {
        switch type {
        case "student": return "graduationcap.fill"
        case "professional": return "briefcase.fill"
        case "local": return "location.fill"
        case "volunteer": return "heart.fill"
        default: return "rosette"
        }
    }
    
    var color: Color {
        switch type {
        case "student": return Color("5B4FE5")
        case "professional": return Color( "2196F3")
        case "local": return Color("4CAF50")
        case "volunteer": return Color("FF6B6B")
        default: return Color.gray
        }
    }
}
