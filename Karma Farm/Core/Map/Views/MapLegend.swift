import SwiftUI

struct MapLegend: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reward Types")
                        .font(DesignSystem.Typography.bodySemibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    ForEach(RewardType.allCases, id: \.self) { rewardType in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(rewardType.gradient)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            
                            Text(rewardType.displayName)
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Spacer()
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("Request")
                            .font(DesignSystem.Typography.footnote)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primaryGreen)
                        Text("Offer")
                            .font(DesignSystem.Typography.footnote)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding()
                .background(DesignSystem.Colors.surface)
                .cornerRadius(DesignSystem.Radius.medium)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
            }
            
            // Legend toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                    if !isExpanded {
                        Text("Legend")
                            .font(DesignSystem.Typography.caption)
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, isExpanded ? 8 : 12)
                .padding(.vertical, 6)
                .background(DesignSystem.Colors.primaryGradient)
                .clipShape(Capsule())
                .shadow(color: DesignSystem.Colors.primaryBlue.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .padding()
    }
}