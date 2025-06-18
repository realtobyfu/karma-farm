//
//  EditProfileViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import Foundation

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
    
    func saveProfile() {
        // TODO: Save profile changes to backend
    }
}
