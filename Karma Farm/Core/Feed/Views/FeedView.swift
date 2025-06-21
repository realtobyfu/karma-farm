//
//  FeedView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedFilter: FeedFilter = .all
    @State private var showingCreatePost = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter picker
                FilterPickerView(selectedFilter: $selectedFilter)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Feed content
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.posts.isEmpty {
                    EmptyFeedView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    PostsFeedView(posts: viewModel.posts, isLoading: viewModel.isLoading)
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
            .onChange(of: selectedFilter) { newFilter in
                viewModel.filterChanged(to: newFilter)
            }
        }
    }
}

struct FilterPickerView: View {
    @Binding var selectedFilter: FeedFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FeedFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.purple.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PostsFeedView: View {
    let posts: [Post]
    let isLoading: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts) { post in
                    PostCardView(post: post)
                        .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await FeedViewModel().refresh()
        }
    }
}

struct PostCardView: View {
    let post: Post
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let user = post.user {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(.systemGray4))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text(user.username.prefix(1).uppercased())
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                )
                            
                            Text(user.username)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: post.type.icon)
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                        
                        Text("\(post.karmaValue)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    
                    if let timeRemaining = post.timeRemaining {
                        Text(timeRemaining)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Description
            Text(post.description)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Location and type
            HStack {
                if let locationName = post.locationName {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        
                        Text(locationName)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(post.isRequest ? "REQUEST" : "OFFER")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(post.isRequest ? .red : .green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((post.isRequest ? Color.red : Color.green).opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: { showingDetail = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                        Text("View Details")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                }
                
                Spacer()
                
                if post.isCurrentUserPost {
                    Button(action: { }) {
                        Text("Edit")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Button(action: { }) {
                        HStack(spacing: 4) {
                            Image(systemName: "message")
                            Text("Contact")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingDetail) {
            PostDetailView(post: post)
        }
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Posts Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Be the first to share a post in your community!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button("Create Your First Post") {
                // TODO: Show create post view
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.purple)
            .cornerRadius(12)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading posts...")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.title)
                            .font(.system(size: 28, weight: .bold))
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
                        DetailRow(icon: "star.fill", title: "Karma Value", value: "\(post.karmaValue)")
                        DetailRow(icon: "clock.fill", title: "Posted", value: post.timeRemaining ?? "Just now")
                        
                        if let locationName = post.locationName {
                            DetailRow(icon: "location.fill", title: "Location", value: locationName)
                        }
                        
                        DetailRow(icon: "tag.fill", title: "Type", value: post.isRequest ? "Request" : "Offer")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // TODO: Dismiss
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
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
    FeedView()
} 
