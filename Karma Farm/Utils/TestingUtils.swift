//
//  TestingUtils.swift
//  Karma Farm
//
//  Created by Assistant on 6/17/25.
//

import Foundation
import SwiftUI

// MARK: - Testing Configuration
struct TestingConfig {
    static let useMockData = true
    
    #if DEBUG
    static let enableDebugLogging = true
    #else
    static let enableDebugLogging = false
    #endif
}

// MARK: - Preview Helpers
extension View {
    func withMockAuth() -> some View {
        self.environmentObject(AuthManager.mockAuthenticated as! AuthManager)
    }
    
    func withMockUnauthenticated() -> some View {
        self.environmentObject(AuthManager.mockUnauthenticated as! AuthManager)
    }
}

// MARK: - Mock Data Helpers
struct MockDataProvider {
    static func sampleUsers() -> [User] {
        return User.mockUsers
    }
    
    static func samplePosts() -> [Post] {
        return Post.mockPosts
    }
    
    static func sampleChats() -> [Chat] {
        return Chat.mockChats
    }
    
    static func sampleBadges() -> [Badge] {
        return Badge.mockBadges
    }
}

// MARK: - Testing API Service
class TestAPIService {
    static func configureForTesting() {
        // Any testing-specific configuration
        print("🧪 Test environment configured")
    }
    
    static func resetMockState() {
        // Reset any mock states
        let mockAuth = AuthManager.mockUnauthenticated as! MockAuthManager
        mockAuth.isAuthenticated = false
        mockAuth.currentUser = nil
        mockAuth.errorMessage = nil
        mockAuth.isLoading = false
    }
} 