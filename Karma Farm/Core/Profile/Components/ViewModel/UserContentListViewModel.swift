//
//  UserContentListViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/28/24.
//

import Foundation

@MainActor
class UserContentListViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var replies = [PostReply]()
    
    private let user: User
    
    init(user: User) {
        self.user = user
        Task { try await fetchUserPosts() }
        Task { try await fetchUserReplies() }
    }
    
    func fetchUserPosts() async throws {
        var userPosts = try await PostService.fetchUserPosts(uid: user.id)
        
        for i in 0 ..< userPosts.count {
            userPosts[i].user = self.user
        }
        self.posts = userPosts
    }
    
    func fetchUserReplies() async throws {
        self.replies = try await PostService.fetchPostReplies(forUser: user)
        try await fetchReplyMetadta()
    }
    
    private func fetchReplyMetadta() async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for reply in self.replies {
                group.addTask { try await self.fetchReplyPostData(reply: reply) }
            }
        })
    }
    
    private func fetchReplyPostData(reply: PostReply) async throws {
        guard let replyIndex = replies.firstIndex(where: { $0.id == reply.id }) else { return }
        
        async let post = try await PostService.fetchPost(postId: reply.postId)
        
        let postOwnerUid = try await post.ownerUid
        async let user = try await UserService.fetchUser(withUid: postOwnerUid)
        
        var postCopy = try await post
        postCopy.user = try await user
        replies[replyIndex].post = postCopy
    }
    
    func noContentText(filter: ProfilePostFilterViewModel) -> String {
        let name = user.isCurrentUser ? "You" : user.username
        let nextWord = user.isCurrentUser ? "haven't" : "hasn't"
        let contentType = filter == .posts ? "posts" : "replies"
        
        return "\(name) \(nextWord) posted any \(contentType) yet."
    }
}
