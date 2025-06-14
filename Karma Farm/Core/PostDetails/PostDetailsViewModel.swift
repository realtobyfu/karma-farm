//
//  PostDetailsViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//
import Foundation
import Firebase

@MainActor
class PostDetailsViewModel: ObservableObject {
    @Published var post: Post
    @Published var replies = [PostReply]()
    
    init(post: Post) {
        self.post = post
        setPostUserIfNecessary()
        Task { try await fetchPostReplies() }
    }
    
    private func setPostUserIfNecessary() {
        guard post.user == nil else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if post.ownerUid == currentUid {
            post.user = UserService.shared.currentUser
        }
    }
    
    func fetchPostReplies() async throws {
        self.replies = try await PostService.fetchPostReplies(forPost: post)
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for reply in replies {
                group.addTask { try await self.fetchUserData(forReply: reply) }
            }
        })
    }
    
    private func fetchUserData(forReply reply: PostReply) async throws {
        guard let replyIndex = replies.firstIndex(where: { $0.id == reply.id }) else { return }
        
        async let user = UserService.fetchUser(withUid: reply.postReplyOwnerUid)
        self.replies[replyIndex].replyUser = try await user
    }
}
