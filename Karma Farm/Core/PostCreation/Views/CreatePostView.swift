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
    
    let selectedTaskType: TaskType?
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: PostType = .task
    @State private var selectedCategory: PostCategory = .other
    @State private var taskType: TaskType = .karma
    @State private var karmaValue = 10
    @State private var paymentAmount: Double = 20.0
    @State private var karmaInputText = "10"
    @State private var paymentInputText = "20.00"
    @State private var useCurrentLocation = true
    @State private var customLocationName = ""
    @State private var expirationDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @State private var hasExpiration = true
    @State private var showContent = false
    
    init(selectedTaskType: TaskType? = nil) {
        self.selectedTaskType = selectedTaskType
        if let taskType = selectedTaskType {
            self._taskType = State(initialValue: taskType)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(spacing: 24) {
                    // Post Type Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Post Type")
                            .font(DesignSystem.Typography.title1)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: showContent)
                        
                        HStack(spacing: 12) {
                            ForEach(PostType.allCases, id: \.self) { postType in
                                PostTypeButton(
                                    title: postType.displayName,
                                    subtitle: getPostTypeSubtitle(postType),
                                    icon: nil,
                                    isSelected: selectedType == postType,
                                    color: getPostTypeColor(postType)
                                ) {
                                    selectedType = postType
                                    // Update task type based on post type
                                    if postType == .social {
                                        taskType = .fun
                                    }
                                    // Reset category when changing post type
                                    selectedCategory = PostCategory.categories(for: postType).first ?? .other
                                }
                            }
                        }
                    }
                    
                    // Basic Information
                    // Task Type Badge
                    HStack {
                        Text("Task Type")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        TaskTypeBadge(taskType: taskType, value: taskType.displayName)
                    }
                    
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
                            ForEach(PostCategory.categories(for: selectedType), id: \.self) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    
                    // Task Type Value Section
                    if selectedType != .social {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(taskType == .karma ? "Karma Value" : "Payment Amount")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if taskType == .karma {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Enter karma amount")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        TextField("10", text: $karmaInputText)
                                            .keyboardType(.numberPad)
                                            .textFieldStyle(CreatePostTextFieldStyle())
                                            .onChange(of: karmaInputText) { newValue in
                                                // Allow only numbers
                                                let filtered = newValue.filter { $0.isNumber }
                                                if filtered != newValue {
                                                    karmaInputText = filtered
                                                }
                                                if let value = Int(filtered) {
                                                    karmaValue = max(1, min(1000, value))
                                                }
                                            }
                                        
                                        Text("karma")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(DesignSystem.Colors.primaryBlue)
                                            .padding(.horizontal, 12)
                                    }
                                }
                            } else if taskType == .cash {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Payment amount (off-platform)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("$")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                                            .padding(.leading, 12)
                                        
                                        TextField("20.00", text: $paymentInputText)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(CreatePostTextFieldStyle())
                                            .onChange(of: paymentInputText) { newValue in
                                                // Allow numbers and one decimal point
                                                let components = newValue.components(separatedBy: ".")
                                                if components.count > 2 {
                                                    paymentInputText = String(newValue.dropLast())
                                                } else if components.count == 2 && components[1].count > 2 {
                                                    paymentInputText = components[0] + "." + String(components[1].prefix(2))
                                                } else {
                                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                                    if filtered != newValue {
                                                        paymentInputText = filtered
                                                    }
                                                    if let value = Double(filtered) {
                                                        paymentAmount = max(0.01, min(9999.99, value))
                                                    }
                                                }
                                            }
                                    }
                                    
                                    // Cash payment notice
                                    HStack(spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                                        
                                        Text("Cash payments are handled directly between users")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(12)
                                    .background(DesignSystem.Colors.primaryOrange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    } else {
                        // Social activity notice
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Social Activity")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(DesignSystem.Colors.primaryPurple)
                                
                                Text("This is a social activity with no rewards - just for fun!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .background(DesignSystem.Colors.primaryPurple.opacity(0.1))
                            .cornerRadius(8)
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
                                        .foregroundColor(DesignSystem.Colors.primaryGreen)
                                    
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
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
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
            .onAppear {
                if let selectedTaskType = selectedTaskType {
                    taskType = selectedTaskType
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
                    taskType: taskType,
                    karmaValue: taskType == .karma ? karmaValue : 0,
                    paymentAmount: taskType == .cash ? paymentAmount : nil,
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
    let icon: String?
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : color)
                }
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
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryGreen)
                    .font(.system(size: 20))
                
                Text(type.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.primaryGreen.opacity(0.1))
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
    
    private func getPostTypeSubtitle(_ type: PostType) -> String {
        switch type {
        case .skillShare:
            return "Share your skills"
        case .task:
            return "Request or offer help"
        case .social:
            return "Fun activities"
        }
    }
    
    private func getPostTypeColor(_ type: PostType) -> Color {
        switch type {
        case .skillShare:
            return DesignSystem.Colors.primaryBlue
        case .task:
            return DesignSystem.Colors.primaryGreen
        case .social:
            return DesignSystem.Colors.primaryPurple
        }
    }
}

#Preview {
    CreatePostView()
} 
