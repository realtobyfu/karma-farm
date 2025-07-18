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
                            HStack {
                                Text("\(Int(filters.radiusKm)) km")
                                    .font(DesignSystem.Typography.bodyMedium)
                                Spacer()
                                Text(filters.radiusKm > 40 ? "Any distance" : "")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Slider(value: $filters.radiusKm, in: 1...50, step: 1)
                                .accentColor(DesignSystem.Colors.primaryGreen)
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

// MARK: - Search Models
struct SearchFilters {
    var postType: RewardType?
    var isRequest: Bool?
    var radiusKm: Double = 10
    var minKarma: Int?
    var maxKarma: Int?
    var verifiedUsersOnly = false
    var includeAnonymous = true
    var sortBy: SearchSortOption = .createdAt
    var tags: [String] = []
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