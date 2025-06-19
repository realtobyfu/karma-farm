//
//  ChatListViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    
    init() {
        Task {
            await fetchChats()
        }
    }
    
    func fetchChats() async {
        do {
            // Get current user's auth token
            guard let user = AuthManager.shared.firebaseUser else {
                print("No authenticated user")
                return
            }
            let token = try await user.getIDToken()
            let chats = try await APIService.shared.fetchChats(token)
            self.chats = chats
        } catch {
            print("Failed to fetch chats: \(error)")
            // Use mock data for now
            self.chats = Chat.mockChats
        }
    }
}
