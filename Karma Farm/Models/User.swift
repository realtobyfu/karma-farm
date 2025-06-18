//
//  User.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import FirebaseAuth
// MARK: - Models

struct GeoPoint: Codable {
    var latitude: Double
    var longitude: Double
}

struct User: Codable, Identifiable {
    let id: String
    let firebaseUid: String
    let username: String
    var profilePicture: String?
    var karmaBalance: Int
    var email: String?
    var phoneNumber: String?
    var isEmailVerified: Bool
    var isPhoneVerified: Bool
    var bio: String?
    var skills: [String]
    var interests: [String]
    var privateProfile: PrivateProfile?
    var lastLocation: GeoPoint?
    var badges: [Badge]
    let createdAt: Date
    let updatedAt: Date
    var isDiscoverable: Bool
    
    var isCurrentUser: Bool {
        return firebaseUid == Auth.auth().currentUser?.uid
    }
    
    enum CodingKeys: String, CodingKey {
        case id, firebaseUid, username, profilePicture, karmaBalance, email, phoneNumber, isEmailVerified, isPhoneVerified, bio, skills, interests, privateProfile, lastLocation, badges, createdAt, updatedAt, isDiscoverable
    }
}

struct PrivateProfile: Codable {
    var age: Int?
    var gender: String?
    var realName: String?
    var privatePicture: String?
}


/* Other Structs */
struct Chat: Identifiable {
    let id: String
    let participants: [String]
    var lastMessage: Message?
    var unreadCount: Int
    let createdAt: Date
    var user: User? // Other participant
}

struct Message: Identifiable {
    let id: String
    let chatId: String
    let senderId: String
    let content: String
    let createdAt: Date
    var isRead: Bool
}

struct KarmaTransaction: Codable, Identifiable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let amount: Int
    let postId: String?
    let type: TransactionType
    let createdAt: Date
    
    enum TransactionType: String, Codable {
        case earned = "earned"
        case given = "given"
        case bonus = "bonus"
    }
}

struct UserStats {
    let postsCreated: Int
    let karmaEarned: Int
    let karmaGiven: Int
    let connections: Int
}
