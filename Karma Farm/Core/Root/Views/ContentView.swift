//
//  ContentView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingContainerView()
                }
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            // Check authentication state on app launch
        }
    }
    
    private var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingCreatePost = false
    @State private var previousTab = 0
    
    let tabs: [(icon: String, title: String)] = [
        ("house.fill", "Home"),
        ("map.fill", "Map"),
        ("", ""), // Empty for FAB
        ("bubble.left.fill", "Chat"),
        ("person.crop.circle.fill", "Profile")
    ]
    
    // Create a mapping for actual tab indices after filtering
    let tabIndexMapping: [Int] = [0, 1, 3, 4] // Maps filtered indices to actual indices
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            // Content with transitions
            ZStack {
                FeedView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .scaleEffect(selectedTab == 0 ? 1 : 0.95)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
                
                if selectedTab == 1 {
                    MapView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                if selectedTab == 3 {
                    ChatListView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                if selectedTab == 4 {
                    ProfileView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            
            // Animated Tab Bar
            VStack {
                Spacer()
                AnimatedTabBar(
                    selectedTab: Binding(
                        get: {
                            // Convert actual tab index to filtered tab index
                            if let index = tabIndexMapping.firstIndex(of: selectedTab) {
                                return index
                            }
                            return 0
                        },
                        set: { filteredIndex in
                            // Convert filtered tab index to actual tab index
                            if filteredIndex < tabIndexMapping.count {
                                selectedTab = tabIndexMapping[filteredIndex]
                            }
                        }
                    ),
                    tabs: tabs.filter { !$0.icon.isEmpty }
                )
            }
        }
        .onChange(of: selectedTab) { newValue in
            if newValue != 2 { // Skip FAB space
                previousTab = newValue
            }
        }
    }
}


#Preview("Unauthenticated") {
    ContentView()
        .environmentObject(AuthManager.mockUnauthenticated as! AuthManager)
}

#Preview("Authenticated") {
    ContentView()
        .environmentObject(AuthManager.mockAuthenticated as! AuthManager)
}

#Preview("Feed") {
    FeedView()
}


#Preview("Profile") {
    ProfileView()
        .environmentObject(AuthManager.mockAuthenticated as! AuthManager)
}
