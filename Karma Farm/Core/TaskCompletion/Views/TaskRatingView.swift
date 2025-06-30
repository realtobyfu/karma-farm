import SwiftUI

struct TaskRatingView: View {
    let post: Post
    @ObservedObject var viewModel: TaskCompletionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var animateStars = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Success Animation
                    successAnimation
                    
                    // Rating Section
                    ratingSection
                    
                    // Tags Section
                    tagsSection
                    
                    // Review Section
                    reviewSection
                    
                    // Submit Button
                    submitButton
                }
                .padding()
            }
            .background(DesignSystem.Colors.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Rate Your Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateStars = true
            }
        }
    }
    
    private var successAnimation: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(post.taskType.gradient)
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateStars ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateStars)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateStars ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateStars)
            }
            
            Text("Task Completed!")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .opacity(animateStars ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.3), value: animateStars)
            
            if post.taskType == .karma {
                HStack {
                    Image(systemName: "star.fill")
                    Text("+\(post.karmaValue) karma earned")
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(post.taskType.primaryColor)
                .opacity(animateStars ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.4), value: animateStars)
            }
        }
    }
    
    private var ratingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("How was your experience?")
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= viewModel.selectedRating ? "star.fill" : "star")
                        .font(.title)
                        .foregroundColor(star <= viewModel.selectedRating ? Color.yellow : Color(UIColor.systemGray3))
                        .scaleEffect(star <= viewModel.selectedRating ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedRating)
                        .onTapGesture {
                            viewModel.selectedRating = star
                            #if os(iOS)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            #endif
                        }
                }
            }
            
            Text(ratingText)
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .animation(.easeInOut, value: viewModel.selectedRating)
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.medium)
    }
    
    private var ratingText: String {
        switch viewModel.selectedRating {
        case 1: return "Poor experience"
        case 2: return "Below average"
        case 3: return "Average"
        case 4: return "Good experience"
        case 5: return "Excellent experience!"
        default: return ""
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("What went well?")
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: DesignSystem.Spacing.sm) {
                ForEach(HelpfulnessTag.allCases, id: \.self) { tag in
                    TagButton(
                        tag: tag,
                        isSelected: viewModel.selectedTags.contains(tag),
                        taskType: post.taskType
                    ) {
                        if viewModel.selectedTags.contains(tag) {
                            viewModel.selectedTags.remove(tag)
                        } else {
                            viewModel.selectedTags.insert(tag)
                        }
                        #if os(iOS)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        #endif
                    }
                }
            }
        }
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Additional feedback (optional)")
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            TextEditor(text: $viewModel.reviewText)
                .frame(minHeight: 100)
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.backgroundSecondary)
                .cornerRadius(DesignSystem.Radius.small)
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitRating()
                if viewModel.error == nil {
                    dismiss()
                }
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Submit Rating")
                }
            }
            .font(DesignSystem.Typography.bodySemibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(post.taskType.gradient)
            .cornerRadius(DesignSystem.Radius.medium)
        }
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Tag Button Component
struct TagButton: View {
    let tag: HelpfulnessTag
    let isSelected: Bool
    let taskType: TaskType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: tag.icon)
                    .font(.caption)
                Text(tag.displayName)
                    .font(DesignSystem.Typography.caption)
            }
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? taskType.gradient : LinearGradient(colors: [Color(UIColor.systemGray5)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(DesignSystem.Radius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.pill)
                    .stroke(Color(UIColor.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}