//
//  APIService.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation
import UIKit
import Alamofire
import Firebase
import FirebaseAuth

// MARK: - API Configuration
struct APIConfig {
    #if DEBUG
    static let baseURL = "http://127.0.0.1:3000"
    #else
    static let baseURL = "http://127.0.0.1:3000"
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
    let category: PostCategory
    let title: String
    let description: String
    let karmaValue: Int?
    let paymentAmount: Double?
    let location: Location?
    let locationName: String?
    let expiresAt: Date?
}

struct EmptyResponse: Codable {}

struct PrivacySettingsResponse: Codable {
    let isPrivateProfile: Bool
    let settings: PrivacySettings
}

struct PrivacySettingsUpdateRequest: Codable {
    let isPrivateProfile: Bool
    let privacySettings: PrivacySettings
}

struct CollegeEmailVerificationResponse: Codable {
    let success: Bool
    let message: String
    let data: VerificationData?
}

struct VerificationData: Codable {
    let verificationCode: String
}

struct UploadResponse: Codable {
    let success: Bool
    let data: UploadData?
}

struct UploadData: Codable {
    let url: String
    let filename: String
    let size: Int
    let mimetype: String
}

// MARK: - APIError
enum APIError: LocalizedError {
    case notAuthenticated
    case invalidData
    case uploadFailed
    case networkError(String)
    case decodingError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidData:
            return "Invalid data provided"
        case .uploadFailed:
            return "Failed to upload file"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - APIService
actor APIService {
    static let shared = APIService()

    private let session: Session
    private let sessionQueue = DispatchQueue(label: "APIService.sessionQueue", qos: .userInitiated)

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
            // Use ISO8601 decoder with fractional seconds for Date fields
            let decoder = JSONDecoder()
            // Convert snake_case keys from backend to camelCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                if let date = isoFormatter.date(from: dateStr) {
                    return date
                }
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateStr)")
            }

            // Perform network request on dedicated queue to avoid actor isolation issues
            let session = self.session
            self.sessionQueue.async {
                session.request(
                    url,
                    method: method,
                    parameters: parameters,
                    encoding: method == .get ? URLEncoding.default : JSONEncoding.default,
                    headers: headers
                )
                .validate()
                .responseDecodable(of: T.self, decoder: decoder) { response in
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
    }
    
    // MARK: - Public API Call Method
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Codable? = nil,
        parameters: [String: Any]? = nil,
        responseType: T.Type
    ) async throws -> T {
        // Get the current user's ID token
        guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.notAuthenticated
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        // Convert body to parameters if provided
        var finalParameters = parameters
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(body),
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                finalParameters = json
            }
        }
        
        return try await performRequest(
            endpoint: endpoint,
            method: method,
            parameters: finalParameters,
            headers: headers,
            responseType: responseType
        )
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
    
    func setupProfile(_ idToken: String, profileData: [String: Any]) async throws {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        try await performRequestEmptyResponse(
            endpoint: "/auth/setup-profile",
            method: .post,
            parameters: profileData,
            headers: headers
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
    
    func fetchPosts(_ idToken: String, parameters: [String: Any] = [:]) async throws -> [Post] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/posts",
            method: .get,
            parameters: parameters,
            headers: headers,
            responseType: [Post].self
        )
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
    
    func updateProfile(_ idToken: String, profileData: [String: Any]) async throws {
        try await setupProfile(idToken, profileData: profileData)
    }
    
    // MARK: - College Email Verification
    func verifyCollegeEmail(_ idToken: String, email: String) async throws -> CollegeEmailVerificationResponse {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "email": email
        ]
        
        return try await performRequest(
            endpoint: "/users/verify-college-email",
            method: .post,
            parameters: parameters,
            headers: headers,
            responseType: CollegeEmailVerificationResponse.self
        )
    }
    
    func confirmCollegeEmail(_ idToken: String, verificationCode: String) async throws -> User {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "verificationCode": verificationCode
        ]
        
        return try await performRequest(
            endpoint: "/users/confirm-college-email",
            method: .post,
            parameters: parameters,
            headers: headers,
            responseType: User.self
        )
    }
    
    // MARK: - Privacy Settings
    func getPrivacySettings() async throws -> PrivacySettingsResponse {
        guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.notAuthenticated
        }
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(idToken)")
        
        return try await performRequest(
            endpoint: "/privacy/settings",
            method: .get,
            headers: headers,
            responseType: PrivacySettingsResponse.self
        )
    }
    
    func updatePrivacySettings(_ settings: PrivacySettingsUpdateRequest) async throws {
        guard let idToken = try? await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.notAuthenticated
        }
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(idToken)")
        headers.add(name: "Content-Type", value: "application/json")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(settings)
        let parameters = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        let _: EmptyResponse = try await performRequest(
            endpoint: "/privacy/settings",
            method: .put,
            parameters: parameters,
            headers: headers,
            responseType: EmptyResponse.self
        )
    }
    
    // MARK: - Image Upload
    func uploadProfileImage(_ idToken: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidData
        }
        
        let url = "\(APIConfig.baseURL)/upload/profile-image"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            // Create decoder with snake_case conversion
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData,
                        withName: "image",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg"
                    )
                },
                to: url,
                headers: headers
            )
            .responseDecodable(of: UploadResponse.self, decoder: decoder) { response in
                switch response.result {
                case .success(let uploadResponse):
                    if uploadResponse.success, let imageUrl = uploadResponse.data?.url {
                        continuation.resume(returning: imageUrl)
                    } else {
                        continuation.resume(throwing: APIError.uploadFailed)
                    }
                case .failure(let error):
                    #if DEBUG
                    print("❌ Upload error: \(error)")
                    #endif
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Task Completion
    func acceptPost(_ idToken: String, postId: String) async throws -> Post {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/posts/\(postId)/accept",
            method: .post,
            headers: headers,
            responseType: Post.self
        )
    }
    
    func completePost(_ idToken: String, postId: String) async throws -> Post {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/posts/\(postId)/complete",
            method: .post,
            headers: headers,
            responseType: Post.self
        )
    }
    
    func rateCompletedTask(_ idToken: String, postId: String, rating: Int, review: String?) async throws -> Post {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "rating": rating,
            "review": review ?? ""
        ]
        
        return try await performRequest(
            endpoint: "/posts/\(postId)/rate",
            method: .post,
            parameters: parameters,
            headers: headers,
            responseType: Post.self
        )
    }
    
    // MARK: - Karma Transactions
    func getKarmaTransactions(_ idToken: String, limit: Int = 100) async throws -> [KarmaTransaction] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "limit": limit
        ]
        
        return try await performRequest(
            endpoint: "/karma/transactions",
            method: .get,
            parameters: parameters,
            headers: headers,
            responseType: [KarmaTransaction].self
        )
    }
    
    // MARK: - Connections
    /*
    func sendConnectionRequest(_ idToken: String, request: ConnectionRequest) async throws -> Connection {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "toUserId": request.toUserId,
            "message": request.message ?? ""
        ]
        
        return try await performRequest(
            endpoint: "/connections/request",
            method: .post,
            parameters: parameters,
            headers: headers,
            responseType: Connection.self
        )
    }
    */
    
    /*
    func acceptConnectionRequest(_ idToken: String, connectionId: String) async throws -> Connection {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/connections/\(connectionId)/accept",
            method: .put,
            headers: headers,
            responseType: Connection.self
        )
    }
    */
    
    /*
    func declineConnectionRequest(_ idToken: String, connectionId: String) async throws -> Connection {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/connections/\(connectionId)/decline",
            method: .put,
            headers: headers,
            responseType: Connection.self
        )
    }
    */
    
    /*
    func removeConnection(_ idToken: String, connectionId: String) async throws {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        try await performRequestEmptyResponse(
            endpoint: "/connections/\(connectionId)",
            method: .delete,
            headers: headers
        )
    }
    */
    
    /*
    func getConnections(_ idToken: String, status: ConnectionStatus? = nil) async throws -> [Connection] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        var parameters: [String: Any] = [:]
        if let status = status {
            parameters["status"] = status.rawValue
        }
        
        return try await performRequest(
            endpoint: "/connections",
            method: .get,
            parameters: parameters,
            headers: headers,
            responseType: [Connection].self
        )
    }
    */
    
    /*
    func getPendingConnectionRequests(_ idToken: String) async throws -> [Connection] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/connections/pending",
            method: .get,
            headers: headers,
            responseType: [Connection].self
        )
    }
    */
    
    /*
    func checkConnection(_ idToken: String, userId: String) async throws -> ConnectionCheckResponse {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/connections/check/\(userId)",
            method: .get,
            headers: headers,
            responseType: ConnectionCheckResponse.self
        )
    }
    */
    
    // MARK: - User Profiles
    func getUserProfile(_ idToken: String, userId: String) async throws -> User {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        struct UserProfileResponse: Codable {
            let success: Bool
            let data: User
        }
        
        let response = try await performRequest(
            endpoint: "/users/profile/\(userId)",
            method: .get,
            headers: headers,
            responseType: UserProfileResponse.self
        )
        
        return response.data
    }
    
    func getCurrentUserProfile(_ idToken: String) async throws -> User {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        return try await performRequest(
            endpoint: "/users/me",
            method: .get,
            headers: headers,
            responseType: User.self
        )
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
    
    private func performRequestEmptyResponse(
        endpoint: String,
        method: HTTPMethod = .post,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) async throws {
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
                encoding: JSONEncoding.default,
                headers: headers
            )
            .validate()
            .response { response in
                #if DEBUG
                print("📱 API Response Status: \(response.response?.statusCode ?? 0)")
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("📄 Response Data: \(str)")
                }
                #endif
                
                switch response.result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    #if DEBUG
                    print("❌ API Error: \(error)")
                    #endif
                    continuation.resume(throwing: error)
                }
            }
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
    
    func fetchPosts(_ idToken: String, parameters: [String: Any] = [:]) async throws -> [Post] {
        await simulateNetworkDelay()
        
        // Simple mock filtering
        var filteredPosts = Post.mockPosts
        
        if let type = parameters["type"] as? String {
            if type == PostType.task.rawValue {
                filteredPosts = filteredPosts.filter { $0.type == .task }
            } else if type == PostType.skillShare.rawValue {
                filteredPosts = filteredPosts.filter { $0.type == .skillShare }
            }
        }
        
        if let userId = parameters["userId"] as? String {
            filteredPosts = filteredPosts.filter { $0.userId == userId }
        }
        
        if let status = parameters["status"] as? String,
           status == PostStatus.active.rawValue {
            filteredPosts = filteredPosts.filter { $0.status == .active }
        }
        
        return filteredPosts
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

