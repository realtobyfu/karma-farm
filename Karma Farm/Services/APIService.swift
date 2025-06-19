//
//  APIService.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import Alamofire
import Firebase
import FirebaseAuth

// MARK: - API Configuration
struct APIConfig {
    #if DEBUG
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "https://your-production-api.com"
    #endif
    
    static let timeout: TimeInterval = 30.0
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct ProfileUpdateRequest: Codable {
    let username: String
    let bio: String?
    let profilePicture: String?
    let isCollegeStudent: Bool?
    let collegeEmail: String?
    let privateProfile: PrivateProfile?
}

struct CreatePostRequest: Codable {
    let type: PostType
    let title: String
    let description: String
    let karmaValue: Int
    let isRequest: Bool
    let location: Location?
    let locationName: String?
    let expiresAt: Date?
}

// MARK: - APIService
class APIService {
    static let shared = APIService()
    
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.timeout
        configuration.timeoutIntervalForResource = APIConfig.timeout
        
        self.session = Session(configuration: configuration)
    }
    
    // MARK: - Generic API Call Method
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        let url = "\(APIConfig.baseURL)\(endpoint)"
        
        #if DEBUG
        print("🌐 API Request: \(method.rawValue) \(url)")
        if let params = parameters {
            print("📋 Parameters: \(params)")
        }
        if let headers = headers {
            print("📄 Headers: \(headers)")
        }
        #endif
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: method == .get ? URLEncoding.default : JSONEncoding.default,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                #if DEBUG
                print("📱 API Response Status: \(response.response?.statusCode ?? 0)")
                if let data = response.data {
                    print("📄 Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8")")
                }
                #endif
                
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    #if DEBUG
                    print("❌ API Error: \(error)")
                    #endif
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    func verifyToken(_ idToken: String) async throws -> AuthResponse {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/auth/verify",
            method: .post,
            headers: headers,
            responseType: AuthResponse.self
        )
    }
    
    func getCurrentUser(_ idToken: String) async throws -> User {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/auth/me",
            method: .get,
            headers: headers,
            responseType: User.self
        )
    }
    
    func setupProfile(_ idToken: String, profileData: [String: Any]) async throws -> User {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/auth/setup-profile",
            method: .post,
            parameters: profileData,
            headers: headers,
            responseType: User.self
        )
    }
    
    // MARK: - Posts Methods
    func getPosts(_ idToken: String, filters: [String: Any]? = nil) async throws -> [Post] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/posts",
            method: .get,
            parameters: filters,
            headers: headers,
            responseType: [Post].self
        )
    }
    
    func createPost(_ idToken: String, postData: [String: Any]) async throws -> Post {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/posts",
            method: .post,
            parameters: postData,
            headers: headers,
            responseType: Post.self
        )
    }
    
    // MARK: - Legacy Methods (for compatibility with existing ViewModels)
    func fetchChats(_ idToken: String) async throws -> [Chat] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/chats",
            method: .get,
            headers: headers,
            responseType: [Chat].self
        )
    }
    
    func fetchPosts(_ idToken: String) async throws -> [Post] {
        return try await getPosts(idToken)
    }
    
    func fetchNearbyPosts(_ idToken: String, latitude: Double, longitude: Double, radius: Double) async throws -> [Post] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
        
        return try await performRequest(
            endpoint: "/posts/nearby",
            method: .get,
            parameters: parameters,
            headers: headers,
            responseType: [Post].self
        )
    }
    
    func updateProfile(_ idToken: String, profileData: [String: Any]) async throws -> User {
        return try await setupProfile(idToken, profileData: profileData)
    }
    
    // MARK: - Network Status
    func checkNetworkStatus() async -> Bool {
        do {
            let _: String = try await performRequest(
                endpoint: "/",
                method: .get,
                responseType: String.self
            )
            return true
        } catch {
            #if DEBUG
            print("❌ Network check failed: \(error)")
            #endif
            return false
        }
    }
}

// MARK: - Mock APIService for Testing
class MockAPIService {
    var shouldSimulateNetworkDelay = true
    var shouldFailAuth = false
    var shouldReturnNewUser = false
    
    private func simulateNetworkDelay() async {
        if shouldSimulateNetworkDelay {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }
    
    func verifyToken(_ idToken: String) async throws -> AuthResponse {
        await simulateNetworkDelay()
        
        if shouldFailAuth {
            throw NSError(domain: "MockAPI", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Invalid token"
            ])
        }
        
        return AuthResponse(
            isNewUser: shouldReturnNewUser,
            user: shouldReturnNewUser ? User.mockUser : User.mockUsers[0]
        )
    }
    
    func getCurrentUser(_ idToken: String) async throws -> User {
        await simulateNetworkDelay()
        return User.mockUser
    }
    
    func setupProfile(_ idToken: String, profileData: [String: Any]) async throws -> User {
        await simulateNetworkDelay()
        var updatedUser = User.mockUser
        // Apply profile updates here if needed
        return updatedUser
    }
    
    func getPosts(_ idToken: String, filters: [String: Any]? = nil) async throws -> [Post] {
        await simulateNetworkDelay()
        return Post.mockPosts
    }
    
    func createPost(_ idToken: String, postData: [String: Any]) async throws -> Post {
        await simulateNetworkDelay()
        return Post.mockPost
    }
    
    func checkNetworkStatus() async -> Bool {
        await simulateNetworkDelay()
        return !shouldFailAuth
    }
    
    // MARK: - Additional Methods for Compatibility
    func fetchChats(_ idToken: String) async throws -> [Chat] {
        await simulateNetworkDelay()
        return Chat.mockChats
    }
    
    func fetchPosts(_ idToken: String) async throws -> [Post] {
        await simulateNetworkDelay()
        return Post.mockPosts
    }
    
    func fetchNearbyPosts(_ idToken: String, latitude: Double, longitude: Double, radius: Double) async throws -> [Post] {
        await simulateNetworkDelay()
        return Post.mockPosts.filter { post in
            // Simple distance filter for mock data
            guard let location = post.location else { return false }
            let distance = sqrt(pow(location.latitude - latitude, 2) + pow(location.longitude - longitude, 2))
            return distance <= radius
        }
    }
    
    func updateProfile(_ idToken: String, profileData: [String: Any]) async throws -> User {
        await simulateNetworkDelay()
        return User.mockUser
    }
}

// MARK: - Testing Configuration
extension MockAPIService {
    static let shared = MockAPIService()
}

enum APIError: Error {
    case notAuthenticated
    case invalidResponse
    case serverError(String)
}
