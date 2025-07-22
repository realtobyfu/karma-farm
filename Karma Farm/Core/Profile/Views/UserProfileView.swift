import SwiftUI

struct UserProfileView: View {
    let userId: String
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showingSendConnection = false
    @State private var connectionMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if let user = viewModel.user {
                    VStack(spacing: 24) {
                        // Profile Header
                        UserProfileHeaderView(
                            user: user,
                            connectionStatus: viewModel.connectionStatus,
                            onConnect: { showingSendConnection = true },
                            onAccept: { await viewModel.acceptConnection() },
                            onDecline: { await viewModel.declineConnection() }
                        )
                        
                        // Stats Section
                        StatsCardView(stats: viewModel.userStats)
                        
                        // Skills & Interests (if visible based on privacy)
                        if user.skills.count > 0 || user.interests.count > 0 {
                            SkillsInterestsView(user: user)
                        }
                        
                        // Badges (if visible based on privacy)
                        if !user.badges.isEmpty {
                            BadgesView(badges: user.badges)
                        }
                        
                        // Recent Posts
                        if !viewModel.userPosts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Posts")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.userPosts) { post in
                                    PostRowView(post: post)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Profile")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            Task {
                                await viewModel.loadUserProfile(userId: userId)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSendConnection) {
                SendConnectionView(
                    toUser: viewModel.user,
                    message: $connectionMessage,
                    onSend: {
                        Task {
                            await viewModel.sendConnectionRequest(message: connectionMessage)
                            showingSendConnection = false
                        }
                    }
                )
            }
        }
        .task {
            await viewModel.loadUserProfile(userId: userId)
        }
    }
}

// MARK: - User Profile Header
struct UserProfileHeaderView: View {
    let user: User
    let connectionStatus: ConnectionStatus?
    let onConnect: () -> Void
    let onAccept: () async -> Void
    let onDecline: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Picture
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 100, height: 100)
                .overlay(
                    Group {
                        if let profileImageUrl = user.profileImageUrl,
                           let url = URL(string: profileImageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                    }
                )
            
            // Name and Bio
            Text(user.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
            }
            
            // Connection Button
            if let status = connectionStatus {
                switch status {
                case .pending:
                    if let currentUserId = AuthManager.shared.currentUser?.id,
                       user.id == currentUserId {
                        // Incoming request
                        HStack(spacing: 12) {
                            Button {
                                Task { await onAccept() }
                            } label: {
                                Label("Accept", systemImage: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                Task { await onDecline() }
                            } label: {
                                Label("Decline", systemImage: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        // Outgoing request
                        Label("Request Sent", systemImage: "clock.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(20)
                    }
                    
                case .accepted:
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                    
                default:
                    Button(action: onConnect) {
                        Label("Connect", systemImage: "person.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Button(action: onConnect) {
                    Label("Connect", systemImage: "person.badge.plus")
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Send Connection View
struct SendConnectionView: View {
    let toUser: User?
    @Binding var message: String
    let onSend: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Send connection request to \(toUser?.name ?? "user")")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a message (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $message)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        onSend()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - View Model
@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var userStats = UserStats()
    @Published var userPosts: [Post] = []
    @Published var connectionStatus: ConnectionStatus?
    @Published var connection: Connection?
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiService = APIService.shared
    
    func loadUserProfile(userId: String) async {
        isLoading = true
        error = nil
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            // Load user profile
            user = try await apiService.getUserProfile(idToken, userId: userId)
            
            // Check connection status
            let connectionCheck = try await apiService.checkConnection(idToken, userId: userId)
            if connectionCheck.isConnected {
                connectionStatus = .accepted
            } else {
                // Check for pending requests
                let connections = try await apiService.getConnections(idToken)
                if let existingConnection = connections.first(where: {
                    ($0.fromUserId == userId || $0.toUserId == userId)
                }) {
                    connection = existingConnection
                    connectionStatus = existingConnection.status
                }
            }
            
            // TODO: Load user stats and posts
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func sendConnectionRequest(message: String) async {
        guard let userId = user?.id else { return }
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            let request = ConnectionRequest(toUserId: userId, message: message.isEmpty ? nil : message)
            connection = try await apiService.sendConnectionRequest(idToken, request: request)
            connectionStatus = .pending
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func acceptConnection() async {
        guard let connectionId = connection?.id else { return }
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            connection = try await apiService.acceptConnectionRequest(idToken, connectionId: connectionId)
            connectionStatus = .accepted
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func declineConnection() async {
        guard let connectionId = connection?.id else { return }
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            connection = try await apiService.declineConnectionRequest(idToken, connectionId: connectionId)
            connectionStatus = .declined
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(userId: "test-user-id")
    }
}