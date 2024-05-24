//
//  PostCreationViewModel.swift
//  Threads
//
//  Created by Tobias Fu on 1/11/24.
//

import Firebase

class PostCreationViewModel: ObservableObject {
    
    func uploadPost(caption: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let post = Post(ownerUid: uid, caption: caption, createdAt: Timestamp(), replyCount: 0, likes: 0)
        
        try await PostService.uploadPost(post)
    }
}
