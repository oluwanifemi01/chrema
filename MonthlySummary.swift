//
//  MonthlySummary.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/26/26.
//
import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// MARK: - Monthly Summary Model
struct MonthlySummary: Identifiable, Codable {
    var id = UUID().uuidString
    var userId: String
    var month: Int  // 1-12
    var year: Int
    var totalIncome: Double
    var totalSpent: Double
    var totalSaved: Double
    var savingsGoalMet: Bool
    var budgetCategories: [CategorySummary]
    var achievements: [String]
    var insights: [String]
    var createdAt: Date = Date()
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date()
        return formatter.string(from: date)
    }
    
    var savingsPercentage: Double {
        guard totalIncome > 0 else { return 0 }
        return (totalSaved / totalIncome) * 100
    }
    
    var spentPercentage: Double {
        guard totalIncome > 0 else { return 0 }
        return (totalSpent / totalIncome) * 100
    }
}

struct CategorySummary: Codable {
    var name: String
    var budgeted: Double
    var spent: Double
    var percentageUsed: Double
    var icon: String
    var color: String
    
    var wasOverBudget: Bool {
        spent > budgeted
    }
    
    var savedAmount: Double {
        max(budgeted - spent, 0)
    }
}

// MARK: - Monthly Summary Manager
class MonthlySummaryManager: ObservableObject {
    @Published var summaries: [MonthlySummary] = []
    @Published var currentMonthSummary: MonthlySummary?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Generate Current Month Summary
    func generateCurrentMonthSummary(
        authManager: AuthenticationManager,
        expenseManager: ExpenseManager,
        budget: BudgetItem
    ) {
        guard let userId = Auth.auth().currentUser?.uid,
              let userData = authManager.userData else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        // Calculate totals
        let totalIncome = Double(userData.monthlyIncome) ?? 0
        let totalSpent = expenseManager.getTotalSpentThisMonth()
        let savingsTarget = budget.monthlySavings
        let actualSavings = max(totalIncome - totalSpent, 0)
        
        // Get spending by category
        let spendingByCategory = expenseManager.getSpendingByCategory()
        
        // Build category summaries
        var categorySummaries: [CategorySummary] = []
        
        // Food
        categorySummaries.append(CategorySummary(
            name: "Food & Groceries",
            budgeted: budget.monthlyFood,
            spent: spendingByCategory[.food] ?? 0,
            percentageUsed: ((spendingByCategory[.food] ?? 0) / budget.monthlyFood) * 100,
            icon: "fork.knife",
            color: "orange"
        ))
        
        // Entertainment
        categorySummaries.append(CategorySummary(
            name: "Entertainment",
            budgeted: budget.monthlyMiscellaneous,
            spent: spendingByCategory[.entertainment] ?? 0,
            percentageUsed: ((spendingByCategory[.entertainment] ?? 0) / budget.monthlyMiscellaneous) * 100,
            icon: "sparkles",
            color: "purple"
        ))
        
        // Pets if applicable
        if !userData.pets.isEmpty {
            let petBudget = userData.pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
            categorySummaries.append(CategorySummary(
                name: "Pets",
                budgeted: petBudget,
                spent: spendingByCategory[.pets] ?? 0,
                percentageUsed: ((spendingByCategory[.pets] ?? 0) / petBudget) * 100,
                icon: "pawprint.fill",
                color: "brown"
            ))
        }
        
        // Kids if applicable
        if userData.hasKids {
            let kidBudget = Double(userData.monthlyKidExpenses) ?? 0
            if kidBudget > 0 {
                categorySummaries.append(CategorySummary(
                    name: "Kids",
                    budgeted: kidBudget,
                    spent: spendingByCategory[.kids] ?? 0,
                    percentageUsed: ((spendingByCategory[.kids] ?? 0) / kidBudget) * 100,
                    icon: "figure.2.and.child.holdinghands",
                    color: "green"
                ))
            }
        }
        
        // Generate achievements
        let achievements = generateAchievements(
            totalSpent: totalSpent,
            totalIncome: totalIncome,
            savingsTarget: savingsTarget,
            actualSavings: actualSavings,
            categorySummaries: categorySummaries
        )
        
        // Generate insights
        let insights = generateInsights(
            categorySummaries: categorySummaries,
            totalSpent: totalSpent,
            totalIncome: totalIncome
        )
        
        // Check if savings goal met
        let savingsGoalMet = actualSavings >= savingsTarget
        
        // Create summary
        let summary = MonthlySummary(
            userId: userId,
            month: month,
            year: year,
            totalIncome: totalIncome,
            totalSpent: totalSpent,
            totalSaved: actualSavings,
            savingsGoalMet: savingsGoalMet,
            budgetCategories: categorySummaries,
            achievements: achievements,
            insights: insights
        )
        
        DispatchQueue.main.async {
            self.currentMonthSummary = summary
        }
    }
    
    // MARK: - Save Summary to Firebase
    func saveSummary(_ summary: MonthlySummary) {
        let summaryData: [String: Any] = [
            "id": summary.id,
            "userId": summary.userId,
            "month": summary.month,
            "year": summary.year,
            "totalIncome": summary.totalIncome,
            "totalSpent": summary.totalSpent,
            "totalSaved": summary.totalSaved,
            "savingsGoalMet": summary.savingsGoalMet,
            "achievements": summary.achievements,
            "insights": summary.insights,
            "createdAt": Timestamp(date: summary.createdAt)
        ]
        
        db.collection("monthlySummaries").document(summary.id).setData(summaryData) { error in
            if let error = error {
                print("Error saving summary: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Load Past Summaries
    func loadSummaries() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("monthlySummaries")
            .whereField("userId", isEqualTo: userId)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .limit(to: 12)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading summaries: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                // Parse summaries (simplified for now)
                self.isLoading = false
            }
    }
    
    // MARK: - Generate Achievements
    private func generateAchievements(
        totalSpent: Double,
        totalIncome: Double,
        savingsTarget: Double,
        actualSavings: Double,
        categorySummaries: [CategorySummary]
    ) -> [String] {
        var achievements: [String] = []
        
        // Savings achievements
        if actualSavings >= savingsTarget {
            achievements.append("🎯 Hit your savings goal!")
        }
        
        let savingsPercentage = (actualSavings / totalIncome) * 100
        if savingsPercentage >= 20 {
            achievements.append("💎 Saved 20%+ of income")
        } else if savingsPercentage >= 15 {
            achievements.append("💰 Saved 15%+ of income")
        } else if savingsPercentage >= 10 {
            achievements.append("💵 Saved 10%+ of income")
        }
        
        // Under budget achievements
        let underBudgetCategories = categorySummaries.filter { !$0.wasOverBudget }
        if underBudgetCategories.count == categorySummaries.count {
            achievements.append("✨ Stayed under budget in ALL categories!")
        } else if underBudgetCategories.count >= categorySummaries.count / 2 {
            achievements.append("📊 Under budget in most categories")
        }
        
        // Specific category wins
        for category in categorySummaries {
            if category.percentageUsed < 80 {
                achievements.append("🎉 Only used \(Int(category.percentageUsed))% of \(category.name) budget")
            }
        }
        
        return achievements
    }
    
    // MARK: - Generate Insights
    private func generateInsights(
        categorySummaries: [CategorySummary],
        totalSpent: Double,
        totalIncome: Double
    ) -> [String] {
        var insights: [String] = []
        
        // Over budget insights
        let overBudgetCategories = categorySummaries.filter { $0.wasOverBudget }
        for category in overBudgetCategories {
            let overspent = category.spent - category.budgeted
            insights.append("⚠️ \(category.name): $\(Int(overspent)) over budget")
        }
        
        // Spending percentage insights
        let spentPercentage = (totalSpent / totalIncome) * 100
        if spentPercentage > 90 {
            insights.append("💡 You spent \(Int(spentPercentage))% of income - try to reduce spending")
        } else if spentPercentage < 70 {
            insights.append("💚 Great job! You only spent \(Int(spentPercentage))% of income")
        }
        
        // Category-specific insights
        for category in categorySummaries {
            if category.percentageUsed > 100 {
                insights.append("📈 Consider increasing \(category.name) budget next month")
            }
        }
        
        // Savings opportunities
        let savedCategories = categorySummaries.filter { $0.savedAmount > 0 }
        if !savedCategories.isEmpty {
            let totalSaved = savedCategories.reduce(0) { $0 + $1.savedAmount }
            insights.append("💡 You saved $\(Int(totalSaved)) across categories - add to savings!")
        }
        
        return insights
    }
}
