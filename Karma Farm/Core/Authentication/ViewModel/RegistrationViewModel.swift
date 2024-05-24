//
//  RegistrationViewModel.swift
//  Threads
//
//  Created by Tobias Fu on 1/7/24.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var fullname = ""

    @MainActor
    // async throws: "The Furure" of API calls
    func createUser() async throws {
        try await AuthService.shared.createUser(
            withEmail: email,
            password: password,
            fullname: fullname,
            username: username
        )
    }
}
 
