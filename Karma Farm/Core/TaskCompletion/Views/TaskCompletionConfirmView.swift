import SwiftUI

struct TaskCompletionConfirmView: View {
    let post: Post
    @StateObject private var viewModel: TaskCompletionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var completionNotes = ""
    @State private var showingRatingView = false
    @State private var actualTimeSpent = 0
    @State private var showTimeAdjustment = false
    @State private var timeAdjustmentOption: TimeAdjustmentOption = .giftExtraTime
    
    init(post: Post) {
        self.post = post
        self._viewModel = StateObject(wrappedValue: TaskCompletionViewModel(post: post))
        // Initialize actual time with estimated time
        self._actualTimeSpent = State(initialValue: post.karmaValue ?? 0)
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
                            .fill(item.isCompleted ? post.rewardType.gradient : LinearGradient(colors: [Color(UIColor.systemGray5)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 32, height: 32)
                        
                        if item.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        } else {
                            Text("\(item.stepNumber)")
                                .font(.caption.bold())
                                .foregroundColor(item.isCurrent ? post.rewardType.primaryColor : DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    // Connector Line
                    if item.stepNumber < progressSteps.count {
                        Rectangle()
                            .fill(item.isCompleted ? post.rewardType.primaryColor : Color(UIColor.systemGray5))
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
                .foregroundStyle(post.rewardType.gradient)
            
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
                    .foregroundColor(post.rewardType.primaryColor)
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
                    
                    // Time tracking section
                    if post.rewardType == .karma {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Actual Time Spent")
                                .font(DesignSystem.Typography.bodySemibold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            HStack {
                                Text("Estimated: \(post.karmaValue ?? 0) minutes")
                                    .font(DesignSystem.Typography.footnote)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Spacer()
                                
                                if actualTimeSpent != (post.karmaValue ?? 0) {
                                    Text(actualTimeSpent > (post.karmaValue ?? 0) ? "+\(actualTimeSpent - (post.karmaValue ?? 0)) min" : "-\((post.karmaValue ?? 0) - actualTimeSpent) min")
                                        .font(DesignSystem.Typography.footnote)
                                        .foregroundColor(actualTimeSpent > (post.karmaValue ?? 0) ? .orange : .green)
                                }
                            }
                            
                            // Time preset buttons
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach([15, 30, 45, 60, 90, 120, 180, 240], id: \.self) { minutes in
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                actualTimeSpent = minutes
                                                showTimeAdjustment = minutes != (post.karmaValue ?? 0)
                                            }
                                        }) {
                                            Text("\(minutes)m")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(actualTimeSpent == minutes ? .white : DesignSystem.Colors.primaryGreen)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(actualTimeSpent == minutes ? DesignSystem.Colors.primaryGreen : Color(.systemGray6))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(DesignSystem.Colors.primaryGreen.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            
                            // Custom time slider
                            VStack(spacing: 4) {
                                Slider(value: Binding(
                                    get: { Double(actualTimeSpent) },
                                    set: { 
                                        actualTimeSpent = Int($0)
                                        showTimeAdjustment = actualTimeSpent != (post.karmaValue ?? 0)
                                    }
                                ), in: 15...360, step: 5)
                                .accentColor(DesignSystem.Colors.primaryGreen)
                                
                                Text("\(actualTimeSpent) minutes = \(actualTimeSpent) karma")
                                    .font(.system(size: 11))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                        .padding()
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .cornerRadius(DesignSystem.Radius.small)
                        
                        // Time adjustment options if time differs
                        if showTimeAdjustment {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Time Adjustment")
                                    .font(DesignSystem.Typography.bodySemibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                ForEach(TimeAdjustmentOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        withAnimation {
                                            timeAdjustmentOption = option
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: timeAdjustmentOption == option ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(timeAdjustmentOption == option ? DesignSystem.Colors.primaryGreen : .gray)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(option.title)
                                                    .font(DesignSystem.Typography.bodyMedium)
                                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                                
                                                Text(option.description(estimatedMinutes: post.karmaValue ?? 0, actualMinutes: actualTimeSpent))
                                                    .font(DesignSystem.Typography.caption)
                                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                            .background(DesignSystem.Colors.backgroundSecondary)
                            .cornerRadius(DesignSystem.Radius.small)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            let adjustedKarma = timeAdjustmentOption.calculateAdjustedKarma(
                                estimated: post.karmaValue ?? 0,
                                actual: actualTimeSpent
                            )
                            await viewModel.markAsCompleted(
                                notes: completionNotes.isEmpty ? nil : completionNotes,
                                actualTimeMinutes: actualTimeSpent,
                                adjustedKarma: adjustedKarma
                            )
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
                        .background(post.rewardType.gradient)
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

enum TimeAdjustmentOption: String, CaseIterable {
    case giftExtraTime = "gift_extra_time"
    case requestAdjustment = "request_adjustment"
    case splitDifference = "split_difference"
    
    var title: String {
        switch self {
        case .giftExtraTime:
            return "Gift the extra time"
        case .requestAdjustment:
            return "Request karma adjustment"
        case .splitDifference:
            return "Split the difference"
        }
    }
    
    func description(estimatedMinutes: Int, actualMinutes: Int) -> String {
        let difference = abs(actualMinutes - estimatedMinutes)
        
        switch self {
        case .giftExtraTime:
            if actualMinutes > estimatedMinutes {
                return "No extra karma for the additional \(difference) minutes"
            } else {
                return "Keep the full \(estimatedMinutes) karma payment"
            }
        case .requestAdjustment:
            if actualMinutes > estimatedMinutes {
                return "Request \(difference) extra karma from the requester"
            } else {
                return "Return \(difference) karma to the requester"
            }
        case .splitDifference:
            let splitAmount = difference / 2
            if actualMinutes > estimatedMinutes {
                return "Request \(splitAmount) extra karma (half of \(difference))"
            } else {
                return "Return \(splitAmount) karma (half of \(difference))"
            }
        }
    }
    
    func calculateAdjustedKarma(estimated: Int, actual: Int) -> Int {
        switch self {
        case .giftExtraTime:
            return estimated // No adjustment
        case .requestAdjustment:
            return actual // Full actual time
        case .splitDifference:
            return (estimated + actual) / 2 // Average of both
        }
    }
}