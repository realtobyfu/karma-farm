import SwiftUI
import MapKit

struct MapStyleToggle: View {
    @State private var isExpanded = false
    @State private var selectedStyle: MapStyle = .standard
    
    private let styles: [(name: String, icon: String, style: MapStyle)] = [
        ("Standard", "map", .standard),
        ("Satellite", "globe.americas.fill", .hybrid),
        ("Transit", "tram.fill", .standard)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            if isExpanded {
                ForEach(styles, id: \.name) { item in
                    Button(action: {
                        selectedStyle = item.style
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16))
                            .foregroundColor(selectedStyle == item.style ? .white : DesignSystem.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                selectedStyle == item.style ? 
                                DesignSystem.Colors.primaryGradient : 
                                Color(UIColor.systemBackground)
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(UIColor.systemGray4), lineWidth: selectedStyle == item.style ? 0 : 1)
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