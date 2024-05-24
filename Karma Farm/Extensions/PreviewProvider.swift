//
//  PreviewProvider.swift
//  Threads
//
//  Created by Tobias Fu on 1/9/24.
//

import SwiftUI
import Firebase 

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
}

class DeveloperPreview {
    static let shared = DeveloperPreview()
    let user = User(id: "123", fullname: "Tobias Fu", email: "zfu04@tufts.edu", username: "realtobyfu")
//    let currentUser = user

    
    let post = Post(ownerUid: "123", caption: "This is a test post", createdAt: Timestamp(), replyCount: 0, likes: 0)
}
