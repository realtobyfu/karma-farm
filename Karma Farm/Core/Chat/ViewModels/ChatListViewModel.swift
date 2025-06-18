//
//  ChatListViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import SwiftUICore

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    
    init() {
        Task {
            await fetchChats()
        }
    }
    
    func fetchChats() async {
        // TODO: Fetch chats from backend
    }
}
