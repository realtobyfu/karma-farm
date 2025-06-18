//
//  AuthManager.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation
import FirebaseAuth
import Firebase
import Combine

struct AuthResponse: Codable {
    let isNewUser: Bool
    let user: User
}

// Add this typealias if you need to reference the Firebase user object
// typealias FirebaseUser = FirebaseAuth.User

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
            self?.isAuthenticated = user != nil
            
            if user != nil {
                self?.fetchUserProfile()
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    // MARK: - Phone Authentication
    func startPhoneVerification(phoneNumber: String) async throws -> String {
        isLoading = true
        errorMessage = nil
        
        do {
            let verificationID = try await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            isLoading = false
            return verificationID
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func verifyCode(verificationID: String, code: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let credential = PhoneAuthProvider.provider()
                .credential(withVerificationID: verificationID, verificationCode: code)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Get ID token for backend
            let idToken = try await authResult.user.getIDToken()
            
            // Verify with backend
            try await verifyWithBackend(idToken: idToken)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Backend Communication
    private func verifyWithBackend(idToken: String) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/auth/verify") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        if response.isNewUser {
            // Navigate to profile setup
            self.currentUser = response.user
        } else {
            self.currentUser = response.user
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func fetchUserProfile() {
        // TODO: Implement logic to fetch the user profile from your backend or local storage
    }
}
