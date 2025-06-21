//
//  CreatePostView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import CoreLocation

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @StateObject private var locationManager = LocationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: PostType = .general
    @State private var karmaValue = 10
    @State private var isRequest = true
    @State private var useCurrentLocation = true
    @State private var customLocationName = ""
    @State private var expirationDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @State private var hasExpiration = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Post Type Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What do you want to post?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            PostTypeButton(
                                title: "Request Help",
                                subtitle: "Ask for assistance",
                                icon: "hand.raised.fill",
                                isSelected: isRequest,
                                color: .red
                            ) {
                                isRequest = true
                            }
                            
                            PostTypeButton(
                                title: "Offer Help",
                                subtitle: "Provide assistance",
                                icon: "heart.fill",
                                isSelected: !isRequest,
                                color: .green
                            ) {
                                isRequest = false
                            }
                        }
                    }
                    
                    // Basic Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic Information")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            TextField("Title", text: $title)
                                .textFieldStyle(CreatePostTextFieldStyle())
                            
                            TextField("Description", text: $description, axis: .vertical)
                                .textFieldStyle(CreatePostTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Category")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(PostType.allCases, id: \.self) { type in
                                CategoryChip(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    
                    // Karma Value
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Karma Value")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("How much karma is this worth?")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(karmaValue) karma")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(karmaValue) },
                                set: { karmaValue = Int($0) }
                            ), in: 5...100, step: 5)
                            .accentColor(.purple)
                        }
                    }
                    
                    // Location
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            Toggle("Use current location", isOn: $useCurrentLocation)
                                .font(.system(size: 16))
                            
                            if !useCurrentLocation {
                                TextField("Enter location name", text: $customLocationName)
                                    .textFieldStyle(CreatePostTextFieldStyle())
                            }
                            
                            if let location = locationManager.userLocation {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.purple)
                                    
                                    Text("Current: \(location.coordinate.latitude, specifier: "%.3f"), \(location.coordinate.longitude, specifier: "%.3f")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Expiration
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expiration")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            Toggle("Set expiration date", isOn: $hasExpiration)
                                .font(.system(size: 16))
                            
                            if hasExpiration {
                                DatePicker("Expires on", selection: $expirationDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                    .font(.system(size: 16))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        LoadingOverlay()
                    }
                }
            )
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && (!useCurrentLocation ? !customLocationName.isEmpty : true)
    }
    
    private func createPost() {
        Task {
            do {
                let locationName = useCurrentLocation ? "Current Location" : customLocationName
                let location = useCurrentLocation ? locationManager.userLocation : nil
                
                try await viewModel.createPost(
                    title: title,
                    description: description,
                    type: selectedType,
                    karmaValue: karmaValue,
                    isRequest: isRequest,
                    location: location,
                    locationName: locationName,
                    expiresAt: hasExpiration ? expirationDate : nil
                )
                
                dismiss()
            } catch {
                // Error is handled in view model
            }
        }
    }
}

struct PostTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? color : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryChip: View {
    let type: PostType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .foregroundColor(isSelected ? .white : .purple)
                    .font(.system(size: 20))
                
                Text(type.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .purple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.purple : Color.purple.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CreatePostTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .font(.system(size: 16))
    }
}

struct LoadingOverlay: View {
    var body: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Creating Post...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(24)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            )
    }
}

#Preview {
    CreatePostView()
} 