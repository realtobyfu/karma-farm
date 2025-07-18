//
//  CreatePostViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import Foundation
import CoreLocation
import FirebaseAuth

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func createPost(
        title: String,
        description: String,
        type: PostType,
        category: PostCategory,
        rewardType: RewardType = .karma,
        karmaValue: Int? = nil,
        paymentAmount: Double? = nil,
        location: CLLocation?,
        locationName: String,
        expiresAt: Date?
    ) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw CreatePostError.noAuthToken
            }
            
            var postData: [String: Any] = [
                "title": title,
                "description": description,
                "type": type.rawValue,
                "category": category.rawValue,
                "rewardType": rewardType.rawValue,
                "locationName": locationName
            ]
            
            if let karmaValue = karmaValue {
                postData["karmaValue"] = karmaValue
            }
            
            if let paymentAmount = paymentAmount {
                postData["paymentAmount"] = paymentAmount
            }
            
            if let location = location {
                postData["location"] = [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                ]
            }
            
            if let expiresAt = expiresAt {
                let formatter = ISO8601DateFormatter()
                postData["expiresAt"] = formatter.string(from: expiresAt)
            }
            
            let newPost = try await APIService.shared.createPost(idToken, postData: postData)
            
            // Notify other parts of the app that a new post was created
            NotificationCenter.default.post(name: .newPostCreated, object: newPost)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
}

// MARK: - Errors
enum CreatePostError: LocalizedError {
    case noAuthToken
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noAuthToken:
            return "Authentication token not available"
        case .invalidData:
            return "Invalid post data"
        case .networkError:
            return "Network error occurred"
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let newPostCreated = Notification.Name("newPostCreated")
}
