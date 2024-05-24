//
//  ContentActionButtonViewModel.swift
//  Threads
//
//  Created by Tobias Fu on 1/23/24.
//

import Foundation

@MainActor
class ContentActionButtonViewModel: ObservableObject {
    @Published var post: Post?
    @Published var reply: PostReply?
    
    init(contentType: PostViewConfig) {
        switch contentType {
        case .post(let post):
            self.post = post
            Task { try await checkIfUserLikedPost() }
            
        case .reply(let reply):
            self.reply = reply
        }
    }
    
    func likePost() async throws {
        guard let post = post else { return }
        
        try await PostService.likePost(post)
        self.post?.didLike = true
        self.post?.likes += 1
    }
    
    func unlikePost() async throws {
        guard let post = post else { return }

        try await PostService.unlikePost(post)
        self.post?.didLike = false
        self.post?.likes -= 1
    }
    
    func checkIfUserLikedPost() async throws {
        guard let post = post else { return }

        let didLike = try await PostService.checkIfUserLikedPost(post)
        if didLike {
            self.post?.didLike = true
        }
    }
}
