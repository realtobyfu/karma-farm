import SwiftUI
import MapKit

enum MapStyleType: String, CaseIterable, Equatable {
    case standard = "Standard"
    case satellite = "Satellite"
    case transit = "Transit"
    
    var icon: String {
        switch self {
        case .standard: return "map"
        case .satellite: return "globe.americas.fill"
        case .transit: return "tram.fill"
        }
    }
    
    var mapStyle: MKMapType {
        switch self {
        case .standard: return .standard
        case .satellite: return .hybrid
        case .transit: return .standard
        }
    }
}

struct MapStyleToggle: View {
    @State private var isExpanded = false
    @State private var selectedStyle: MapStyleType = .standard
    
    var body: some View {
        VStack(spacing: 8) {
            if isExpanded {
                ForEach(MapStyleType.allCases, id: \.self) { style in
                    Button(action: {
                        selectedStyle = style
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }) {
                        Image(systemName: style.icon)
                            .font(.system(size: 16))
                            .foregroundColor(selectedStyle == style ? .white : DesignSystem.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                selectedStyle == style ? 
                                DesignSystem.Colors.primaryGradient : 
                                LinearGradient(colors: [Color(UIColor.systemBackground)], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(UIColor.systemGray4), lineWidth: selectedStyle == style ? 0 : 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Main toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "map")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.primaryGradient)
                    .clipShape(Circle())
                    .shadow(color: DesignSystem.Colors.primaryBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
        }
        .padding(.vertical, 8)
    }
}