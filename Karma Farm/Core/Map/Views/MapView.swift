//
//  MapView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager.shared
    @State private var cameraPosition = MapCameraPosition.automatic
    @State private var showingCreatePost = false
    @State private var selectedPost: Post?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(position: $cameraPosition) {
                    // User location
                    if let userLocation = locationManager.userLocation {
                        Annotation("You", coordinate: userLocation.coordinate) {
                            UserLocationPin()
                        }
                    }
                    
                    // Posts on map
                    ForEach(viewModel.nearbyPosts) { post in
                        if let coordinate = post.coordinate {
                            Annotation(post.title, coordinate: coordinate) {
                                PostPin(post: post) {
                                    selectedPost = post
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .onAppear {
                    requestLocationAndLoadPosts()
                }
                .onChange(of: locationManager.userLocation) { newLocation in
                    if let location = newLocation {
                        updateCameraPosition(for: location)
                        viewModel.loadNearbyPosts(around: location)
                    }
                }
                
                // Controls overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Recenter button
                            Button(action: recenterOnUser) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            // Create post button
                            Button(action: { showingCreatePost = true }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.filterType = .all }) {
                            Label("All Posts", systemImage: "circle.fill")
                        }
                        
                        Button(action: { viewModel.filterType = .requests }) {
                            Label("Requests Only", systemImage: "hand.raised.fill")
                        }
                        
                        Button(action: { viewModel.filterType = .offers }) {
                            Label("Offers Only", systemImage: "heart.fill")
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
            .sheet(item: $selectedPost) { post in
                PostDetailSheet(post: post)
            }
        }
    }
    
    private func requestLocationAndLoadPosts() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestLocationPermission()
        } else if let location = locationManager.userLocation {
            updateCameraPosition(for: location)
            viewModel.loadNearbyPosts(around: location)
        }
    }
    
    private func updateCameraPosition(for location: CLLocation) {
        cameraPosition = MapCameraPosition.region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    
    private func recenterOnUser() {
        if let location = locationManager.userLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                updateCameraPosition(for: location)
            }
        }
    }
}

struct UserLocationPin: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 20, height: 20)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
}

struct PostPin: View {
    let post: Post
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(post.isRequest ? Color.red : Color.green)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: post.type.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                Text("\(post.karmaValue)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PostDetailSheet: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(post.isRequest ? "REQUEST" : "OFFER")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(post.isRequest ? .red : .green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((post.isRequest ? Color.red : Color.green).opacity(0.1))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                
                                Text("\(post.karmaValue)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Text(post.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if let user = post.user {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(user.username.prefix(1).uppercased())
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.username)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Karma: \(user.karmaBalance)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Description
                    Text(post.description)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        if let locationName = post.locationName {
                            DetailRow(icon: "location.fill", title: "Location", value: locationName)
                        }
                        
                        DetailRow(icon: "clock.fill", title: "Posted", value: post.timeRemaining ?? "Just now")
                        DetailRow(icon: "tag.fill", title: "Category", value: post.type.displayName)
                    }
                    
                    // Action button
                    if !post.isCurrentUserPost {
                        Button(action: { }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Contact \(post.user?.username ?? "User")")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct MapDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MapView()
} 
