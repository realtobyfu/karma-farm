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
        isLoading = true
        // TODO: Fetch posts from backend
        isLoading = false
    }
    
    func refresh() async {
        await fetchPosts()
    }
    
    func filterChanged(to filter: FeedFilter) {
        // TODO: Apply filter and fetch posts
    }
}
