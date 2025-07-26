import SwiftUI

struct KarmaHistoryView: View {
    @StateObject private var viewModel = KarmaHistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    ProgressView("Loading transactions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.transactions.isEmpty {
                    KarmaEmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.transactions) { transaction in
                                TransactionRowView(transaction: transaction)
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadTransactions()
                    }
                }
            }
            .navigationTitle("Karma History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error ?? "An error occurred")
            }
        }
        .task {
            await viewModel.loadTransactions()
        }
    }
}

// MARK: - Helper Functions
private func getTransactionIcon(for type: TransactionType) -> String {
    switch type.rawValue {
    case "reward":
        return "gift.fill"
    case "post_creation":
        return "square.and.pencil"
    case "post_completion":
        return "checkmark.circle.fill"
    case "transfer":
        return "arrow.left.arrow.right"
    case "system_bonus":
        return "star.fill"
    case "referral":
        return "person.2.fill"
    case "earned":
        return "arrow.down.circle.fill"
    case "given":
        return "arrow.up.circle.fill"
    case "bonus":
        return "star.circle.fill"
    default:
        return "questionmark.circle"
    }
}

private func getTransactionDescription(for transaction: KarmaTransaction) -> String {
    switch transaction.type.rawValue {
    case "reward":
        return "Karma reward"
    case "post_creation":
        return "Created a post"
    case "post_completion":
        return "Completed a task"
    case "transfer":
        if transaction.amount > 0 {
            return "Received karma"
        } else {
            return "Sent karma"
        }
    case "system_bonus":
        return "System bonus"
    case "referral":
        return "Referral bonus"
    case "earned":
        return "Earned karma"
    case "given":
        return "Given karma"
    case "bonus":
        return "Bonus karma"
    default:
        return "Transaction"
    }
}

private func getTransactionTypeName(for type: TransactionType) -> String {
    switch type.rawValue {
    case "reward":
        return "Reward"
    case "post_creation":
        return "Post Creation"
    case "post_completion":
        return "Task Completion"
    case "transfer":
        return "Transfer"
    case "system_bonus":
        return "System Bonus"
    case "referral":
        return "Referral Bonus"
    case "earned":
        return "Earned"
    case "given":
        return "Given"
    case "bonus":
        return "Bonus"
    default:
        return "Transaction"
    }
}

private func timeAgoDisplay(from date: Date) -> String {
    let now = Date()
    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
    
    if let years = components.year, years > 0 {
        return "\(years) year\(years > 1 ? "s" : "") ago"
    } else if let months = components.month, months > 0 {
        return "\(months) month\(months > 1 ? "s" : "") ago"
    } else if let days = components.day, days > 0 {
        return "\(days) day\(days > 1 ? "s" : "") ago"
    } else if let hours = components.hour, hours > 0 {
        return "\(hours) hour\(hours > 1 ? "s" : "") ago"
    } else if let minutes = components.minute, minutes > 0 {
        return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
    } else {
        return "Just now"
    }
}

// MARK: - Transaction Row View
struct TransactionRowView: View {
    let transaction: KarmaTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(transaction.amount > 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: getTransactionIcon(for: transaction.type))
                    .font(.system(size: 20))
                    .foregroundColor(transaction.amount > 0 ? .green : .red)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(getTransactionDescription(for: transaction))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(getTransactionTypeName(for: transaction.type))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(timeAgoDisplay(from: transaction.createdAt))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount
            Text("\(transaction.amount > 0 ? "+" : "")\(transaction.amount)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(transaction.amount > 0 ? .green : .red)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - View Model
@MainActor
class KarmaHistoryViewModel: ObservableObject {
    @Published var transactions: [KarmaTransaction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiService = APIService.shared
    
    func loadTransactions() async {
        isLoading = true
        error = nil
        
        do {
            guard let idToken = await AuthManager.shared.getIDToken() else {
                throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            }
            
            transactions = try await apiService.getKarmaTransactions(idToken)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Preview
// MARK: - Empty State View
struct KarmaEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Transactions Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your karma transaction history will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
struct KarmaHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        KarmaHistoryView()
    }
}
