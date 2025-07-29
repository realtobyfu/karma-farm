//
//  MapViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation
import MapKit
import SwiftUI
import FirebaseAuth

enum MapFilterType {
    case all
    case requests
    case offers
}

@MainActor
class MapViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var nearbyPosts: [Post] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.4075, longitude: -71.1190),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var searchRadiusMiles: Int = 5 {
        didSet {
            if let location = LocationManager.shared.userLocation {
                loadNearbyPosts(around: location)
            }
        }
    }
    
    // Computed property for km
    var searchRadius: Double {
        // Convert miles to km (1 mile = 1.60934 km)
        return Double(searchRadiusMiles) * 1.60934
    }
    @Published var filterType: MapFilterType = .all {
        didSet {
            applyFilter()
        }
    }
    @Published var filterRewardType: RewardType? = nil {
        didSet {
            applyFilter()
        }
    }
    
    func centerOnUserLocation() {
        guard let location = LocationManager.shared.userLocation else { return }
        withAnimation {
            region.center = location.coordinate
        }
    }
    
    func loadNearbyPosts(around location: CLLocation) {
        Task {
            await fetchNearbyPosts(location: location)
        }
    }
    
    func fetchNearbyPosts(location: CLLocation) async {
        do {
            // Get current user's auth token
            guard let user = AuthManager.shared.firebaseUser else {
                print("No authenticated user")
                self.posts = Post.mockPosts
                self.nearbyPosts = Post.mockPosts
                return
            }
            let token = try await user.getIDToken()
            let posts = try await APIService.shared.fetchNearbyPosts(token, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: searchRadius)
            self.posts = posts
            self.nearbyPosts = posts
            applyFilter()
        } catch {
            print("Failed to fetch nearby posts: \(error)")
            // Use mock data for now
            self.posts = Post.mockPosts
            self.nearbyPosts = Post.mockPosts
            applyFilter()
        }
    }
    
    func fetchNearbyPosts() async {
        guard let location = LocationManager.shared.userLocation else { return }
        await fetchNearbyPosts(location: location)
    }
    
    private func applyFilter() {
        var filtered = posts
        
        // Apply task type filter
        if let rewardType = filterRewardType {
            filtered = filtered.filter { $0.rewardType == rewardType }
        }
        
        // Apply request/offer filter
        switch filterType {
        case .all:
            nearbyPosts = filtered
        case .requests:
            nearbyPosts = filtered.filter { $0.isRequest }
        case .offers:
            nearbyPosts = filtered.filter { !$0.isRequest }
        }
    }
}
