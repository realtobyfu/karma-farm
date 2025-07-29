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
                .onChange(of: viewModel.searchRadiusMiles) { _ in
                    if let location = locationManager.userLocation {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            updateCameraPosition(for: location)
                        }
                    }
                }
                
                // Controls overlay
                VStack {
                    HStack {
                        Spacer()
                        MapLegend()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Map style toggle
                            MapStyleToggle()
                            
                            // Recenter button
                            Button(action: recenterOnUser) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(DesignSystem.Colors.primaryGradient)
                                    .clipShape(Circle())
                                    .shadow(color: DesignSystem.Colors.primaryGreen.opacity(0.3), radius: 4, x: 0, y: 2)
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
                        Section("Reward Types") {
                            Button(action: { viewModel.filterRewardType = nil }) {
                                Label("All Types", systemImage: "circle.grid.3x3.fill")
                            }
                            
                            ForEach(RewardType.allCases, id: \.self) { rewardType in
                                Button(action: { viewModel.filterRewardType = rewardType }) {
                                    Label(rewardType.displayName, systemImage: rewardType.icon)
                                }
                            }
                        }
                        
                        Section("Post Types") {
                            Button(action: { viewModel.filterType = .all }) {
                                Label("All Posts", systemImage: "circle.fill")
                            }
                            
                            Button(action: { viewModel.filterType = .requests }) {
                                Label("Requests Only", systemImage: "hand.raised.fill")
                            }
                            
                            Button(action: { viewModel.filterType = .offers }) {
                                Label("Offers Only", systemImage: "heart.fill")
                            }
                        }
                        
                        Section("Search Radius") {
                            Button(action: { viewModel.searchRadiusMiles = 5 }) {
                                Label("5 miles", systemImage: viewModel.searchRadiusMiles == 5 ? "checkmark.circle.fill" : "circle")
                            }
                            
                            Button(action: { viewModel.searchRadiusMiles = 10 }) {
                                Label("10 miles", systemImage: viewModel.searchRadiusMiles == 10 ? "checkmark.circle.fill" : "circle")
                            }
                            
                            Button(action: { viewModel.searchRadiusMiles = 25 }) {
                                Label("25 miles", systemImage: viewModel.searchRadiusMiles == 25 ? "checkmark.circle.fill" : "circle")
                            }
                            
                            Button(action: { viewModel.searchRadiusMiles = 50 }) {
                                Label("50 miles", systemImage: viewModel.searchRadiusMiles == 50 ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    } label: {
                        ZStack {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.title2)
                                .foregroundStyle(DesignSystem.Colors.primaryGradient)
                            
                            // Show active filter indicator
                            if viewModel.filterRewardType != nil || viewModel.filterType != .all {
                                Circle()
                                    .fill(DesignSystem.Colors.primaryOrange)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
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
        // Calculate span based on search radius
        // Rough conversion: 1 degree latitude ≈ 69 miles
        let spanDegrees = Double(viewModel.searchRadiusMiles) / 69.0 * 2.0 // *2 for full diameter
        
        cameraPosition = MapCameraPosition.region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: spanDegrees, longitudeDelta: spanDegrees)
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
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            onTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    // Outer glow effect
                    Circle()
                        .fill(post.rewardType.primaryColor.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                    
                    // Main pin with gradient
                    Circle()
                        .fill(post.rewardType.gradient)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: post.rewardType.primaryColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: post.rewardType.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Value badge
                Text(post.displayValue)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(post.rewardType.gradient)
                    .clipShape(Capsule())
                    .shadow(color: post.rewardType.primaryColor.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
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
                            // Reward type badge
                            HStack(spacing: 4) {
                                Image(systemName: post.rewardType.icon)
                                Text(post.rewardType.displayName)
                            }
                            .font(DesignSystem.Typography.captionMedium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(post.rewardType.gradient)
                            .clipShape(Capsule())
                            
                            // Request/Offer badge
                            Text(post.isRequest ? "REQUEST" : "OFFER")
                                .font(DesignSystem.Typography.captionMedium)
                                .foregroundColor(post.isRequest ? .red : DesignSystem.Colors.primaryGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((post.isRequest ? Color.red : DesignSystem.Colors.primaryGreen).opacity(0.1))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            // Value display
                            Text(post.displayValue)
                                .font(DesignSystem.Typography.numberMedium)
                                .foregroundColor(post.rewardType.primaryColor)
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
                                Image(systemName: post.isRequest ? "hand.raised.fill" : "message.fill")
                                Text(post.isRequest ? "Accept Task" : "Contact \(post.user?.username ?? "User")")
                            }
                            .font(DesignSystem.Typography.bodySemibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(post.rewardType.gradient)
                            .cornerRadius(DesignSystem.Radius.medium)
                            .shadow(color: post.rewardType.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
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
