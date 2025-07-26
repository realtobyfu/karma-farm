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
    
    init() {
        Task {
            await fetchPosts()
        }
    }
    
    func fetchPosts() async {
        isLoading = true
        do {
            // Get current user's auth token
            guard let user = AuthManager.shared.firebaseUser else {
                print("No authenticated user")
                self.posts = Post.mockPosts
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
            
            let posts = try await APIService.shared.fetchPosts(token, parameters: parameters)
            self.posts = posts
        } catch {
            print("Failed to fetch posts: \(error)")
            // Use mock data for now
            self.posts = Post.mockPosts
        }
        isLoading = false
    }
    
    func refresh() async {
        await fetchPosts()
    }
    
    func filterChanged(to filter: FeedFilter) {
        currentFilter = filter
        Task {
            await fetchPosts()
        }
    }
}
