//
//  FeedViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import FirebaseAuth


@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var currentFilter: FeedFilter = .all
    @Published var locationManager = LocationManager.shared

    private var fetchTask: Task<Void, Never>?

    init() {
        startInitialFetch()
    }

    deinit {
        fetchTask?.cancel()
    }

    private func startInitialFetch() {
        fetchTask?.cancel()
        fetchTask = Task {
            await fetchPosts()
        }
    }
    
    func fetchPosts() async {
        // Check if task was cancelled
        guard !Task.isCancelled else { return }

        isLoading = true
        do {
            // Get current user's auth token
            guard let user = AuthManager.shared.firebaseUser else {
                print("No authenticated user")
                self.posts = Post.mockPosts
                isLoading = false
                return
            }

            // Check cancellation before network call
            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            let token = try await user.getIDToken()

            // Build filter parameters based on current filter
            var parameters: [String: Any] = [:]

            switch currentFilter {
            case .all:
                // No additional filters
                break
            case .requests:
                parameters["type"] = PostType.task.rawValue
            case .offers:
                parameters["type"] = PostType.skillShare.rawValue
            case .nearby:
                if let location = locationManager.userLocation {
                    parameters["latitude"] = location.coordinate.latitude
                    parameters["longitude"] = location.coordinate.longitude
                    parameters["radius"] = 5000 // 5km radius
                }
            case .following:
                // TODO: Implement following filter when connections are integrated
                break
            case .myPosts:
                parameters["userId"] = AuthManager.shared.currentUser?.id
            }

            // Always filter for active posts
            parameters["status"] = PostStatus.active.rawValue

            // Check cancellation before API call
            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            let posts = try await APIService.shared.fetchPosts(token, parameters: parameters)

            // Check cancellation before updating UI
            guard !Task.isCancelled else { return }

            self.posts = posts
        } catch {
            // Don't update UI if cancelled
            guard !Task.isCancelled else { return }

            print("Failed to fetch posts: \(error)")
            // Use mock data for now
            self.posts = Post.mockPosts
        }

        // Only update loading state if not cancelled
        if !Task.isCancelled {
            isLoading = false
        }
    }
    
    func refresh() async {
        await fetchPosts()
    }
    
    func filterChanged(to filter: FeedFilter) {
        currentFilter = filter
        fetchTask?.cancel()
        fetchTask = Task {
            await fetchPosts()
        }
    }

    /// Load posts and user stats concurrently for performance optimization
    func loadFeedWithUserStats() async {
        fetchTask?.cancel()
        fetchTask = Task {
            // Check if task was cancelled
            guard !Task.isCancelled else { return }

            isLoading = true

            do {
                // Get current user's auth token
                guard let user = AuthManager.shared.firebaseUser else {
                    print("No authenticated user")
                    self.posts = Post.mockPosts
                    isLoading = false
                    return
                }

                // Check cancellation before network call
                guard !Task.isCancelled else {
                    isLoading = false
                    return
                }

                let token = try await user.getIDToken()

                // Use TaskGroup to load posts and user stats concurrently
                try await withThrowingTaskGroup(of: Void.self) { group in
                    // Add task to fetch posts
                    group.addTask { [weak self] in
                        guard let self = self, !Task.isCancelled else { return }

                        var parameters: [String: Any] = [:]

                        switch await self.currentFilter {
                        case .all:
                            break
                        case .requests:
                            parameters["type"] = PostType.task.rawValue
                        case .offers:
                            parameters["type"] = PostType.skillShare.rawValue
                        case .nearby:
                            if let location = await self.locationManager.userLocation {
                                parameters["latitude"] = location.coordinate.latitude
                                parameters["longitude"] = location.coordinate.longitude
                                parameters["radius"] = 5000
                            }
                        case .following:
                            break
                        case .myPosts:
                            parameters["userId"] = await AuthManager.shared.currentUser?.id
                        }

                        parameters["status"] = PostStatus.active.rawValue

                        guard !Task.isCancelled else { return }
                        let posts = try await APIService.shared.fetchPosts(token, parameters: parameters)

                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            self.posts = posts
                        }
                    }

                    // Add task to refresh user data in background
                    group.addTask {
                        guard !Task.isCancelled else { return }
                        try await AuthManager.shared.fetchCurrentUser()
                    }

                    // Wait for all tasks to complete
                    try await group.waitForAll()
                }

            } catch {
                // Don't update UI if cancelled
                guard !Task.isCancelled else { return }

                print("Failed to load feed with user stats: \(error)")
                // Use mock data for now
                self.posts = Post.mockPosts
            }

            // Only update loading state if not cancelled
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
}
