import SwiftUI

struct TaskAcceptanceView: View {
    let post: Post
    @StateObject private var viewModel: TaskCompletionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var proposedDate = Date()
    @State private var message = ""
    @State private var showDatePicker = false
    
    init(post: Post) {
        self.post = post
        self._viewModel = StateObject(wrappedValue: TaskCompletionViewModel(post: post))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Task Header
                    taskHeader
                    
                    // Task Details
                    taskDetails
                    
                    // Acceptance Form
                    acceptanceForm
                    
                    // Accept Button
                    acceptButton
                }
                .padding()
            }
            .background(DesignSystem.Colors.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Accept Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var taskHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Task Type Badge
            HStack {
                Image(systemName: post.taskType.icon)
                Text(post.taskType.displayName)
                    .font(DesignSystem.Typography.captionMedium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(post.taskType.gradient)
            .clipShape(Capsule())
            
            // Task Title
            Text(post.title)
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Task Value
            Text(post.displayValue)
                .font(DesignSystem.Typography.numberLarge)
                .foregroundColor(post.taskType.primaryColor)
        }
    }
    
    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Description
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Description")
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(post.description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Divider()
            
            // Posted By
            if let user = post.user {
                HStack {
                    AsyncImage(url: URL(string: user.profilePicture ?? "")) { image  in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("\(user.karmaBalance) karma")
                                .font(DesignSystem.Typography.caption)
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Location
            if let locationName = post.locationName {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Text(locationName)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.medium)
    }
    
    private var acceptanceForm: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Acceptance Details")
                .font(DesignSystem.Typography.bodySemibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            // Proposed Completion Date
            if post.taskType != .fun {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("When can you complete this?")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(proposedDate, style: .date)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .padding()
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .cornerRadius(DesignSystem.Radius.small)
                    }
                }
            }
            
            // Message
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Message (optional)")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                TextEditor(text: $message)
                    .frame(minHeight: 80)
                    .padding(DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .cornerRadius(DesignSystem.Radius.small)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePicker("Select Date", selection: $proposedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .presentationDetents([.medium])
        }
    }
    
    private var acceptButton: some View {
        Button(action: {
            Task {
                await viewModel.acceptTask()
                dismiss()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Accept Task")
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
