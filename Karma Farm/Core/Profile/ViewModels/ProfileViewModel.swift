//
//  ProfileViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var stats = UserStats(postsCreated: 0, karmaEarned: 0, karmaGiven: 0, connections: 0)
    @Published var recentPosts: [Post] = []
    
    init() {
        Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        currentUser = AuthManager.shared.currentUser
        // TODO: Load stats and recent posts
    }
}
