//
//  UserProfileViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/28/24.
//

import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var posts = [Post]()  // Renamed from threads
    @Published var replies = [PostReply]()  // Assuming ThreadReply has been renamed to PostReply
    @Published var user: User
    
    init(user: User) {
        self.user = user
        loadUserData()
    }
        
    func loadUserData() {
        Task {
            async let stats = try await UserService.fetchUserStats(uid: user.id)
            self.user.stats = try await stats

        }
    }
}

//// MARK: - Following
//
//extension UserProfileViewModel {
//    func follow() async throws {
//        try await UserService.shared.follow(uid: user.id)
//        self.user.isFollowed = true
//        self.user.stats?.followersCount += 1
//    }
//    
//    func unfollow() async throws {
//        try await UserService.shared.unfollow(uid: user.id)
//        self.user.isFollowed = false
//        self.user.stats?.followersCount -= 1
//    }
//    
//    func checkIfUserIsFollowed() async -> Bool {
//        return await UserService.checkIfUserIsFollowed(user)
//    }
//}
