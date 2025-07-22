//
//  BadgeSetupView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct BadgeSetupView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var canProceed: Bool
    let onContinue: () -> Void
    @State private var verificationCode = ""
    @State private var showVerificationInput = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 8) {
                        Text("Earn Badges")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Build trust in the community by verifying your identity")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.top, 40)
                
                // Badge types
                VStack(spacing: 20) {
                    BadgeCard(
                        icon: "graduationcap.fill",
                        title: "College Student",
                        description: "Verify your .edu email to earn this badge",
                        color: .blue,
                        isSelected: viewModel.isCollegeStudent
                    ) {
                        viewModel.isCollegeStudent.toggle()
                        if !viewModel.isCollegeStudent {
                            viewModel.collegeEmail = ""
                            viewModel.emailVerificationSent = false
                        }
                    }
                    
                    if viewModel.isCollegeStudent {
                        VStack(spacing: 12) {
                            TextField("College Email (.edu)", text: $viewModel.collegeEmail)
                                .textFieldStyle(BadgeTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            
                            if !viewModel.emailVerificationSent {
                                Button("Verify Email") {
                                    Task {
                                        do {
                                            try await viewModel.verifyCollegeEmail()
                                        } catch {
                                            print("Email verification error: \(error)")
                                        }
                                    }
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(viewModel.isValidCollegeEmail ? Color.blue : Color.gray)
                                .cornerRadius(8)
                                .disabled(!viewModel.isValidCollegeEmail || viewModel.isVerifyingEmail)
                                .overlay(
                                    Group {
                                        if viewModel.isVerifyingEmail {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        }
                                    }
                                )
                            } else {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Verification email sent!")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                    
                                    if !showVerificationInput {
                                        Button("Enter Verification Code") {
                                            showVerificationInput = true
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                    } else {
                                        VStack(spacing: 8) {
                                            TextField("Verification Code", text: $verificationCode)
                                                .textFieldStyle(BadgeTextFieldStyle())
                                                .autocapitalization(.allCharacters)
                                                .autocorrectionDisabled()
                                            
                                            Button("Confirm") {
                                                Task {
                                                    do {
                                                        try await viewModel.confirmCollegeEmail(verificationCode: verificationCode)
                                                        canProceed = true
                                                    } catch {
                                                        print("Confirmation error: \(error)")
                                                    }
                                                }
                                            }
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 40)
                                            .background(!verificationCode.isEmpty ? Color.blue : Color.gray)
                                            .cornerRadius(8)
                                            .disabled(verificationCode.isEmpty || viewModel.isVerifyingEmail)
                                            
                                            #if DEBUG
                                            if let debugCode = UserDefaults.standard.string(forKey: "debug_college_verification_code") {
                                                Text("Debug Code: \(debugCode)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            #endif
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    
                    BadgeCard(
                        icon: "checkmark.shield.fill",
                        title: "Verified Profile",
                        description: "Complete your profile to earn this badge",
                        color: .green,
                        isSelected: true
                    ) {
                        // Already selected, this is automatic
                    }
                    
                    BadgeCard(
                        icon: "heart.fill",
                        title: "Community Helper",
                        description: "Earn karma by helping others in your community",
                        color: .red,
                        isSelected: false
                    ) {
                        // This is earned through activity
                    }
                }
                
                Text("Don't worry - you can always add more badges later from your profile!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer(minLength: 80)
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
                        onContinue()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
                .background(Color(.systemBackground))
            }
        )
        .onAppear {
            canProceed = true
        }
    }
    

}

struct BadgeCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                }
            }
            .padding()
            .background(isSelected ? Color.purple.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BadgeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.system(size: 16))
    }
}

#Preview {
    BadgeSetupView(canProceed: .constant(true)) {}
}

