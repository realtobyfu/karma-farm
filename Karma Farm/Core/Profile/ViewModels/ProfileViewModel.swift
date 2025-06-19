//
//  ProfileViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation
import FirebaseAuth

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
        await loadStats()
        await loadRecentPosts()
    }

    private func loadStats() async {
        do {
            guard let user = AuthManager.shared.currentUser else { return }
            guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else { return }
            guard let url = URL(string: "\(APIConfig.baseURL)/auth/stats") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            let stats = try JSONDecoder().decode(UserStats.self, from: data)
            self.stats = stats
        } catch {
            print("Failed to load stats: \(error)")
        }
    }

    private func loadRecentPosts() async {
        do {
            guard let user = AuthManager.shared.currentUser else { return }
            guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else { return }
            guard let url = URL(string: "\(APIConfig.baseURL)/auth/recent-posts") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            self.recentPosts = posts
        } catch {
            print("Failed to load recent posts: \(error)")
        }
    }
}
