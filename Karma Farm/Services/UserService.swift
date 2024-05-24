//
//  UserService.swift
//  Threads
//
//  Created by Tobias Fu on 1/9/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class UserService {
    
    @Published var currentUser: User?
    
    static let shared = UserService()
    private static let userCache = NSCache<NSString, NSData>()

    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        self.currentUser = user
    }
    
    static func fetchUser(withUid uid: String) async throws -> User {
        if let nsData = userCache.object(forKey: uid as NSString) {
            if let user = try? JSONDecoder().decode(User.self, from: nsData as Data) {
                return user
            }
        }
        
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        
        if let userData = try? JSONEncoder().encode(user) {
            userCache.setObject(userData as NSData, forKey: uid as NSString)
        }
        
        return user
    }
    
    static func fetchUsers() async throws -> [User] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let snapshot = try await FirestoreConstants.UserCollection.getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
        return users.filter({ $0.id != uid })
    }
}

// MARK: - Following

extension UserService {
    func updateUserFeedAfterFollow(followedUid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postsSnapshot = try await FirestoreConstants.PostsCollection.whereField("ownerUid", isEqualTo: followedUid).getDocuments()
        
        for document in postsSnapshot.documents {
            try await FirestoreConstants
                .UserCollection
                .document(currentUid)
                .collection("user-feed")
                .document(document.documentID)
                .setData([:])
        }
    }
    
    func updateUserFeedAfterUnfollow(unfollowedUid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postsSnapshot = try await FirestoreConstants.PostsCollection.whereField("ownerUid", isEqualTo: unfollowedUid).getDocuments()
        
        for document in postsSnapshot.documents {
            try await FirestoreConstants
                .UserCollection
                .document(currentUid)
                .collection("user-feed")
                .document(document.documentID)
                .delete()
        }
    }
}

// MARK: - Helpers

extension UserService {
    static func fetchUserStats(uid: String) async throws -> UserStats {
        async let followingSnapshot = try await FirestoreConstants.FollowingCollection.document(uid).collection("user-following").getDocuments()
        let following = try await followingSnapshot.count
        
        async let followerSnapshot = try await FirestoreConstants.FollowersCollection.document(uid).collection("user-followers").getDocuments()
        let followers = try await followerSnapshot.count
        
        async let postsSnapshot = try await FirestoreConstants.PostsCollection.whereField("ownerUid", isEqualTo: uid).getDocuments()
        let postsCount = try await postsSnapshot.count
        
        return .init(postsCount: postsCount)
    }
 
    
    private static func fetchUsers(_ snapshot: QuerySnapshot?) async throws -> [User] {
        var users = [User]()
        guard let documents = snapshot?.documents else { return [] }
        
        for doc in documents {
            let user = try await UserService.fetchUser(withUid: doc.documentID)
            users.append(user)
        }
        
        return users
    }
}
