//
//  ActivityModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct ActivityModel: Identifiable, Codable, Hashable {
    @DocumentID private var activityModelId: String?
    let type: ActivityType
    let senderUid: String
    let createdAt: Timestamp
    var postId: String?
    
    
    var user: User?
    var post: Post?
    var isFollowed: Bool?
    
    var id: String {
        return activityModelId ?? NSUUID().uuidString
    }
}
