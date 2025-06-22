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
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Feed")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Create")
                }
            
            ChatListView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

struct ChatListView: View {
    @State private var chats = Chat.mockChats
    
    var body: some View {
        NavigationView {
            List(chats) { chat in
                ChatRowView(chat: chat)
            }
                .navigationTitle("Messages")
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.user?.username.prefix(1).uppercased() ?? "?")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.user?.username ?? "Unknown")
                    .font(.headline)
                
                Text(chat.lastMessage?.content ?? "No messages")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("2h")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if chat.unreadCount > 0 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("\(chat.unreadCount)")
                                .font(.caption2)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.vertical, 4)
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
