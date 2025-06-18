//
//  CreatePostViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import Foundation

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var selectedLocation: String?
    @Published var isCreating = false
    
    func createPost(type: PostType, title: String, description: String, karmaValue: Int, isRequest: Bool) {
        Task {
            isCreating = true
            // Create post via backend
            isCreating = false
        }
    }
}
