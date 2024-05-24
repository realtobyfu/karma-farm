//
//  ContentViewModel.swift
//  Threads
//
//  Created by Tobias Fu on 1/8/24.
//

import Foundation
import Combine
import Firebase

class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
         AuthService.shared.$userSession.sink { [weak self] userSession in
            self?.userSession = userSession
        } .store(in: &cancellables)
        
        
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)

    }
}
