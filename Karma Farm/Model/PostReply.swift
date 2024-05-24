//
//  PostReply.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import FirebaseFirestoreSwift
import Firebase

struct PostReply: Identifiable, Codable {
    @DocumentID private var replyId: String?
    let postId: String
    let replyText: String
    let postReplyOwnerUid: String
    let postOwnerUid: String
    let createdAt: Timestamp
    
    var post: Post?
    var replyUser: User?
    
    var id: String {
        return replyId ?? NSUUID().uuidString
    }
}
