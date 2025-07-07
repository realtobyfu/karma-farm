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

struct ChatListView: View {
    @State private var chats = Chat.mockChats
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(Array(chats.enumerated()), id: \.element.id) { index, chat in
                            ChatRowView(chat: chat)
                                .slideInAnimation(delay: Double(index) * 0.05)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    withAnimation {
                        isRefreshing = true
                    }
                    // Simulate refresh
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    withAnimation {
                        isRefreshing = false
                    }
                }
                .navigationTitle("Messages")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Animated Avatar
            Circle()
                .fill(DesignSystem.Colors.backgroundSecondary)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.user?.username.prefix(1).uppercased() ?? "?")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.user?.username ?? "Unknown")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(chat.lastMessage?.content ?? "No messages")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("2h")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                if chat.unreadCount > 0 {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGreen)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("\(chat.unreadCount)")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(.white)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.medium)
        .shadow(color: Color.black.opacity(isPressed ? 0.05 : 0.02), radius: isPressed ? 2 : 5, x: 0, y: isPressed ? 1 : 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
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

#Preview("Chat List") {
    ChatListView()
}

#Preview("Profile") {
    ProfileView()
        .environmentObject(AuthManager.mockAuthenticated as! AuthManager)
}
