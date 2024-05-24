//
//  FeedViewModel.swift
//  Threads
//
//  Created by Tobias Fu on 1/12/24.
//

import Foundation
import SwiftUI


@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    init() {
        Task { try await fetchPosts() }
    }
    
    func fetchPosts() async throws {
        self.posts = try await PostService.fetchPosts()
        try await fetchUserDataForPosts()
    }
    
    private func fetchUserDataForPosts() async throws {
        
        for i in 0 ..< posts.count {
            // we use index because we want to update the original posts array,
            // which is the source of truth
            let post = posts[i]
            let ownerUid = post.ownerUid
            let postUser = try await UserService.fetchUser(withUid: ownerUid)
            
            posts[i].user = postUser
        }
    }
}

