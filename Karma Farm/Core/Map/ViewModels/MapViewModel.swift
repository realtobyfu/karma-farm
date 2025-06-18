//
//  MapViewModel.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//
import Foundation
import MapKit
import SwiftUI

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
        // TODO: Fetch posts from backend based on location and radius
    }
}
