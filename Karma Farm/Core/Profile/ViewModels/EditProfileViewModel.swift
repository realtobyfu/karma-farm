//
//  EditProfileViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import Foundation
import FirebaseAuth

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var username = ""
    @Published var bio = ""
    @Published var skills: [String] = []
    @Published var interests: [String] = []
    @Published var profileImage: UIImage?
    @Published var isDiscoverable = true
    
    // Private profile
    @Published var realName = ""
    @Published var age = 18
    @Published var gender = "unspecified"
    
    init() {
        loadCurrentProfile()
    }
    
    func loadCurrentProfile() {
        guard let user = AuthManager.shared.currentUser else { return }
        username = user.username
        bio = user.bio ?? ""
        skills = user.skills
        interests = user.interests
        isDiscoverable = user.isDiscoverable
        
        if let privateProfile = user.privateProfile {
            realName = privateProfile.realName ?? ""
            age = privateProfile.age ?? 18
            gender = privateProfile.gender ?? "unspecified"
        }
    }
    
    func saveProfile() async {
        guard let firebaseUser = AuthManager.shared.firebaseUser else { return }
        do {
            let token = try await firebaseUser.getIDToken()
            let profileData: [String: Any] = [
                "username": username,
                "bio": bio,
                "skills": skills,
                "interests": interests,
                "isDiscoverable": isDiscoverable,
                "privateProfile": [
                    "age": age,
                    "gender": gender,
                    "realName": realName
                ]
            ]
            let updatedUser = try await APIService.shared.updateProfile(token, profileData: profileData)
            
            // Update the AuthManager's current user
            await MainActor.run {
                AuthManager.shared.currentUser = updatedUser
            }
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}
