//
//  LoginViewModel.swift
//  Threads
//
//  Created by Tobias Fu on 1/9/24.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    @MainActor
    // async throws: "The Furure" of API calls
    func login() async throws {
        try await AuthService.shared.login(withEmail: email, password: password)
    }
}
