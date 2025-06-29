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
    
    var body: some View {
        ZStack {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    FeedView()
                case 1:
                    MapView()
                case 3:
                    ChatListView()
                case 4:
                    ProfileView()
                default:
                    FeedView()
                }
            }
            
            // Modern Tab Bar
            VStack {
                Spacer()
                ModernTabBar(selectedTab: $selectedTab)
            }
            
            // Floating Action Button - removed from here as it's in FeedView
        }
    }
}

struct ChatListView: View {
    @State private var chats = Chat.mockChats
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                List(chats) { chat in
                    ChatRowView(chat: chat)
                        .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Messages")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Circle()
                .fill(DesignSystem.Colors.backgroundSecondary)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.user?.username.prefix(1).uppercased() ?? "?")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                )
            
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
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.medium)
        .padding(.horizontal, DesignSystem.Spacing.sm)
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
