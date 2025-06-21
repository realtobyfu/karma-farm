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
        print("🔥 AuthManager: Starting phone verification for: \(phoneNumber)")
        
        // Check if Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("🔥 ERROR: Firebase is not configured!")
            throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured"])
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            print("🔥 AuthManager: Calling Firebase PhoneAuthProvider")
            let verificationID = try await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            print("🔥 AuthManager: Firebase returned verification ID: \(verificationID)")
            
            await MainActor.run {
                isLoading = false
            }
            return verificationID
        } catch {
            print("🔥 AuthManager ERROR: \(error)")
            if let nsError = error as NSError? {
                print("🔥 AuthManager ERROR Details: Domain: \(nsError.domain), Code: \(nsError.code), UserInfo: \(nsError.userInfo)")
            }
            
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
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
        Task {
            do {
                guard let firebaseUser = Auth.auth().currentUser else { return }
                let idToken = try await firebaseUser.getIDToken()
                guard let url = URL(string: "\(APIConfig.baseURL)/auth/me") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
                let (data, _) = try await URLSession.shared.data(for: request)
                let fetchedUser = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.currentUser = fetchedUser
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Mock AuthManager for Testing and Previews
class MockAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(isAuthenticated: Bool = false, currentUser: User? = nil) {
        self.isAuthenticated = isAuthenticated
        self.currentUser = currentUser
    }
    
    func startPhoneVerification(phoneNumber: String) async throws -> String {
        isLoading = true
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        return "mock-verification-id"
    }
    
    func verifyCode(verificationID: String, code: String) async throws {
        isLoading = true
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        if code == "123456" {
            // Success case
            currentUser = User.mockUser
            isAuthenticated = true
            isLoading = false
        } else {
            // Error case
            isLoading = false
            errorMessage = "Invalid verification code. Please try again."
            throw NSError(domain: "MockAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
    }
}

// MARK: - Preview Helper
extension AuthManager {
    static let mockAuthenticated = MockAuthManager(isAuthenticated: true, currentUser: User.mockUser)
    static let mockUnauthenticated = MockAuthManager(isAuthenticated: false, currentUser: nil)
}
