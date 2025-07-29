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
        updateCompletionStatus()
    }
    
    // MARK: - Accept Task
    func acceptTask() async {
        isLoading = true
        error = nil
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            // API call to accept task
            post = try await apiService.acceptPost(idToken, postId: post.id)
            updateCompletionStatus()
            
            // Show success feedback
            await showSuccessHapticFeedback()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Mark Task as Completed
    func markAsCompleted(notes: String? = nil, actualTimeMinutes: Int? = nil, adjustedKarma: Int? = nil) async {
        isLoading = true
        error = nil
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            // API call to mark task as completed
            // TODO: Update API to handle actualTimeMinutes and adjustedKarma
            post = try await apiService.completePost(idToken, postId: post.id)
            updateCompletionStatus()
            
            // Store the time tracking data for future use
            if let actualTime = actualTimeMinutes {
                UserDefaults.standard.set(actualTime, forKey: "task_\(post.id)_actualTime")
            }
            if let karma = adjustedKarma {
                UserDefaults.standard.set(karma, forKey: "task_\(post.id)_adjustedKarma")
            }
            
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
            // Task completion is confirmed automatically when marked as completed
            // Just update the status and show rating view
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
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            // API call to submit rating
            // The backend handles karma transfer automatically
            post = try await apiService.rateCompletedTask(
                idToken,
                postId: post.id,
                rating: selectedRating,
                review: reviewText.isEmpty ? nil : reviewText
            )
            
            await showSuccessHapticFeedback()
            showRatingView = false
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    
    // MARK: - Helpers
    private func updateCompletionStatus() {
        // Update completion status based on post data
        switch post.status {
        case .active:
            if post.acceptedByUserId != nil {
                completionStatus = .inProgress
            } else {
                completionStatus = .pending
            }
        case .completed:
            if post.ratedByUserId != nil {
                completionStatus = .confirmed
            } else {
                completionStatus = .awaitingConfirmation
            }
        case .cancelled:
            completionStatus = .pending
        }
    }
    
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