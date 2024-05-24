//
//  PostService.swift
//  Threads
//
//  Created by Tobias Fu on 1/11/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct PostService {
    
    static func uploadPost(_ post: Post) async throws {
        guard let postData = try? Firestore.Encoder().encode(post) else { return }
        try await Firestore.firestore().collection("posts").addDocument(data: postData)
    }
    
    static func fetchPosts() async throws -> [Post] {
        let snapshot = try await Firestore
            .firestore()
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Post.self) })
    }
    
    static func fetchUserPosts(uid: String) async throws -> [Post] {
        // To-do: making those paths
        let snapshot = try await Firestore
            .firestore()
            .collection("posts")
            .whereField("ownerUid", isEqualTo: uid)
            .getDocuments()
        
        let posts = snapshot.documents.compactMap({ try? $0.data(as: Post.self) })
        // this gives us the most recent posts first
        return posts.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() })
    }
    
    static func fetchPost(postId: String) async throws -> Post {
        let snapshot = try await FirestoreConstants.PostsCollection.document(postId).getDocument()
        let post = try snapshot.data(as: Post.self)
        return post
    }

}

// MARK: - Likes

extension PostService {
    static func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let threadRef = FirestoreConstants.PostsCollection.document(post.id)
        
        // async let runs all the "try await" tasks, which means they are run simultaneously,
        // and we wait for their completion
        async let _ = try await threadRef.collection("post-likes").document(uid).setData([:])
        async let _ = try await threadRef.updateData(["likes": post.likes + 1])
        async let _ = try await FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(post.id).setData([:])
        
    }
    
    
    static func unlikePost(_ post: Post) async throws {
        guard post.likes > 0 else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let threadRef = FirestoreConstants.PostsCollection.document(post.id)
        
        async let _ = try await threadRef.collection("post-likes").document(uid).delete()
        async let _ = try await FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(post.id).delete()
        async let _ = try await threadRef.updateData(["likes": post.likes - 1])
    }
    
    static func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false}
         
        
        let snapshot = try await FirestoreConstants
            .UserCollection
            .document(uid)
            .collection("user-likes")
            .document(post.id)
            .getDocument()
        
        return snapshot.exists
    }
}


// MARK: - Replies

extension PostService {
    static func replyToPost(_ post: Post, replyText: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let reply = PostReply(
            postId: post.id,
            replyText: replyText,
            postReplyOwnerUid: currentUid,
            postOwnerUid: post.ownerUid,
            createdAt: Timestamp()
        )
        
        guard let data = try? Firestore.Encoder().encode(reply) else { return }
        try await FirestoreConstants.RepliesCollection.document().setData(data)
        try await FirestoreConstants.PostsCollection.document(post.id).updateData([
            "replyCount": post.replyCount + 1
        ])
        
        ActivityService.uploadNotification(toUid: post.ownerUid, type: .reply, postId: post.id)
    }
    
    static func fetchPostReplies(forPost post: Post) async throws -> [PostReply] {
        let snapshot = try await FirestoreConstants.RepliesCollection.whereField("postId", isEqualTo: post.id).getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: PostReply.self) })
    }
    
    static func fetchPostReplies(forUser user: User) async throws -> [PostReply] {
       let snapshot = try await  FirestoreConstants
            .RepliesCollection
            .whereField("postReplyOwnerUid", isEqualTo: user.id)
            .getDocuments()
        
        var replies = snapshot.documents.compactMap({ try? $0.data(as: PostReply.self) })
        
        for i in 0 ..< replies.count {
            replies[i].replyUser = user
        }
        
        return replies
    }
}
