//
//  PhoneAuthViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//


import Foundation
import Combine
import FirebaseAuth

class PhoneAuthViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    @Published var isVerifying: Bool = false
    @Published var errorMessage: String?
    
    func sendVerificationCode() {
        isVerifying = true
        errorMessage = nil
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                self?.isVerifying = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
        }
    }
    
    func verifyCode() {
        isVerifying = true
        errorMessage = nil
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            self.isVerifying = false
            self.errorMessage = "No verification ID found."
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isVerifying = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                // Handle successful sign in if needed
            }
        }
    }
}
