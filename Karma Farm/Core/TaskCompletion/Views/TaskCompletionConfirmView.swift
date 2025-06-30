import SwiftUI

struct TaskCompletionConfirmView: View {
    let post: Post
    @StateObject private var viewModel: TaskCompletionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var completionNotes = ""
    @State private var showingRatingView = false
    
    init(post: Post) {
        self.post = post
        self._viewModel = StateObject(wrappedValue: TaskCompletionViewModel(post: post))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Progress Indicator
                    progressIndicator
                    
                    // Current Status
                    statusCard
                    
                    // Action Section
                    actionSection
                }
                .padding()
            }
            .background(DesignSystem.Colors.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Task Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingRatingView) {
                TaskRatingView(post: post, viewModel: viewModel)
            }
            .onChange(of: viewModel.showRatingView) { newValue in
                showingRatingView = newValue
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            ForEach(progressSteps, id: \.step) { item in
                HStack(spacing: 0) {
                    // Step Circle
                    ZStack {
                        Circle()
                            .fill(item.isCompleted ? post.taskType.gradient : Color(UIColor.systemGray5))
                            .frame(width: 32, height: 32)
                        
                        if item.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        } else {
                            Text("\(item.stepNumber)")
                                .font(.caption.bold())
                                .foregroundColor(item.isCurrent ? post.taskType.primaryColor : DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    // Connector Line
                    if item.stepNumber < progressSteps.count {
                        Rectangle()
                            .fill(item.isCompleted ? post.taskType.primaryColor : Color(UIColor.systemGray5))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var progressSteps: [(step: CompletionStatus, stepNumber: Int, isCompleted: Bool, isCurrent: Bool)] {
        let allSteps: [CompletionStatus] = [.inProgress, .awaitingConfirmation, .confirmed]
        let currentIndex = allSteps.firstIndex(of: viewModel.completionStatus) ?? 0
        
        return allSteps.enumerated().map { index, step in
            (
                step: step,
                stepNumber: index + 1,
                isCompleted: index <= currentIndex,
                isCurrent: index == currentIndex
            )
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Status Icon
            Image(systemName: viewModel.completionStatus.icon)
                .font(.system(size: 48))
                .foregroundStyle(post.taskType.gradient)
            
            // Status Title
            Text(viewModel.completionStatus.displayName)
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            // Status Description
            Text(viewModel.progressDescription)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            // Task Info
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(post.title)
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(post.displayValue)
                    .font(DesignSystem.Typography.numberMedium)
                    .foregroundColor(post.taskType.primaryColor)
            }
            .padding()
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(DesignSystem.Radius.small)
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.medium)
    }
    
    private var actionSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // For task completer - Mark as completed
            if viewModel.canMarkCompleted {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Mark as Completed")
                        .font(DesignSystem.Typography.bodySemibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Add any notes about the completion (optional)")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    TextEditor(text: $completionNotes)
                        .frame(minHeight: 80)
                        .padding(DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .cornerRadius(DesignSystem.Radius.small)
                    
                    Button(action: {
                        Task {
                            await viewModel.markAsCompleted(notes: completionNotes.isEmpty ? nil : completionNotes)
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark as Completed")
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
            
            // For task owner - Confirm completion
            if viewModel.canConfirmCompletion {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Confirm Completion")
                        .font(DesignSystem.Typography.bodySemibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Please confirm that the task has been completed satisfactorily")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Button(action: {
                            // Handle dispute
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Dispute")
                            }
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(DesignSystem.Radius.medium)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.confirmCompletion()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Confirm")
                                }
                            }
                            .font(DesignSystem.Typography.bodySemibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.primaryGreen)
                            .cornerRadius(DesignSystem.Radius.medium)
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
            
            // Show error if any
            if let error = viewModel.error {
                Text(error)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(DesignSystem.Radius.small)
            }
        }
    }
}