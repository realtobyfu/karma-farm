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
    @State private var username = ""
    @State private var bio = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var isCollegeStudent = false
    @State private var collegeEmail = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Public Profile") {
                    // Profile Picture
                    HStack {
                        Spacer()
                        
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundColor(.gray)
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
                    
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Bio (optional)", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Verification Badges") {
                    Toggle("I'm a college student", isOn: $isCollegeStudent)
                    
                    if isCollegeStudent {
                        TextField("College Email", text: $collegeEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        Text("Use your .edu email to get a verified college badge")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Private Profile (Optional)") {
                    NavigationLink("Set up private profile") {
                        PrivateProfileSetupView()
                    }
                    
                    Text("Your private profile is only shared with users you choose to connect with")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Set Up Profile")
            .navigationBarItems(
                trailing: Button("Done") {
                    saveProfile()
                }
                .disabled(username.isEmpty)
            )
        }
    }
    
    private func saveProfile() {
        Task {
            // API call to save profile
            // Navigate to main app
        }
    }
}
