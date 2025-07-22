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
            
            // Call the API to send verification email
            let response = try await APIService.shared.verifyCollegeEmail(idToken, email: collegeEmail)
            
            if response.success {
                emailVerificationSent = true
                
                // Store the verification code temporarily for development
                // In production, this would be sent via email
                if let verificationCode = response.data?.verificationCode {
                    #if DEBUG
                    print("📧 Verification code (DEBUG ONLY): \(verificationCode)")
                    // Store in UserDefaults for testing purposes
                    UserDefaults.standard.set(verificationCode, forKey: "debug_college_verification_code")
                    #endif
                }
            } else {
                throw OnboardingError.emailVerificationFailed
            }
            
            isVerifyingEmail = false
        } catch {
            isVerifyingEmail = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func confirmCollegeEmail(verificationCode: String) async throws {
        isVerifyingEmail = true
        errorMessage = nil
        
        do {
            guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw OnboardingError.noAuthToken
            }
            
            // Call the API to confirm the verification code
            let updatedUser = try await APIService.shared.confirmCollegeEmail(idToken, verificationCode: verificationCode)
            
            // Update the AuthManager with the new user data
            await MainActor.run {
                AuthManager.shared.currentUser = updatedUser
            }
            
            isCollegeStudent = true
            isVerifyingEmail = false
        } catch {
            isVerifyingEmail = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) async throws -> String {
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
            throw OnboardingError.noAuthToken
        }
        
        do {
            let imageUrl = try await APIService.shared.uploadProfileImage(idToken, image: image)
            
            // Convert relative URL to absolute URL if needed
            if imageUrl.hasPrefix("/") {
                return "\(APIConfig.baseURL)\(imageUrl)"
            }
            
            return imageUrl
        } catch {
            print("Image upload error: \(error)")
            throw OnboardingError.imageUploadFailed
        }
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
    case emailVerificationFailed
    
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
        case .emailVerificationFailed:
            return "Failed to send verification email"
        }
    }
}

