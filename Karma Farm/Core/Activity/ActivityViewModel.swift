//
//  ActivityViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//
//
import Foundation

import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var notifications = [ActivityModel]()
    @Published var isLoading = false
    
    @Published var selectedFilter: ActivityFilterViewModel = .all {
        didSet {
            switch selectedFilter {
            case .all:
                self.notifications = temp
            case .replies:
                temp = notifications
                self.notifications = notifications.filter({ $0.type == .reply })
            }
        }
    }
    
    private var temp = [ActivityModel]()
    
    init() {
        Task { try await updateNotifications() }
    }
    
    private func fetchNotificationData() async throws {
        self.isLoading = true
        self.notifications = try await ActivityService.fetchUserActivity()
        self.isLoading = false
    }
    
    private func updateNotifications() async throws {
        try await fetchNotificationData()
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for notification in notifications {
                group.addTask { try await self.updateNotificationMetadata(notification: notification) }
            }
        })
    }
    
    private func updateNotificationMetadata(notification: ActivityModel) async throws {
        guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        
        async let notificationUser = try await UserService.fetchUser(withUid: notification.senderUid)
        var user = try await notificationUser
        
        self.notifications[indexOfNotification].user = user
        
        if let postId = notification.postId {
            async let postSnapshot = await FirestoreConstants.PostsCollection.document(postId).getDocument()
            self.notifications[indexOfNotification].post = try? await postSnapshot.data(as: Post.self)
        }
    }
}



enum ActivityFilterViewModel: Int, CaseIterable, Identifiable, Codable {
    case all
    case replies

    var title: String {
        switch self {
        case .all: return "All"
        case .replies: return "Replies"
        }
    }
    
    var id: Int { return self.rawValue }
}
