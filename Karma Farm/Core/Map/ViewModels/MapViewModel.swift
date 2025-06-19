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

@MainActor
class MapViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.4075, longitude: -71.1190),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var searchRadius: Double = 10
    
    func centerOnUserLocation() {
        guard let location = LocationManager.shared.userLocation else { return }
        withAnimation {
            region.center = location.coordinate
        }
    }
    
    func fetchNearbyPosts() async {
        guard let location = LocationManager.shared.userLocation else { return }
        do {
            // Get current user's auth token
            guard let user = AuthManager.shared.firebaseUser else {
                print("No authenticated user")
                self.posts = Post.mockPosts
                return
            }
            let token = try await user.getIDToken()
            let posts = try await APIService.shared.fetchNearbyPosts(token, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: searchRadius)
            self.posts = posts
        } catch {
            print("Failed to fetch nearby posts: \(error)")
            // Use mock data for now
            self.posts = Post.mockPosts
        }
    }
}
