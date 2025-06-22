//
//  OnboardingViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Profile data
    @Published var profileData = ProfileSetupData()
    
    // Badge data
    @Published var isCollegeStudent = false
    @Published var collegeEmail = ""
    @Published var isVerifyingEmail = false
    @Published var emailVerificationSent = false
    
    func updateProfile(username: String, bio: String, skills: [String], interests: [String], profileImage: UIImage?) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw OnboardingError.noAuthToken
            }
            
            var profileImageURL: String?
            
            // Upload profile image if provided
            if let image = profileImage {
                profileImageURL = try await uploadProfileImage(image)
            }
            
            let profileData: [String: Any] = [
                "username": username,
                "bio": bio,
                "skills": skills,
                "interests": interests,
                "profilePicture": profileImageURL as Any,
                "isCollegeStudent": isCollegeStudent,
                "collegeEmail": collegeEmail.isEmpty ? nil : collegeEmail
            ]
            
            try await APIService.shared.setupProfile(idToken, profileData: profileData)
            
            // Refetch user data since setupProfile doesn't return it anymore
            try await AuthManager.shared.fetchCurrentUser()
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func verifyCollegeEmail() async throws {
        guard isValidCollegeEmail else {
            throw OnboardingError.invalidCollegeEmail
        }
        
        isVerifyingEmail = true
        errorMessage = nil
        
        do {
            guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw OnboardingError.noAuthToken
            }
            
            // TODO: Implement actual email verification API call
            // For now, simulate the verification process
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            emailVerificationSent = true
            isVerifyingEmail = false
        } catch {
            isVerifyingEmail = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) async throws -> String {
        // TODO: Implement image upload to backend/cloud storage
        // For now, return a placeholder URL
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "https://placeholder.com/profile-image"
    }
    
    var isValidCollegeEmail: Bool {
        collegeEmail.lowercased().hasSuffix(".edu") && collegeEmail.contains("@")
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Data Models
struct ProfileSetupData {
    var username = ""
    var bio = ""
    var skills: [String] = []
    var interests: [String] = []
    var profileImage: UIImage?
}

// MARK: - Errors
enum OnboardingError: LocalizedError {
    case noAuthToken
    case invalidCollegeEmail
    case imageUploadFailed
    case profileUpdateFailed
    
    var errorDescription: String? {
        switch self {
        case .noAuthToken:
            return "Authentication token not available"
        case .invalidCollegeEmail:
            return "Please enter a valid .edu email address"
        case .imageUploadFailed:
            return "Failed to upload profile image"
        case .profileUpdateFailed:
            return "Failed to update profile"
        }
    }
}

