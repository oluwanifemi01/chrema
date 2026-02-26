//
//  BudgetPreferencesView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/24/26.
//
import SwiftUI

struct BudgetPreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var categoryManager = BudgetCategoryManager()
    let budget: BudgetItem
    
    @State private var showAddCategory = false
    @State private var categoryToEdit: CustomBudgetCategory?
    
    var totalIncome: Double {
        Double(authManager.userData?.monthlyIncome ?? "0") ?? 0
    }
    
    var fixedExpenses: Double {
        guard let userData = authManager.userData else { return 0 }
        let rent = Double(userData.rent) ?? 0
        let utilities = Double(userData.utilities) ?? 0
        let phone = Double(userData.phone) ?? 0
        let transport = Double(userData.transportation) ?? 0
        let subscriptions = Double(userData.subscriptions) ?? 0
        return rent + utilities + phone + transport + subscriptions
    }
    
    var coreBudget: Double {
        var total = budget.monthlyFood + budget.monthlyMiscellaneous + budget.monthlySavings
        
        // Add pets
        if let pets = authManager.userData?.pets {
            total += pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
        }
        
        // Add kids
        if let kidExpenses = authManager.userData?.monthlyKidExpenses {
            total += Double(kidExpenses) ?? 0
        }
        
        return total
    }
    
    var totalAllocated: Double {
        return coreBudget + categoryManager.getTotalCustomBudget()
    }
    
    var remainingBudget: Double {
        return totalIncome - fixedExpenses - totalAllocated
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Budget Summary Card
                        VStack(spacing: 16) {
                            Text("Monthly Budget")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                AnimatedNumber(value: totalAllocated, format: .currency)
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("/ $\(Int(totalIncome - fixedExpenses))")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Allocated")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("$\(Int(totalAllocated))")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                    .background(Color.white.opacity(0.3))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Remaining")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("$\(Int(remainingBudget))")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(remainingBudget < 0 ? .red : .white)
                                }
                            }
                            
                            if remainingBudget < 0 {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    
                                    Text("Over budget by $\(Int(abs(remainingBudget)))")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(24)
                        .background(Color.appGradient)
                        .cornerRadius(20)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Core Categories
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Core Categories")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primaryText)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                CoreCategoryCard(
                                    icon: "fork.knife",
                                    name: "Food & Groceries",
                                    amount: budget.monthlyFood,
                                    color: .orange
                                )
                                
                                CoreCategoryCard(
                                    icon: "sparkles",
                                    name: "Entertainment",
                                    amount: budget.monthlyMiscellaneous,
                                    color: .purple
                                )
                                
                                CoreCategoryCard(
                                    icon: "dollarsign.circle.fill",
                                    name: "Savings",
                                    amount: budget.monthlySavings,
                                    color: .green
                                )
                                
                                // Pets if applicable
                                if let pets = authManager.userData?.pets, !pets.isEmpty {
                                    let petExpenses = pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
                                    CoreCategoryCard(
                                        icon: "pawprint.fill",
                                        name: "Pets",
                                        amount: petExpenses,
                                        color: .brown
                                    )
                                }
                                
                                // Kids if applicable
                                if let hasKids = authManager.userData?.hasKids, hasKids {
                                    let kidExpenses = Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
                                    CoreCategoryCard(
                                        icon: "figure.2.and.child.holdinghands",
                                        name: "Kids",
                                        amount: kidExpenses,
                                        color: Color(red: 0.2, green: 0.7, blue: 0.3)
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Custom Categories
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Custom Categories")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primaryText)
                                
                                Spacer()
                                
                                if !categoryManager.customCategories.isEmpty {
                                    Text("\(categoryManager.customCategories.count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondaryText)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.cardBackground)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            if categoryManager.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if categoryManager.customCategories.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondaryText)
                                    
                                    Text("No custom categories yet")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primaryText)
                                    
                                    Text("Add categories for coffee, gym, hobbies, etc.")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(categoryManager.customCategories) { category in
                                        CustomCategoryCard(category: category) {
                                            categoryToEdit = category
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // Add Category Button
                            Button(action: {
                                showAddCategory = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                    
                                    Text("Add Custom Category")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Spacer()
                                }
                                .foregroundColor(.accentPurple)
                                .padding(20)
                                .background(Color.cardBackground)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Budget Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accentPurple)
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(
                    categoryManager: categoryManager,
                    remainingBudget: remainingBudget,
                    totalIncome: totalIncome
                )
            }
            .sheet(item: $categoryToEdit) { category in
                EditCategoryView(
                    categoryManager: categoryManager,
                    category: category,
                    remainingBudget: remainingBudget + category.monthlyBudget
                )
            }
            .onAppear {
                categoryManager.loadCategories()
            }
        }
    }
}

// MARK: - Core Category Card
struct CoreCategoryCard: View {
    let icon: String
    let name: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                Text("Core category")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            AnimatedNumber(value: amount, format: .currency)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primaryText)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondaryText.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Custom Category Card
struct CustomCategoryCard: View {
    let category: CustomBudgetCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(categoryColor(category.color))
                    .frame(width: 44, height: 44)
                    .background(categoryColor(category.color).opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryText)
                    
                    Text("Custom category")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    AnimatedNumber(value: category.monthlyBudget, format: .currency)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(categoryColor(category.color).opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    func categoryColor(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return .orange
        case "purple": return .purple
        case "blue": return .blue
        case "pink": return .pink
        case "red": return .red
        case "brown": return .brown
        case "green": return .green
        case "yellow": return .yellow
        case "teal": return .teal
        case "indigo": return .indigo
        case "cyan": return .cyan
        case "mint": return Color(red: 0.4, green: 0.9, blue: 0.7)
        default: return .gray
        }
    }
}

#Preview {
    BudgetPreferencesView(
        authManager: AuthenticationManager(),
        budget: BudgetItem(
            monthlyFood: 450,
            monthlyMiscellaneous: 300,
            monthlySavings: 500,
            remainingMoney: 250,
            savingsPercentage: 20,
            personalizedAdvice: "Great!",
            breakdown: "Good"
        )
    )
}
