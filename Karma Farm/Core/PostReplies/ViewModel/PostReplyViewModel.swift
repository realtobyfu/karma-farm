//
//  PostReplyViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import Foundation

class PostReplyViewModel: ObservableObject {
    func uploadPostReply(toPost post: Post, replyText: String) async throws {
        try await PostService.replyToPost(post, replyText: replyText)
    }
}
  
