//
//  Post.swift
//  Threads
//
//  Created by Tobias Fu on 1/11/24.
//

import Firebase
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Hashable {
    @DocumentID var postId: String?
    
    // takes us to the username/ profile image
    let ownerUid: String
    let caption: String
    let createdAt: Timestamp
    var replyCount: Int
    
//    var karma: Int?
    // use ownerUid -> user after having fetched the post
    // dependency, a owner has to be associated with a post
    var user: User?

    var didLike: Bool?
    var likes: Int
    
    var id: String {
        return postId ?? NSUUID().uuidString
    }
    
}
