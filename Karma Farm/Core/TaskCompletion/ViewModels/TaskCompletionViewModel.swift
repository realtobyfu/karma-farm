import Foundation
import SwiftUI
import Combine

@MainActor
class TaskCompletionViewModel: ObservableObject {
    @Published var completionStatus: CompletionStatus = .pending
    @Published var isLoading = false
    @Published var error: String?
    @Published var showRatingView = false
    @Published var selectedRating = 5
    @Published var reviewText = ""
    @Published var selectedTags: Set<HelpfulnessTag> = []
    
    private let apiService = APIService.shared
    private var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    // MARK: - Accept Task
    func acceptTask() async {
        isLoading = true
        error = nil
        
        do {
            // API call to accept task
            try await acceptTaskAPI(postId: post.id)
            completionStatus = .inProgress
            
            // Show success feedback
            await showSuccessHapticFeedback()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Mark Task as Completed
    func markAsCompleted(notes: String? = nil) async {
        isLoading = true
        error = nil
        
        do {
            // API call to mark task as completed
            try await markTaskCompletedAPI(postId: post.id, notes: notes)
            completionStatus = .awaitingConfirmation
            
            await showSuccessHapticFeedback()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Confirm Task Completion (for task owner)
    func confirmCompletion() async {
        isLoading = true
        error = nil
        
        do {
            // API call to confirm completion
            try await confirmTaskCompletionAPI(postId: post.id)
            completionStatus = .confirmed
            showRatingView = true
            
            await showSuccessHapticFeedback()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Submit Rating
    func submitRating() async {
        isLoading = true
        error = nil
        
        do {
            let rating = TaskRating(
                id: UUID().uuidString,
                rating: selectedRating,
                review: reviewText.isEmpty ? nil : reviewText,
                helpfulnessTags: Array(selectedTags),
                createdAt: Date()
            )
            
            // API call to submit rating
            try await submitRatingAPI(postId: post.id, rating: rating)
            
            // Transfer karma if it's a karma task
            if post.taskType == .karma {
                try await transferKarmaAPI(
                    fromUserId: post.isRequest ? post.userId : post.completedByUserId ?? "",
                    toUserId: post.isRequest ? post.completedByUserId ?? "" : post.userId,
                    amount: post.karmaValue
                )
            }
            
            await showSuccessHapticFeedback()
            showRatingView = false
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - API Calls (Mock implementations)
    private func acceptTaskAPI(postId: String) async throws {
        // In real implementation, this would call the backend
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
    }
    
    private func markTaskCompletedAPI(postId: String, notes: String?) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private func confirmTaskCompletionAPI(postId: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private func submitRatingAPI(postId: String, rating: TaskRating) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private func transferKarmaAPI(fromUserId: String, toUserId: String, amount: Int) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    // MARK: - Helpers
    private func showSuccessHapticFeedback() async {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
}

// MARK: - Task Progress Tracking
extension TaskCompletionViewModel {
    var progressDescription: String {
        switch completionStatus {
        case .pending:
            return "Task available for acceptance"
        case .inProgress:
            return "Task is being completed"
        case .awaitingConfirmation:
            return "Waiting for task owner to confirm completion"
        case .confirmed:
            return "Task completed successfully"
        case .disputed:
            return "Task completion is disputed"
        }
    }
    
    var canAcceptTask: Bool {
        completionStatus == .pending && !post.isCurrentUserPost
    }
    
    var canMarkCompleted: Bool {
        completionStatus == .inProgress && post.completedByUserId == AuthManager.shared.currentUser?.id
    }
    
    var canConfirmCompletion: Bool {
        completionStatus == .awaitingConfirmation && post.isCurrentUserPost
    }
}