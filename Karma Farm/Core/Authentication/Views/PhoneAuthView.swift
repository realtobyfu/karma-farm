//
//  PhoneAuthView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct PhoneAuthView: View {
    @StateObject private var viewModel = PhoneAuthViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var verificationID: String?
    @State private var showVerificationField = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo
                Image("karma_logo") // Add your logo to Assets
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                Text("Welcome to Karma Farm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connect, Share, and Build Community")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 20) {
                    // Phone Number Input
                    HStack {
                        Text("+1")
                            .foregroundColor(.secondary)
                        
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    if showVerificationField {
                        TextField("Verification Code", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    // Action Button
                    Button(action: {
                        if showVerificationField {
                            verifyCode()
                        } else {
                            sendVerificationCode()
                        }
                    }) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(showVerificationField ? "Verify Code" : "Send Code")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(authManager.isLoading || phoneNumber.isEmpty)
                    .padding(.horizontal)
                    
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Terms and Privacy
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func sendVerificationCode() {
        let fullPhoneNumber = "+1\(phoneNumber)"
        
        Task {
            do {
                verificationID = try await authManager.startPhoneVerification(phoneNumber: fullPhoneNumber)
                withAnimation {
                    showVerificationField = true
                }
            } catch {
                print("Error sending verification code: \(error)")
            }
        }
    }
    
    private func verifyCode() {
        guard let verificationID = verificationID else { return }
        
        Task {
            do {
                try await authManager.verifyCode(verificationID: verificationID, code: verificationCode)
            } catch {
                print("Error verifying code: \(error)")
            }
        }
    }
}
