import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Post] = []
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var errorMessage: String?
    @Published var filters = SearchFilters()
    @Published var recentSearches: [String] = []
    
    private let apiService = APIService.shared
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRecentSearches()
    }
    
    func search(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSearching = true
        hasSearched = true
        errorMessage = nil
        
        // Save to recent searches
        saveRecentSearch(query)
        
        // Build search parameters
        var params: [String: String] = [
            "search": query,
            "limit": "50"
        ]
        
        // Add filters
        if let postType = filters.postType {
            params["type"] = postType.rawValue
        }
        
        if let isRequest = filters.isRequest {
            params["isRequest"] = String(isRequest)
        }
        
        if let minKarma = filters.minKarma {
            params["minKarma"] = String(minKarma)
        }
        
        if let maxKarma = filters.maxKarma {
            params["maxKarma"] = String(maxKarma)
        }
        
        params["verifiedUsersOnly"] = String(filters.verifiedUsersOnly)
        params["includeAnonymous"] = String(filters.includeAnonymous)
        params["sortBy"] = filters.sortBy.rawValue
        
        // Add location if available and distance filter is active
        if filters.radiusKm < 50,
           let location = locationManager.userLocation {
            params["latitude"] = String(location.coordinate.latitude)
            params["longitude"] = String(location.coordinate.longitude)
            params["radius"] = String(Int(filters.radiusKm * 1000)) // Convert to meters
        }
        
        if !filters.tags.isEmpty {
            params["tags"] = filters.tags.joined(separator: ",")
        }
        
        do {
            let response: SearchPostsResponse = try await apiService.request(
                endpoint: "/posts/search",
                method: .get,
                parameters: params,
                responseType: SearchPostsResponse.self
            )
            
            searchResults = response.posts
        } catch {
            errorMessage = "Failed to search: \(error.localizedDescription)"
            print("Search error: \(error)")
            searchResults = []
        }
        
        isSearching = false
    }
    
    private func saveRecentSearch(_ query: String) {
        // Remove if already exists
        recentSearches.removeAll { $0 == query }
        
        // Add to front
        recentSearches.insert(query, at: 0)
        
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
}

struct SearchPostsResponse: Codable {
    let posts: [Post]
    let total: Int
}