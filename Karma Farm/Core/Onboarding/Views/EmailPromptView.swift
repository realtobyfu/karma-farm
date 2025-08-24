//
//  EmailPromptView.swift
//  Karma Farm
//
//  Created by Assistant on 8/21/25.
//

import SwiftUI

struct EmailPromptView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(.systemGray3))
                }
                .padding()
            }
            
            // Content
            VStack(spacing: 32) {
                // Icon and title
                VStack(spacing: 20) {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    VStack(spacing: 12) {
                        Text("Add Email for Extra Security")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Secure your account with email recovery and get important updates")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                
                // Benefits list
                VStack(alignment: .leading, spacing: 16) {
                    BenefitRow(icon: "key.fill", text: "Recover account if you lose your phone")
                    BenefitRow(icon: "bell.fill", text: "Receive important account notifications")
                    BenefitRow(icon: "graduationcap.fill", text: "Verify college status for badges")
                }
                .padding(.horizontal, 40)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(EmailPromptTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
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
                    
                    Button("Maybe Later") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
        .background(Color(.systemBackground))
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
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to add email. Please try again later."
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

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.purple)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct EmailPromptTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.system(size: 16))
    }
}

#Preview {
    EmailPromptView(isPresented: .constant(true))
        .environmentObject(AuthManager.shared)
}
