import Foundation
import SwiftUI
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var unreadCount: Int = 0
    
    private let chatService = ChatService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeUnreadCount()
    }
    
    private func observeUnreadCount() {
        chatService.$unreadCount
            .receive(on: DispatchQueue.main)
            .assign(to: &$unreadCount)
    }
    
    func loadChats() async {
        isLoading = true
        errorMessage = nil
        
        do {
            chats = try await chatService.getUserChats()
        } catch {
            errorMessage = "Failed to load chats: \(error.localizedDescription)"
            print("Error loading chats: \(error)")
        }
        
        isLoading = false
    }
    
    func createChat(for postId: String) async throws -> Chat {
        return try await chatService.createChat(postId: postId)
    }
}
