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

// MARK: - Mock Data for Testing and Previews
extension User {
    static let mockUser = User(
        id: "mock-user-id",
        firebaseUid: "mock-firebase-uid",
        username: "johndoe",
        profilePicture: nil,
        karmaBalance: 150,
        email: "john@example.com",
        phoneNumber: "+1234567890",
        isEmailVerified: false,
        isPhoneVerified: true,
        bio: "Love helping others and learning new skills!",
        skills: ["iOS Development", "Cooking", "Guitar"],
        interests: ["Technology", "Music", "Food"],
        privateProfile: PrivateProfile(age: 25, gender: "Male", realName: "John Doe", privatePicture: nil),
        lastLocation: GeoPoint(latitude: 42.3601, longitude: -71.0589),
        badges: [Badge.mockCollegeBadge, Badge.mockVerifiedBadge],
        createdAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
        updatedAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
        isDiscoverable: true
    )
    
    static let mockUsers: [User] = [
        User(
            id: "user-1",
            firebaseUid: "firebase-uid-1",
            username: "sarah_cook",
            profilePicture: nil,
            karmaBalance: 220,
            email: "sarah@example.com",
            phoneNumber: "+1987654321",
            isEmailVerified: false,
            isPhoneVerified: true,
            bio: "Professional chef, love teaching cooking!",
            skills: ["Cooking", "Baking", "Nutrition"],
            interests: ["Food", "Health", "Travel"],
            privateProfile: PrivateProfile(age: 28, gender: "Female", realName: "Sarah Johnson", privatePicture: nil),
            lastLocation: GeoPoint(latitude: 42.3651, longitude: -71.0540),
            badges: [Badge.mockVerifiedBadge],
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: Date().addingTimeInterval(-86400),
            isDiscoverable: true
        ),
        User(
            id: "user-2",
            firebaseUid: "firebase-uid-2",
            username: "techguru",
            profilePicture: nil,
            karmaBalance: 180,
            email: "tech@example.com",
            phoneNumber: "+1555123456",
            isEmailVerified: false,
            isPhoneVerified: true,
            bio: "Software engineer helping others learn to code",
            skills: ["Programming", "Web Development", "Mobile Apps"],
            interests: ["Technology", "Gaming", "Open Source"],
            privateProfile: PrivateProfile(age: 32, gender: "Male", realName: "Alex Chen", privatePicture: nil),
            lastLocation: GeoPoint(latitude: 42.3581, longitude: -71.0636),
            badges: [Badge.mockCollegeBadge],
            createdAt: Date().addingTimeInterval(-86400 * 45),
            updatedAt: Date().addingTimeInterval(-86400 * 3),
            isDiscoverable: true
        )
    ]
}

extension PrivateProfile {
    static let mockPrivateProfile = PrivateProfile(
        age: 25,
        gender: "Male",
        realName: "John Doe",
        privatePicture: nil
    )
}

extension UserStats {
    static let mockStats = UserStats(
        postsCreated: 12,
        karmaEarned: 150,
        karmaGiven: 80,
        connections: 25
    )
}

/* Other Structs */
struct Chat: Codable, Identifiable {
    let id: String
    let participants: [String]
    var lastMessage: Message?
    var unreadCount: Int
    let createdAt: Date
    var user: User? // Other participant
    
    enum CodingKeys: String, CodingKey {
        case id, participants, lastMessage, unreadCount, createdAt, user
    }
}

struct Message: Codable, Identifiable {
    let id: String
    let chatId: String
    let senderId: String
    let content: String
    let createdAt: Date
    var isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, chatId, senderId, content, createdAt, isRead
    }
}

// MARK: - Mock Data for Chat
extension Chat {
    static let mockChats: [Chat] = [
        Chat(
            id: "chat-1",
            participants: ["mock-user-id", "user-1"],
            lastMessage: Message.mockMessages[0],
            unreadCount: 2,
            createdAt: Date().addingTimeInterval(-86400 * 5),
            user: User.mockUsers[0]
        ),
        Chat(
            id: "chat-2",
            participants: ["mock-user-id", "user-2"],
            lastMessage: Message.mockMessages[1],
            unreadCount: 0,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            user: User.mockUsers[1]
        )
    ]
}

extension Message {
    static let mockMessages: [Message] = [
        Message(
            id: "msg-1",
            chatId: "chat-1",
            senderId: "user-1",
            content: "Hey! Are you still available to help with cooking today?",
            createdAt: Date().addingTimeInterval(-3600 * 2),
            isRead: false
        ),
        Message(
            id: "msg-2",
            chatId: "chat-2",
            senderId: "mock-user-id",
            content: "Thanks for the programming help yesterday!",
            createdAt: Date().addingTimeInterval(-86400),
            isRead: true
        )
    ]
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

struct UserStats: Codable {
    let postsCreated: Int
    let karmaEarned: Int
    let karmaGiven: Int
    let connections: Int
}
