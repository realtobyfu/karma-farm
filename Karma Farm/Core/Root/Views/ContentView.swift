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

// Placeholder views for main app sections
struct FeedView: View {
    @State private var posts = Post.mockPosts
    
    var body: some View {
        NavigationView {
            List(posts) { post in
                PostRowView(post: post)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(PlainListStyle())
                .navigationTitle("Feed")
        }
    }
}

struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let user = post.user {
                        Text("by \(user.username)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: post.type.icon)
                            .foregroundColor(.orange)
                        Text("\(post.karmaValue)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    if let timeRemaining = post.timeRemaining {
                        Text(timeRemaining)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(post.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            if let locationName = post.locationName {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MapView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Map View")
                    .font(.title)
                Text("Posts will be displayed on map here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
                .navigationTitle("Map")
        }
    }
}

struct CreatePostView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
            Text("Create Post")
                    .font(.title)
                
                Text("Form to create new posts will go here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
                .navigationTitle("Create")
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

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var userStats = UserStats.mockStats
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(authManager.currentUser?.username.prefix(1).uppercased() ?? "U")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                    
                    Text(authManager.currentUser?.username ?? "User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Karma Balance: \(authManager.currentUser?.karmaBalance ?? 0)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                // Stats
                HStack(spacing: 30) {
                    VStack {
                        Text("\(userStats.postsCreated)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Posts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(userStats.karmaEarned)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Earned")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
            VStack {
                        Text("\(userStats.connections)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Connections")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Sign Out") {
                    authManager.signOut()
                }
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("Profile")
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
