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
        // Primary Colors
        static let primaryGreen = Color(hex: "00C896")
        static let primaryBlue = Color(hex: "0066FF")
        static let primaryOrange = Color(hex: "FF6B35")
        static let primaryPurple = Color(hex: "8B5CF6")
        
        // Background Colors
        static let backgroundPrimary = Color(hex: "FAFBFC")
        static let backgroundSecondary = Color(hex: "F3F4F6")
        static let surface = Color.white
        
        // Text Colors
        static let textPrimary = Color(hex: "1F2937")
        static let textSecondary = Color(hex: "6B7280")
        static let textTertiary = Color(hex: "9CA3AF")
        
        // Gradients
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
        
        static let primaryGradient = LinearGradient(
            colors: [primaryGreen, primaryBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    struct Typography {
        // Headers
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
        static let title1 = Font.system(size: 22, weight: .bold, design: .default)
        static let title2 = Font.system(size: 20, weight: .semibold, design: .default)
        static let title3 = Font.system(size: 18, weight: .semibold, design: .default)
        
        // Body
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let bodySemibold = Font.system(size: 16, weight: .semibold, design: .default)
        
        // Small text
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 12, weight: .medium, design: .default)
        
        // Numbers (rounded design)
        static let numberLarge = Font.system(size: 20, weight: .bold, design: .rounded)
        static let numberMedium = Font.system(size: 16, weight: .bold, design: .rounded)
        static let numberSmall = Font.system(size: 14, weight: .bold, design: .rounded)
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let pill: CGFloat = 25
    }
}

// MARK: - TaskType Enum
enum TaskType: String, Codable, CaseIterable {
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
    
    var primaryColor: Color {
        switch self {
        case .karma: return DesignSystem.Colors.primaryBlue
        case .cash: return DesignSystem.Colors.primaryOrange
        case .fun: return DesignSystem.Colors.primaryPurple
        }
    }
    
    var displayName: String {
        switch self {
        case .karma: return "Karma"
        case .cash: return "Paid"
        case .fun: return "Fun"
        }
    }
    
    var description: String {
        switch self {
        case .karma: return "Community help, earn karma"
        case .cash: return "Paid tasks, real money"
        case .fun: return "Social activities, no reward"
        }
    }
    
}