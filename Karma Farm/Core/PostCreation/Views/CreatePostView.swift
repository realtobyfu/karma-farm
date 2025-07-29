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
    
    let selectedRewardType: RewardType?
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: PostType = .task
    @State private var selectedCategory: PostCategory = .other
    @State private var rewardType: RewardType = .karma
    @State private var selectedDuration = 60 // Default 60 minutes = 60 karma
    @State private var paymentAmount: Double = 20.0
    @State private var paymentInputText = "20.00"
    @State private var useCurrentLocation = true
    @State private var customLocationName = ""
    @State private var expirationDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @State private var hasExpiration = true
    @State private var showContent = false
    @State private var isRequest = false
    @State private var isRemote = false
    
    init(selectedRewardType: RewardType? = nil) {
        self.selectedRewardType = selectedRewardType
        if let rewardType = selectedRewardType {
            self._rewardType = State(initialValue: rewardType)
        }
    }
    
    var body: some View {
        NavigationView {
            content
        }
    }
    
    private var content: some View {
        ZStack {
            backgroundView
            scrollContent
        }
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .overlay(loadingOverlay)
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
            if let selectedRewardType = selectedRewardType {
                rewardType = selectedRewardType
            }
            withAnimation {
                showContent = true
            }
        }
    }
    
    private var backgroundView: some View {
        DesignSystem.Colors.backgroundPrimary
            .ignoresSafeArea()
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                    postTypeSection
                    
                    // Request/Offer Toggle
                    if selectedType != .social {
                        requestOfferSection
                    }
                    
                    // Reward Type Selection
                    if selectedType != .social {
                        rewardTypeSection
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
                            ForEach(PostCategory.categories(for: selectedType), id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category.displayName)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedCategory == category ? .white : DesignSystem.Colors.primaryGreen)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategory == category ? DesignSystem.Colors.primaryGreen : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(DesignSystem.Colors.primaryGreen, lineWidth: 1.5)
                                                )
                                        )
                                }
                            }
                        }
                    }
                    
                    // Reward Value Section
                    if selectedType != .social {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(rewardType == .karma ? "Karma Value" : "Payment Amount")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if rewardType == .karma {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("How much time will this take?")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                    
                                    // Time preset buttons
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 12) {
                                        TimePresetButton(
                                            minutes: 15,
                                            isSelected: selectedDuration == 15,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 15 } }
                                        )
                                        TimePresetButton(
                                            minutes: 30,
                                            isSelected: selectedDuration == 30,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 30 } }
                                        )
                                        TimePresetButton(
                                            minutes: 45,
                                            isSelected: selectedDuration == 45,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 45 } }
                                        )
                                        TimePresetButton(
                                            minutes: 60,
                                            isSelected: selectedDuration == 60,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 60 } }
                                        )
                                        TimePresetButton(
                                            minutes: 90,
                                            isSelected: selectedDuration == 90,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 90 } }
                                        )
                                        TimePresetButton(
                                            minutes: 120,
                                            isSelected: selectedDuration == 120,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 120 } }
                                        )
                                        TimePresetButton(
                                            minutes: 180,
                                            isSelected: selectedDuration == 180,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 180 } }
                                        )
                                        TimePresetButton(
                                            minutes: 240,
                                            isSelected: selectedDuration == 240,
                                            action: { withAnimation(.easeInOut(duration: 0.2)) { selectedDuration = 240 } }
                                        )
                                    }
                                    
                                    // Custom time slider
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text("Custom time")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("\(selectedDuration) minutes")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(DesignSystem.Colors.primaryGreen)
                                        }
                                        
                                        Slider(value: Binding(
                                            get: { Double(selectedDuration) },
                                            set: { selectedDuration = Int($0) }
                                        ), in: 15...240, step: 5)
                                        .accentColor(DesignSystem.Colors.primaryGreen)
                                    }
                                    
                                    // Show karma calculation with visual indicator
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(DesignSystem.Colors.primaryGreen.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            
                                            Text("\(calculatedKarmaValue)")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(DesignSystem.Colors.primaryGreen)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Karma value")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            
                                            Text("1 karma = 1 minute")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(DesignSystem.Colors.primaryGreen.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            } else if rewardType == .cash {
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
                    
                    // Location Type
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location Type")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            LocationTypeButton(
                                isRemote: false,
                                isSelected: !isRemote,
                                title: "In-Person",
                                icon: "person.2.fill"
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isRemote = false
                                }
                            }
                            
                            LocationTypeButton(
                                isRemote: true,
                                isSelected: isRemote,
                                title: "Remote",
                                icon: "laptopcomputer"
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isRemote = true
                                }
                            }
                        }
                    }
                    
                    // Location
                    if !isRemote {
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
    
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && (!useCurrentLocation ? !customLocationName.isEmpty : true)
    }
    
    private var calculatedKarmaValue: Int {
        // 1 karma = 1 minute
        return selectedDuration
    }
    
    private var durationText: String {
        switch selectedDuration {
        case 30:
            return "30 minutes"
        case 60:
            return "1 hour"
        case 120:
            return "2 hours"
        case 240:
            return "4 hours"
        case 480:
            return "8 hours"
        default:
            return "\(selectedDuration) minutes"
        }
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
                    category: selectedCategory,
                    rewardType: selectedType == .social ? .fun : rewardType,
                    karmaValue: (selectedType != .social && rewardType == .karma) ? calculatedKarmaValue : 0,
                    paymentAmount: (selectedType != .social && rewardType == .cash) ? paymentAmount : nil,
                    location: location,
                    locationName: locationName,
                    expiresAt: hasExpiration ? expirationDate : nil,
                    isRequest: selectedType != .social ? isRequest : false,
                    isRemote: isRemote
                )
                
                dismiss()
            } catch {
                // Error is handled in view model
            }
        }
    }
    
    private var postTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                
                Text("Choose the type of activity")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: showContent)
            
            HStack(spacing: 12) {
                ForEach(PostType.allCases, id: \.self) { postType in
                    PostTypeButton(
                        title: postType.displayName,
                        icon: nil,
                        isSelected: selectedType == postType,
                        color: getPostTypeColor(postType)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = postType
                            // Update reward type based on post type
                            if postType == .social {
                                rewardType = .fun
                            } else if rewardType == .fun && postType != .social {
                                // Reset to karma if moving away from social
                                rewardType = .karma
                            }
                            // Reset category when changing post type
                            selectedCategory = PostCategory.categories(for: postType).first ?? .other
                        }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
            }
        }
    }
    
    private var requestOfferSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Are you offering or requesting?")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
            }
            
            HStack(spacing: 12) {
                // Offer option
                RequestOfferOptionButton(
                    isRequest: false,
                    isSelected: !isRequest,
                    title: "Offer"
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRequest = false
                    }
                }
                
                // Request option
                RequestOfferOptionButton(
                    isRequest: true,
                    isSelected: isRequest,
                    title: "Request"
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRequest = true
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var requestOfferDescription: String {
        switch selectedType {
        case .skillShare:
            return "Choose whether you're offering to teach or looking to learn"
        case .task:
            return "Choose whether you're offering help or need help"
        case .social:
            return ""
        }
    }
    
    private var offerDescription: String {
        switch selectedType {
        case .skillShare:
            return "Teach a skill"
        case .task:
            return "Help someone"
        case .social:
            return ""
        }
    }
    
    private var requestDescription: String {
        switch selectedType {
        case .skillShare:
            return "Learn a skill"
        case .task:
            return "Need help"
        case .social:
            return ""
        }
    }
    
    private var rewardTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How will this be rewarded?")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                }
            
            HStack(spacing: 12) {
                // Karma option
                RewardOptionButton(
                    type: .karma,
                    isSelected: rewardType == .karma,
                    title: "Karma Points",
                ) {
                    rewardType = .karma
                }
                
                // Cash option
                RewardOptionButton(
                    type: .cash,
                    isSelected: rewardType == .cash,
                    title: "Cash Payment",
                ) {
                    rewardType = .cash
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
    
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                LoadingOverlay()
            }
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

struct PostTypeButton: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
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
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? color : Color(.systemGray6))
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
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
}

struct RewardOptionButton: View {
    let type: RewardType
    let isSelected: Bool
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : type.primaryColor)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        type.gradient
                    } else {
                        Color(.systemGray6)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RequestOfferOptionButton: View {
    let isRequest: Bool
    let isSelected: Bool
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: isRequest ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryGreen)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        DesignSystem.Colors.primaryGreen
                    } else {
                        Color(.systemGray6)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationTypeButton: View {
    let isRemote: Bool
    let isSelected: Bool
    let title: String
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryGreen)
                
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        DesignSystem.Colors.primaryGreen
                    } else {
                        Color(.systemGray6)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimePresetButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    
    var displayText: String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h\(mins)m"
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(displayText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryGreen)
                
                Text("\(minutes)")
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? DesignSystem.Colors.primaryGreen : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : DesignSystem.Colors.primaryGreen.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreatePostView()
} 
