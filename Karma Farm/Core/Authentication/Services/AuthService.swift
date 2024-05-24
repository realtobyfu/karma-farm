//
//  AuthService.swift
//  Threads
//
//  Created by Tobias Fu on 1/7/24.
//

import Firebase
import FirebaseFirestoreSwift

class AuthService {
    
    // userSession is a local variable that keeps track of whether someone is
    // logged in, in sync with the F irebase server
    
    // @Published means that when it recevies a value, it is sent to other
    // views in the application
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task { try await UserService.shared.fetchCurrentUser() }
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await UserService.shared.fetchCurrentUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, fullname: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // making sure their document id corresponds to user id
            try await uploadUserData(withEmail: email, fullname: fullname, username: username, id: result.user.uid)
            } catch {
                print("DEBUG: Failed to create user with error \(error.localizedDescription)")
                throw error
            }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            print("DEBUG: Failed to sign out")
        }
    }

    @MainActor
    private func uploadUserData(
        withEmail email: String,
        fullname: String,
        username: String,
        id: String
    )  async throws {
        let user = User(id: id, fullname: fullname, email: email, username: username)
        guard let userData = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(id).setData(userData)
        UserService.shared.currentUser = user
    }
}
