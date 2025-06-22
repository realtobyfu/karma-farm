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
            try await APIService.shared.updateProfile(token, profileData: profileData)
            // After updating, fetch the latest user profile
            do {
                let currentUser = try await APIService.shared.getCurrentUser(token)
                await MainActor.run {
                    AuthManager.shared.currentUser = currentUser
                }
            } catch {
                print("Failed to fetch current user: \(error)")
            }
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}

