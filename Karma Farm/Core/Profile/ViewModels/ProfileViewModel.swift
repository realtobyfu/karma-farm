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

    private var loadTask: Task<Void, Never>?
    private var statsTask: Task<Void, Never>?

    var userStats: UserStats {
        return stats
    }

    init() {
        startInitialLoad()
    }

    deinit {
        loadTask?.cancel()
        statsTask?.cancel()
    }

    private func startInitialLoad() {
        loadTask?.cancel()
        loadTask = Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        guard !Task.isCancelled else { return }
        currentUser = AuthManager.shared.currentUser

        // Use TaskGroup to load stats and posts concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                await self?.loadStats()
            }

            group.addTask { [weak self] in
                await self?.loadRecentPosts()
            }
        }
    }

    func loadUserStats() {
        statsTask?.cancel()
        statsTask = Task {
            await loadStats()
        }
    }

    private func loadStats() async {
        guard !Task.isCancelled else { return }

        do {
            guard let user = AuthManager.shared.currentUser else { return }

            guard !Task.isCancelled else { return }
            guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else { return }

            guard !Task.isCancelled else { return }
            guard let url = URL(string: "\(APIConfig.baseURL)/auth/stats") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

            guard !Task.isCancelled else { return }
            let (data, _) = try await URLSession.shared.data(for: request)

            guard !Task.isCancelled else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let stats = try decoder.decode(UserStats.self, from: data)

            guard !Task.isCancelled else { return }
            self.stats = stats
        } catch {
            guard !Task.isCancelled else { return }
            print("Failed to load stats: \(error)")
        }
    }

    private func loadRecentPosts() async {
        guard !Task.isCancelled else { return }

        do {
            guard let user = AuthManager.shared.currentUser else { return }

            guard !Task.isCancelled else { return }
            guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else { return }

            guard !Task.isCancelled else { return }
            guard let url = URL(string: "\(APIConfig.baseURL)/auth/recent-posts") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

            guard !Task.isCancelled else { return }
            let (data, _) = try await URLSession.shared.data(for: request)

            guard !Task.isCancelled else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let posts = try decoder.decode([Post].self, from: data)

            guard !Task.isCancelled else { return }
            self.recentPosts = posts
        } catch {
            guard !Task.isCancelled else { return }
            print("Failed to load recent posts: \(error)")
        }
    }
}
