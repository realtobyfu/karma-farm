//
//  ActivityService.swift
//  Threads
//
//  Created by Stephan Dowless on 7/20/23.
//

import Firebase
import FirebaseFirestoreSwift

struct ActivityService {
    static func fetchUserActivity() async throws -> [ActivityModel] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await FirestoreConstants
            .ActivityCollection
            .document(uid)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: ActivityModel.self) })
    }
    
    static func uploadNotification(toUid uid: String, type: ActivityType, postId: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let model = ActivityModel(
            type: type,
            senderUid: currentUid,
            createdAt: Timestamp(),
            postId: postId // Changed from threadId to postId
        )
        
        guard let data = try? Firestore.Encoder().encode(model) else { return }
        
        FirestoreConstants.ActivityCollection.document(uid).collection("user-notifications").addDocument(data: data)
    }
    
    static func deleteNotification(toUid uid: String, type: ActivityType, postId: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await FirestoreConstants
            .ActivityCollection
            .document(uid)
            .collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid)
            .getDocuments()
        
        for document in snapshot.documents {
            let notification = try? document.data(as: ActivityModel.self)
            guard notification?.type == type else { continue } // Changed from return to continue
            
            if postId != nil {
                guard postId == notification?.postId else { continue } // Changed from threadId to postId and from return to continue
            }
            
            try await document.reference.delete()
        }
    }
}
