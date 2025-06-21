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
    @Published var verificationID: String?
    
    func sendVerificationCode(phoneNumber: String) async throws -> String {
        isVerifying = true
        errorMessage = nil
        
        do {
            let verificationID = try await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            
            await MainActor.run {
                self.verificationID = verificationID
                self.isVerifying = false
            }
            
            return verificationID
        } catch {
            await MainActor.run {
                self.isVerifying = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func verifyCode(verificationID: String, code: String) async throws {
        isVerifying = true
        errorMessage = nil
        
        do {
            let credential = PhoneAuthProvider.provider()
                .credential(withVerificationID: verificationID, verificationCode: code)
            
            let _ = try await Auth.auth().signIn(with: credential)
            
            await MainActor.run {
            self.isVerifying = false
            }
        } catch {
            await MainActor.run {
                self.isVerifying = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
}
