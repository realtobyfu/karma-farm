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

// MARK: - Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}

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
    
    // MARK: - Email Authentication
    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update user profile with display name
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = "\(firstName) \(lastName)"
            try await changeRequest.commitChanges()
            
            // Send email verification
            try await authResult.user.sendEmailVerification()
            
            // Get ID token for backend
            let idToken = try await authResult.user.getIDToken()
            
            // Setup profile with backend
            try await setupUserProfile(idToken: idToken, firstName: firstName, lastName: lastName)
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Get ID token for backend
            let idToken = try await authResult.user.getIDToken()
            
            // Verify with backend
            try await verifyWithBackend(idToken: idToken)
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func resendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await user.sendEmailVerification()
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            throw error
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
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(AuthResponse.self, from: data)
        
        await MainActor.run {
            if response.isNewUser {
                // Navigate to profile setup
                self.currentUser = response.user
            } else {
                self.currentUser = response.user
            }
        }
    }
    
    private func setupUserProfile(idToken: String, firstName: String, lastName: String) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)/auth/setup") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let profileData = [
            "firstName": firstName,
            "lastName": lastName
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: profileData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let user = try decoder.decode(User.self, from: data)
        
        await MainActor.run {
            self.currentUser = user
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
        }
    }
    
    // MARK: - User Profile
    func getIDToken() async -> String? {
        return try? await Auth.auth().currentUser?.getIDToken()
    }
    
    func fetchCurrentUser() async throws {
        guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else {
            throw NSError(domain: "AuthManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not get auth token."])
        }
        
        let user = try await APIService.shared.getCurrentUser(idToken)
        
        await MainActor.run {
            self.currentUser = user
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
        }
    }
    
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let fetchedUser = try decoder.decode(User.self, from: data)
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
            errorMessage = "Invalid verification code"
            throw NSError(domain: "MockAuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])
        }
    }
    
    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) async throws {
        isLoading = true
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Mock success
        currentUser = User.mockUser
        isAuthenticated = true
        isLoading = false
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        if email == "test@example.com" && password == "password" {
            // Success case
            currentUser = User.mockUser
            isAuthenticated = true
            isLoading = false
        } else {
            // Error case
            isLoading = false
            errorMessage = "Invalid email or password"
            throw NSError(domain: "MockAuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password"])
        }
    }
    
    func resendEmailVerification() async throws {
        isLoading = true
        try await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
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
