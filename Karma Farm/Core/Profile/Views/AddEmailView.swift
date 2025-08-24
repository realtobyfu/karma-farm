//
//  AddEmailView.swift
//  Karma Farm
//
//  Created by Assistant on 8/21/25.
//

import SwiftUI

struct AddEmailView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 24) {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                        .padding(.top, 40)
                    
                    VStack(spacing: 12) {
                        Text("Add Email for Account Recovery")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Adding an email helps you recover your account if you lose access to your phone. You'll also receive important updates about your account.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                
                Spacer()
                
                // Form
                VStack(spacing: 16) {
                    // Email field
                    TextField("Email", text: $email)
                        .textFieldStyle(AddEmailTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    // Password field
                    HStack {
                        if showPassword {
                            TextField("Create Password", text: $password)
                                .textContentType(.newPassword)
                        } else {
                            SecureField("Create Password", text: $password)
                                .textContentType(.newPassword)
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Info text
                    Text("Create a password to use if you ever need to sign in with email")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: addEmail) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Add Email")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isValidForm ? Color.purple : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isValidForm || isLoading)
                    
                    Button("Skip for Now") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .alert("Email Added Successfully", isPresented: $showSuccessMessage) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your email has been added to your account. We'll send you a verification link shortly.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidForm: Bool {
        isValidEmail(email) && password.count >= 8
    }
    
    // MARK: - Actions
    
    private func addEmail() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Update email in Firebase Auth
                try await authManager.firebaseUser?.updateEmail(to: email)
                
                // Send verification email
                try await authManager.firebaseUser?.sendEmailVerification()
                
                // Update password
                try await authManager.firebaseUser?.updatePassword(to: password)
                
                // Update backend
                try await authManager.updateUserEmail(email: email)
                
                await MainActor.run {
                    isLoading = false
                    showSuccessMessage = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct AddEmailTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.system(size: 16))
    }
}

#Preview {
    AddEmailView()
        .environmentObject(AuthManager.shared)
}