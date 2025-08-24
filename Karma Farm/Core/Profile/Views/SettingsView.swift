//
//  SettingsView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 7/13/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showingPrivacySettings = false
    @State private var showingDeleteAccount = false
    @State private var showingAddEmail = false
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section("Account") {
                    HStack {
                        Label("Phone Number", systemImage: "phone")
                        Spacer()
                        Text(authManager.currentUser?.phoneNumber ?? "")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    // Email row - shows add or current email
                    if let email = authManager.currentUser?.email, !email.isEmpty {
                        HStack {
                            Label("Email", systemImage: "envelope")
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(email)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .font(.system(size: 14))
                                if !(authManager.currentUser?.isEmailVerified ?? false) {
                                    Text("Not verified")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    } else {
                        Button(action: { showingAddEmail = true }) {
                            HStack {
                                Label("Add Email for Recovery", systemImage: "envelope.badge.shield.half.filled")
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.purple)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Privacy Settings", systemImage: "lock")
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle(isOn: .constant(true)) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    
                    Toggle(isOn: .constant(true)) {
                        Label("Message Notifications", systemImage: "message")
                    }
                    
                    Toggle(isOn: .constant(true)) {
                        Label("Post Updates", systemImage: "doc.text")
                    }
                }
                
                // Support Section
                Section("Support") {
                    Link(destination: URL(string: "mailto:support@karmafarm.app")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    
                    Link(destination: URL(string: "https://karmafarm.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    Link(destination: URL(string: "https://karmafarm.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showingDeleteAccount = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEmail) {
            AddEmailView()
        }
        .alert("Delete Account", isPresented: $showingDeleteAccount) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // TODO: Implement account deletion
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager.shared)
}