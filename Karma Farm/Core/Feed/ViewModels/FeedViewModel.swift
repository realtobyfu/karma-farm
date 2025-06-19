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
            let posts = try await APIService.shared.fetchPosts(token)
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
        // TODO: Apply filter and fetch posts
    }
}
