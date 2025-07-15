//
//  PrivacySettingsView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 7/13/25.
//

import SwiftUI

struct PrivacySettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isPrivateProfile: Bool = false
    @State private var showKarmaBalance: Bool = true
    @State private var showPosts: Bool = true
    @State private var showBadges: Bool = true
    @State private var showProfilePhoto: Bool = true
    @State private var allowDirectMessages: Bool = true
    @State private var connectionsOnly: Bool = false
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Private Profile", isOn: $isPrivateProfile)
                    
                    Text("Private profiles hide most information from non-connections")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                } header: {
                    Text("Profile Visibility")
                }
                
                Section {
                    Toggle("Show Karma Balance", isOn: $showKarmaBalance)
                        .disabled(!isPrivateProfile)
                    
                    Toggle("Show Posts", isOn: $showPosts)
                        .disabled(!isPrivateProfile)
                    
                    Toggle("Show Badges", isOn: $showBadges)
                        .disabled(!isPrivateProfile)
                    
                    Toggle("Show Profile Photo", isOn: $showProfilePhoto)
                        .disabled(!isPrivateProfile)
                } header: {
                    Text("Information Visible to Non-Connections")
                } footer: {
                    Text("These settings only apply when your profile is private")
                        .font(DesignSystem.Typography.caption)
                }
                
                Section {
                    Toggle("Allow Direct Messages", isOn: $allowDirectMessages)
                    
                    Toggle("Connections Only", isOn: $connectionsOnly)
                        .disabled(!allowDirectMessages)
                } header: {
                    Text("Messaging")
                } footer: {
                    Text("Control who can send you messages")
                        .font(DesignSystem.Typography.caption)
                }
                
                Section {
                    HStack {
                        Text("Preview Profile")
                        Spacer()
                        NavigationLink(destination: ProfilePreviewView(isPrivate: isPrivateProfile)) {
                            Text("View")
                                .font(DesignSystem.Typography.footnote)
                        }
                    }
                } footer: {
                    Text("See how your profile appears to others")
                        .font(DesignSystem.Typography.caption)
                }
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .disabled(isLoading)
                }
            }
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }
    
    private func loadCurrentSettings() {
        guard let user = authManager.currentUser else { return }
        
        isPrivateProfile = user.isPrivateProfile
        
        if let settings = user.privacySettings {
            showKarmaBalance = settings.showKarmaBalance
            showPosts = settings.showPosts
            showBadges = settings.showBadges
            showProfilePhoto = settings.showProfilePhoto
            allowDirectMessages = settings.allowDirectMessages
            connectionsOnly = settings.connectionsOnly
        }
    }
    
    private func saveSettings() {
        isLoading = true
        
        let settings = PrivacySettingsUpdateRequest(
            isPrivateProfile: isPrivateProfile,
            privacySettings: PrivacySettings(
                showKarmaBalance: showKarmaBalance,
                showPosts: showPosts,
                showBadges: showBadges,
                showProfilePhoto: showProfilePhoto,
                allowDirectMessages: allowDirectMessages,
                connectionsOnly: connectionsOnly
            )
        )
        
        Task {
            do {
                try await APIService.shared.updatePrivacySettings(settings)
                try await authManager.fetchCurrentUser()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isLoading = false
        }
    }
}

struct ProfilePreviewView: View {
    let isPrivate: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Profile Preview")
                .font(DesignSystem.Typography.title2)
            
            if isPrivate {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Private Profile")
                        .font(DesignSystem.Typography.title3)
                    
                    Text("Only your username and verification status are visible to non-connections")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                Text("Your full profile is visible to everyone")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PrivacySettingsView()
        .environmentObject(AuthManager.shared)
}