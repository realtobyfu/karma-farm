//
//  ProfileSetupView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var canProceed: Bool
    let onContinue: () -> Void
    
    @State private var username = ""
    @State private var bio = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var skills: [String] = []
    @State private var interests: [String] = []
    @State private var newSkill = ""
    @State private var newInterest = ""
    
    private let suggestedSkills = ["iOS Development", "Cooking", "Tutoring", "Photography", "Writing", "Design", "Music", "Sports", "Gardening", "Car Repair"]
    private let suggestedInterests = ["Technology", "Food", "Travel", "Music", "Sports", "Art", "Books", "Gaming", "Fitness", "Movies"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Set Up Your Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Help others get to know you better")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                VStack(spacing: 20) {
                    // Profile Picture Section
                    VStack(spacing: 16) {
                        Text("Profile Picture")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Spacer()
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                if let profileImage = profileImage {
                                    profileImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.purple, lineWidth: 3)
                                        )
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Color(.systemGray5))
                                            .frame(width: 120, height: 120)
                                        
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.purple)
                                            
                                            Text("Add Photo")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.purple)
                                        }
                                    }
                                }
                            }
                            .onChange(of: selectedImage) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Basic Info Section
                    VStack(spacing: 16) {
                        Text("Basic Information")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Username", text: $username)
                            .textFieldStyle(OnboardingTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        TextField("Bio (optional)", text: $bio, axis: .vertical)
                            .textFieldStyle(OnboardingTextFieldStyle())
                            .lineLimit(2...4)
                    }
                    
                    // Skills Section
                    VStack(spacing: 16) {
                        Text("Your Skills")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("What can you help others with?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Add skill field
                        HStack {
                            TextField("Add a skill", text: $newSkill)
                                .textFieldStyle(OnboardingTextFieldStyle())
                            
                            Button("Add") {
                                addSkill()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(newSkill.isEmpty ? Color.gray : Color.purple)
                            .cornerRadius(8)
                            .disabled(newSkill.isEmpty)
                        }
                        
                        // Selected skills
                        if !skills.isEmpty {
                            TagView(tags: skills) { skill in
                                removeSkill(skill)
                            }
                        }
                        
                        // Suggested skills
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TagView(tags: suggestedSkills.filter { !skills.contains($0) }, isSelectable: true) { skill in
                                skills.append(skill)
                                updateCanProceed()
                            }
                        }
                    }
                    
                    // Interests Section
                    VStack(spacing: 16) {
                        Text("Your Interests")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("What are you passionate about?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Add interest field
                        HStack {
                            TextField("Add an interest", text: $newInterest)
                                .textFieldStyle(OnboardingTextFieldStyle())
                            
                            Button("Add") {
                                addInterest()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(newInterest.isEmpty ? Color.gray : Color.purple)
                            .cornerRadius(8)
                            .disabled(newInterest.isEmpty)
                        }
                        
                        // Selected interests
                        if !interests.isEmpty {
                            TagView(tags: interests) { interest in
                                removeInterest(interest)
                            }
                        }
                        
                        // Suggested interests
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TagView(tags: suggestedInterests.filter { !interests.contains($0) }, isSelectable: true) { interest in
                                interests.append(interest)
                                updateCanProceed()
                            }
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .overlay(
            // Continue button overlay
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Divider()
                    
                    Button("Continue") {
                        saveProfile()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canProceed ? Color.purple : Color.gray)
                    .cornerRadius(12)
                    .disabled(!canProceed)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
                .background(Color(.systemBackground))
            }
        )
        .onChange(of: username) { _ in updateCanProceed() }
        .onAppear {
            updateCanProceed()
        }
    }
    
    private func updateCanProceed() {
        canProceed = !username.isEmpty
    }
    
    private func addSkill() {
        guard !newSkill.isEmpty && !skills.contains(newSkill) else { return }
        skills.append(newSkill)
        newSkill = ""
        updateCanProceed()
    }
    
    private func removeSkill(_ skill: String) {
        skills.removeAll { $0 == skill }
        updateCanProceed()
    }
    
    private func addInterest() {
        guard !newInterest.isEmpty && !interests.contains(newInterest) else { return }
        interests.append(newInterest)
        newInterest = ""
        updateCanProceed()
    }
    
    private func removeInterest(_ interest: String) {
        interests.removeAll { $0 == interest }
        updateCanProceed()
    }
    
    private func saveProfile() {
        Task {
            // TODO: API call to save profile
            // For now, just continue to next step
            onContinue()
        }
    }
}

struct TagView: View {
    let tags: [String]
    let isSelectable: Bool
    let onAction: (String) -> Void
    
    init(tags: [String], isSelectable: Bool = false, onAction: @escaping (String) -> Void) {
        self.tags = tags
        self.isSelectable = isSelectable
        self.onAction = onAction
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100), spacing: 8)
        ], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Button(action: { onAction(tag) }) {
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.system(size: 14))
                            .foregroundColor(isSelectable ? .purple : .primary)
                        
                        if !isSelectable {
                            Image(systemName: "xmark")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSelectable ? Color.purple.opacity(0.1) : Color(.systemGray5))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelectable ? Color.purple : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.system(size: 16))
    }
}
#Preview {
    ProfileSetupView(canProceed: .constant(true)) {}
        .environmentObject(AuthManager.shared)
}
