//
//  BadgeSetupView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct BadgeSetupView: View {
    @Binding var canProceed: Bool
    let onContinue: () -> Void
    
    @State private var isCollegeStudent = false
    @State private var collegeEmail = ""
    @State private var isVerifyingEmail = false
    @State private var showVerificationSent = false
    
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
                        isSelected: isCollegeStudent
                    ) {
                        isCollegeStudent.toggle()
                        if !isCollegeStudent {
                            collegeEmail = ""
                            showVerificationSent = false
                        }
                    }
                    
                    if isCollegeStudent {
                        VStack(spacing: 12) {
                            TextField("College Email (.edu)", text: $collegeEmail)
                                .textFieldStyle(BadgeTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            
                            if !showVerificationSent {
                                Button("Verify Email") {
                                    verifyCollegeEmail()
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(isValidCollegeEmail ? Color.blue : Color.gray)
                                .cornerRadius(8)
                                .disabled(!isValidCollegeEmail || isVerifyingEmail)
                                .overlay(
                                    Group {
                                        if isVerifyingEmail {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        }
                                    }
                                )
                            } else {
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
    
    private var isValidCollegeEmail: Bool {
        collegeEmail.lowercased().hasSuffix(".edu") && collegeEmail.contains("@")
    }
    
    private func verifyCollegeEmail() {
        isVerifyingEmail = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isVerifyingEmail = false
            showVerificationSent = true
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
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .font(.system(size: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    BadgeSetupView(canProceed: .constant(true)) {}
}

