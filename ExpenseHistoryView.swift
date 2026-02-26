import SwiftUI

struct ExpenseHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseManager: ExpenseManager
    @ObservedObject var authManager: AuthenticationManager
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary Card
                        VStack(spacing: 12) {
                            Text("This Month")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("$\(Int(expenseManager.getTotalSpentThisMonth()))")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(expenseManager.expenses.count) transactions")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.3, blue: 0.8),
                                    Color(red: 0.3, green: 0.5, blue: 0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.3), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // All Expenses
                        VStack(alignment: .leading, spacing: 16) {
                            Text("All Transactions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appPrimaryText)
                                .padding(.horizontal, 24)
                            
                            if expenseManager.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if expenseManager.expenses.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    Text("No expenses yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("Tap the + button to add your first expense")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(expenseManager.expenses) { expense in
                                        ExpenseHistoryRow(expense: expense)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    expenseManager.deleteExpense(expense)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Expense History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if let url = expenseManager.shareExpenses() {
                            shareURL = url
                            showShareSheet = true
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Expense History Row
struct ExpenseHistoryRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: expense.category.icon)
                .font(.system(size: 20))
                .foregroundColor(categoryColor(expense.category.color))
                .frame(width: 44, height: 44)
                .background(categoryColor(expense.category.color).opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
                
                HStack(spacing: 8) {
                    Text(expense.category.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(expense.date, style: .date)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text("-$\(Int(expense.amount))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appPrimaryText)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func categoryColor(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return .orange
        case "purple": return .purple
        case "blue": return .blue
        case "pink": return .pink
        case "red": return .red
        case "brown": return .brown
        case "green": return Color(red: 0.2, green: 0.7, blue: 0.3)
        default: return .gray
        }
    }
}

#Preview {
    ExpenseHistoryView(
        expenseManager: ExpenseManager(),
        authManager: AuthenticationManager()
    )
}
