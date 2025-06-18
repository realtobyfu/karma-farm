//
//  FeedViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation


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
        do {
            let posts = try await APIService.shared.fetchPosts()
            self.posts = posts
        } catch {
            print("Failed to fetch posts: \(error)")
        }
    }
    
    func refresh() async {
        await fetchPosts()
    }
    
    func filterChanged(to filter: FeedFilter) {
        // TODO: Apply filter and fetch posts
    }
}
