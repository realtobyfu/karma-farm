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

struct APIConfig {
    static let baseURL = "http://localhost:3000" // Change to your backend URL
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

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    private func getAuthToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIError.notAuthenticated
        }
        return try await user.getIDToken()
    }
    
    // MARK: - User Endpoints
    func updateProfile(_ profile: ProfileUpdateRequest) async throws -> User {
        let token = try await getAuthToken()
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        return try await AF.request(
            "\(APIConfig.baseURL)/auth/setup-profile",
            method: .post,
            parameters: profile,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        .validate()
        .serializingDecodable(User.self)
        .value
    }
    
    // MARK: - Posts Endpoints
    func fetchNearbyPosts(latitude: Double, longitude: Double, radius: Double) async throws -> [Post] {
        let token = try await getAuthToken()
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
        
        return try await AF.request(
            "\(APIConfig.baseURL)/posts/nearby",
            method: .get,
            parameters: parameters,
            headers: headers
        )
        .validate()
        .serializingDecodable([Post].self)
        .value
    }
    
    func createPost(_ post: CreatePostRequest) async throws -> Post {
        let token = try await getAuthToken()
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        return try await AF.request(
            "\(APIConfig.baseURL)/posts",
            method: .post,
            parameters: post,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        .validate()
        .serializingDecodable(Post.self)
        .value
    }
}

enum APIError: Error {
    case notAuthenticated
    case invalidResponse
    case serverError(String)
}
