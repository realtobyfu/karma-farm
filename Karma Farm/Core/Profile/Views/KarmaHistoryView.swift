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
                    EmptyStateView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "No Transactions Yet",
                        message: "Your karma transaction history will appear here"
                    )
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

// MARK: - Transaction Row View
struct TransactionRowView: View {
    let transaction: KarmaTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(transaction.isIncoming ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(transaction.isIncoming ? .green : .red)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayDescription)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(transaction.type.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(transaction.createdAt.timeAgoDisplay())
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount
            Text(transaction.displayAmount)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(transaction.isIncoming ? .green : .red)
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
struct KarmaHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        KarmaHistoryView()
    }
}