import SwiftUI

struct SearchFiltersView: View {
    @Binding var filters: SearchFilters
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Post Type
                    FilterSection(title: "Post Type") {
                        Picker("Type", selection: $filters.postType) {
                            Text("All").tag(nil as RewardType?)
                            ForEach(RewardType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type as RewardType?)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Request or Offer
                    FilterSection(title: "Looking for") {
                        Picker("Request Type", selection: $filters.isRequest) {
                            Text("Both").tag(nil as Bool?)
                            Text("Requests").tag(true as Bool?)
                            Text("Offers").tag(false as Bool?)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Distance
                    FilterSection(title: "Distance") {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            // Radius Options
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    DistanceButton(
                                        title: "5 mi",
                                        miles: 5,
                                        isSelected: filters.radiusMiles == 5,
                                        action: { filters.radiusMiles = 5; filters.viewGlobal = false }
                                    )
                                    
                                    DistanceButton(
                                        title: "10 mi",
                                        miles: 10,
                                        isSelected: filters.radiusMiles == 10,
                                        action: { filters.radiusMiles = 10; filters.viewGlobal = false }
                                    )
                                    
                                    DistanceButton(
                                        title: "25 mi",
                                        miles: 25,
                                        isSelected: filters.radiusMiles == 25,
                                        action: { filters.radiusMiles = 25; filters.viewGlobal = false }
                                    )
                                    
                                    DistanceButton(
                                        title: "50 mi",
                                        miles: 50,
                                        isSelected: filters.radiusMiles == 50,
                                        action: { filters.radiusMiles = 50; filters.viewGlobal = false }
                                    )
                                }
                                
                                // View Global Toggle
                                Toggle("View Global (All locations)", isOn: $filters.viewGlobal)
                                    .tint(DesignSystem.Colors.primaryGreen)
                                    .onChange(of: filters.viewGlobal) { newValue in
                                        if newValue {
                                            filters.radiusMiles = nil
                                        }
                                    }
                            }
                            
                            // Current selection display
                            if let radiusMiles = filters.radiusMiles, !filters.viewGlobal {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(DesignSystem.Colors.primaryGreen)
                                    Text("Within \(radiusMiles) miles")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            } else if filters.viewGlobal {
                                HStack {
                                    Image(systemName: "globe")
                                        .font(.system(size: 14))
                                        .foregroundColor(DesignSystem.Colors.primaryBlue)
                                    Text("Viewing all locations globally")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Karma Range
                    FilterSection(title: "Karma Value") {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Min")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                    TextField("0", value: $filters.minKarma, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                                
                                Text("—")
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                VStack(alignment: .leading) {
                                    Text("Max")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                    TextField("100", value: $filters.maxKarma, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                            }
                        }
                    }
                    
                    // Additional Options
                    FilterSection(title: "Additional Filters") {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Toggle("Remote OK", isOn: $filters.includeRemote)
                                .tint(DesignSystem.Colors.primaryGreen)
                            
                            Text("Include tasks that can be done remotely")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .padding(.leading, 32)
                                .padding(.top, -8)
                            
                            Toggle("Verified users only", isOn: $filters.verifiedUsersOnly)
                                .tint(DesignSystem.Colors.primaryGreen)
                            
                            Toggle("Include anonymous posts", isOn: $filters.includeAnonymous)
                                .tint(DesignSystem.Colors.primaryGreen)
                        }
                    }
                    
                    // Sort Options
                    FilterSection(title: "Sort by") {
                        Picker("Sort", selection: $filters.sortBy) {
                            Text("Most Recent").tag(SearchSortOption.createdAt)
                            Text("Karma Value").tag(SearchSortOption.karmaValue)
                            Text("Distance").tag(SearchSortOption.distance)
                        }
                        .pickerStyle(DefaultPickerStyle())
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.backgroundPrimary)
            .navigationTitle("Search Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters = SearchFilters()
                    }
                    .foregroundColor(DesignSystem.Colors.primaryOrange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primaryGreen)
                }
            }
        }
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            content
        }
    }
}

struct DistanceButton: View {
    let title: String
    let miles: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? DesignSystem.Colors.primaryGreen : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(DesignSystem.Colors.primaryGreen, lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Models
struct SearchFilters {
    var postType: RewardType?
    var isRequest: Bool?
    var radiusMiles: Int? = 5 // Default 5 miles
    var viewGlobal = false
    var minKarma: Int?
    var maxKarma: Int?
    var verifiedUsersOnly = false
    var includeAnonymous = true
    var includeRemote = false
    var sortBy: SearchSortOption = .createdAt
    var tags: [String] = []
    
    // Computed property for backward compatibility
    var radiusKm: Double {
        get {
            if viewGlobal {
                return Double.infinity
            }
            // Convert miles to km (1 mile = 1.60934 km)
            return Double(radiusMiles ?? 5) * 1.60934
        }
        set {
            // Convert km back to miles
            radiusMiles = Int(newValue / 1.60934)
        }
    }
}

enum SearchSortOption: String, CaseIterable {
    case createdAt = "createdAt"
    case karmaValue = "karmaValue"
    case distance = "distance"
    
    var displayName: String {
        switch self {
        case .createdAt: return "Most Recent"
        case .karmaValue: return "Karma Value"
        case .distance: return "Distance"
        }
    }
}

#Preview {
    SearchFiltersView(filters: .constant(SearchFilters())) {
        print("Applied filters")
    }
}