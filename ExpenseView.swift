//
//  ExpenseView.swift
//  Chrema
//
//  Created by Oluwanifemi Oloyede on 2/22/26.
//
import SwiftUI

struct ExpensesView: View {
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var expenseManager = ExpenseManager()
    @State private var showAddExpense = false
    let budget: BudgetItem
    var hideFloatingButton: Bool = false
    
    var foodBudget: Double { budget.monthlyFood }
    var entertainmentBudget: Double { budget.monthlyMiscellaneous }
    
    var foodSpent: Double {
        expenseManager.getSpendingByCategory()[.food] ?? 0
    }
    
    var entertainmentSpent: Double {
        expenseManager.getSpendingByCategory()[.entertainment] ?? 0
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Expenses")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.appPrimaryText)
                        
                        Text("Track your spending")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    
                    // Summary Card
                    VStack(spacing: 16) {
                        Text("This Month")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("$\(Int(expenseManager.getTotalSpentThisMonth()))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Total Spent")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
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
                    .cornerRadius(24)
                    .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 24)
                    
                    // Budget Progress Cards
                    VStack(spacing: 16) {
                        BudgetProgressCard(
                            category: "Food & Groceries",
                            icon: "fork.knife",
                            spent: foodSpent,
                            budget: foodBudget,
                            color: .orange
                        )
                        
                        BudgetProgressCard(
                            category: "Entertainment",
                            icon: "sparkles",
                            spent: entertainmentSpent,
                            budget: entertainmentBudget,
                            color: .purple
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Recent Expenses
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Expenses")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appPrimaryText)
                            
                            Spacer()
                            
                            if !expenseManager.expenses.isEmpty {
                                Text("\(expenseManager.expenses.count) total")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
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
                                ForEach(expenseManager.expenses.prefix(10)) { expense in
                                    ExpenseRow(expense: expense)
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
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Floating Add Button
            if !hideFloatingButton {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showAddExpense = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.4, green: 0.3, blue: 0.8),
                                                    Color(red: 0.3, green: 0.5, blue: 0.9)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.98, green: 0.98, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(expenseManager: expenseManager, authManager: authManager, budget: budget)
        }
        .onAppear {
            expenseManager.loadExpenses()
        }
    }
}

// MARK: - Budget Progress Card
struct BudgetProgressCard: View {
    let category: String
    let icon: String
    let spent: Double
    let budget: Double
    let color: Color
    
    var percentage: Double {
        guard budget > 0 else { return 0 }
        return min((spent / budget) * 100, 100)
    }
    
    var remaining: Double {
        max(budget - spent, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimaryText)
                    
                    Text("$\(Int(spent)) of $\(Int(budget))")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(percentage))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(percentage > 90 ? .red : .black)
                    
                    Text("$\(Int(remaining)) left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(percentage > 90 ? Color.red : color)
                        .frame(width: geometry.size.width * min(percentage / 100, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Expense Row
struct ExpenseRow: View {
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
        case "brown": return .brown  // ADD THIS
        case "green": return .green  // Make sure this is here
        default: return .gray
        }
    }
}

#Preview {
    ExpensesView(
        authManager: AuthenticationManager(),
        budget: BudgetItem(
            monthlyFood: 450,
            monthlyMiscellaneous: 300,
            monthlySavings: 500,
            remainingMoney: 250,
            savingsPercentage: 20,
            personalizedAdvice: "Great advice",
            breakdown: "Breakdown"
        ),
        hideFloatingButton: false
    )
}
