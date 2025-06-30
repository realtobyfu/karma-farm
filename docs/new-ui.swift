import SwiftUI

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Design System
struct DesignSystem {
    struct Colors {
        static let primaryGreen = Color(hex: "00C896")
        static let primaryBlue = Color(hex: "0066FF")
        static let primaryOrange = Color(hex: "FF6B35")
        static let primaryPurple = Color(hex: "8B5CF6")
        
        static let backgroundPrimary = Color(hex: "FAFBFC")
        static let backgroundSecondary = Color(hex: "F3F4F6")
        static let textPrimary = Color(hex: "1F2937")
        static let textSecondary = Color(hex: "6B7280")
        
        static let karmaGradient = LinearGradient(
            colors: [Color(hex: "0066FF"), Color(hex: "00C896")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cashGradient = LinearGradient(
            colors: [Color(hex: "FF6B35"), Color(hex: "FFD93D")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let funGradient = LinearGradient(
            colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Updated Task Type
enum TaskType: String, CaseIterable {
    case karma = "karma"
    case cash = "cash"
    case fun = "fun"
    
    var icon: String {
        switch self {
        case .karma: return "star.fill"
        case .cash: return "dollarsign.circle.fill"
        case .fun: return "party.popper.fill"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .karma: return DesignSystem.Colors.karmaGradient
        case .cash: return DesignSystem.Colors.cashGradient
        case .fun: return DesignSystem.Colors.funGradient
        }
    }
    
    var displayName: String {
        switch self {
        case .karma: return "Karma"
        case .cash: return "Paid"
        case .fun: return "Fun"
        }
    }
}

// MARK: - Task Card Component
struct ModernTaskCard: View {
    let taskType: TaskType
    let title: String
    let description: String
    let value: String
    let location: String
    let timeAgo: String
    let userName: String
    let userAvatar: String?
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(userName.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Task Type Badge
                TaskTypeBadge(taskType: taskType, value: value)
            }
            .padding(16)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(3)
            }
            .padding(.horizontal, 16)
            
            // Footer
            HStack(spacing: 16) {
                Label(location, systemImage: "location.fill")
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View Details")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(taskType == .karma ? DesignSystem.Colors.primaryBlue : 
                                       taskType == .cash ? DesignSystem.Colors.primaryOrange : 
                                       DesignSystem.Colors.primaryPurple)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Task Type Badge
struct TaskTypeBadge: View {
    let taskType: TaskType
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: taskType.icon)
                .font(.system(size: 14, weight: .semibold))
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(taskType.gradient)
        .cornerRadius(20)
    }
}

// MARK: - Floating Action Button
struct FloatingCreateButton: View {
    @State private var isExpanded = false
    @State private var selectedType: TaskType?
    let onSelectType: (TaskType) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background overlay when expanded
            if isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }
            }
            
            VStack(alignment: .trailing, spacing: 16) {
                // Task type options
                if isExpanded {
                    ForEach(TaskType.allCases, id: \.self) { type in
                        TaskTypeOption(type: type) {
                            selectedType = type
                            withAnimation(.spring()) {
                                isExpanded = false
                            }
                            onSelectType(type)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Main button
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            isExpanded ? Color.gray : 
                            LinearGradient(
                                colors: [DesignSystem.Colors.primaryGreen, DesignSystem.Colors.primaryBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .rotationEffect(.degrees(isExpanded ? 45 : 0))
                }
            }
        }
    }
}

// MARK: - Task Type Option
struct TaskTypeOption: View {
    let type: TaskType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(type.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(type.gradient)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Modern Tab Bar
struct ModernTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                if index == 2 {
                    // Empty space for floating button
                    Spacer()
                        .frame(width: 56)
                } else {
                    TabBarItem(
                        icon: tabIcon(for: index),
                        isSelected: selectedTab == index
                    ) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
        )
    }
    
    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "map.fill"
        case 3: return "bubble.left.fill"
        case 4: return "person.crop.circle.fill"
        default: return ""
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryGreen : DesignSystem.Colors.textSecondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                if isSelected {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGreen)
                        .frame(width: 5, height: 5)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Redesigned Home Feed
struct RedesignedHomeFeed: View {
    @State private var selectedTab = 0
    @State private var tasks: [(TaskType, String, String, String, String)] = [
        (.karma, "Help me move furniture", "Need 2 people to help move some furniture to my new apartment", "25", "Cambridge, MA"),
        (.cash, "iOS App Development", "Looking for developer to build a simple app", "$150", "Remote"),
        (.fun, "Basketball Pickup Game", "Join us for friendly basketball this weekend", "Fun!", "MIT Courts"),
        (.karma, "Teach Guitar Basics", "Can teach beginners guitar in exchange for karma", "30", "Boston, MA")
    ]
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Text("Good morning! 👋")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                        
                        // Notification bell
                        Button(action: {}) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "All", isSelected: true)
                            FilterChip(title: "Karma", isSelected: false)
                            FilterChip(title: "Paid", isSelected: false)
                            FilterChip(title: "Fun", isSelected: false)
                            FilterChip(title: "Nearby", isSelected: false)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Task cards
                    VStack(spacing: 16) {
                        ForEach(0..<tasks.count, id: \.self) { index in
                            let task = tasks[index]
                            ModernTaskCard(
                                taskType: task.0,
                                title: task.1,
                                description: task.2,
                                value: task.3,
                                location: task.4,
                                timeAgo: "2h ago",
                                userName: "John Doe"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingCreateButton { type in
                        print("Selected type: \(type)")
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
            
            // Tab bar
            VStack {
                Spacer()
                ModernTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? DesignSystem.Colors.primaryGreen : Color.white
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : DesignSystem.Colors.backgroundSecondary, lineWidth: 1)
            )
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RedesignedHomeFeed()
    }
}