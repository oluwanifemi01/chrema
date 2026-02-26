import SwiftUI

struct RecurringExpensesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseManager: ExpenseManager
    
    var recurringExpenses: [Expense] {
        expenseManager.getRecurringExpenses()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Info
                        VStack(spacing: 12) {
                            Text("\(recurringExpenses.count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Recurring Expenses")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            let totalRecurring = recurringExpenses.reduce(0) { $0 + $1.amount }
                            Text("$\(Int(totalRecurring))/month total")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(Color.appGradient)
                        .cornerRadius(20)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Recurring Expenses List
                        VStack(alignment: .leading, spacing: 16) {
                            if recurringExpenses.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "arrow.clockwise.circle")
                                        .font(.system(size: 48))
                                        .foregroundColor(.appSecondaryText)
                                    
                                    Text("No recurring expenses yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appPrimaryText)
                                    
                                    Text("Set up monthly bills to auto-track")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.appSecondaryText)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(recurringExpenses) { expense in
                                    RecurringExpenseCard(expense: expense)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                expenseManager.deleteExpense(expense)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Recurring Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.customAccentPurple)
                }
            }
        }
    }
}

// MARK: - Recurring Expense Card
struct RecurringExpenseCard: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: expense.category.icon)
                .font(.system(size: 20))
                .foregroundColor(categoryColor(expense.category.color))
                .frame(width: 44, height: 44)
                .background(categoryColor(expense.category.color).opacity(0.1))
                .cornerRadius(12)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
                
                HStack(spacing: 8) {
                    Image(systemName: expense.recurringFrequency?.icon ?? "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.appSecondaryText)
                    
                    Text(expense.recurringFrequency?.rawValue ?? "Monthly")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appSecondaryText)
                    
                    Text("•")
                        .foregroundColor(.appSecondaryText.opacity(0.5))
                    
                    Text(expense.category.rawValue)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.appSecondaryText)
                }
            }
            
            Spacer()
            
            // Amount
            Text("$\(Int(expense.amount))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appPrimaryText)
        }
        .padding(16)
        .background(Color.appCardBackground)
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
    RecurringExpensesView(expenseManager: ExpenseManager())
}
