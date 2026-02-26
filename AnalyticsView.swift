//
//  AnalyticsView.swift
//  Chrema
//
//  Created by Oluwanifemi Oloyede on 2/22/26.
//
import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var expenseManager = ExpenseManager()
    let budget: BudgetItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Your Analytics")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.appPrimaryText)  // UPDATED
                    
                    Text("Track your financial health")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.appSecondaryText)  // UPDATED
                }
                .padding(.top, 60)
                
                // Budget Breakdown Pie Chart
                BudgetPieChartCard(
                    budget: budget,
                    authManager: authManager,
                    expenseManager: expenseManager
                )
                
                // Savings Progress Card
                SavingsProgressCard(
                    currentSavings: budget.monthlySavings,
                    goalAmount: Double(authManager.userData?.savingsGoal ?? "0") ?? 0,
                    timeframe: authManager.userData?.savingsTimeframe ?? "6 months"
                )
                
                // Budget Categories Grid
                BudgetCategoriesGrid(budget: budget, authManager: authManager)
                
                // Insights Card
                InsightsCard(budget: budget, authManager: authManager)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())  // UPDATED
        .onAppear {
            expenseManager.loadExpenses()
        }
    }
}

// MARK: - Budget Pie Chart Card
struct BudgetPieChartCard: View {
    let budget: BudgetItem
    @ObservedObject var authManager: AuthenticationManager
    @ObservedObject var expenseManager: ExpenseManager
    
    var petExpenses: Double {
        guard let pets = authManager.userData?.pets else { return 0 }
        return pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
    }
    
    var kidExpenses: Double {
        return Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
    }
    
    var chartData: [(String, Double, Color)] {
        var data: [(String, Double, Color)] = [
            ("Food", budget.monthlyFood, .orange),
            ("Entertainment", budget.monthlyMiscellaneous, .purple),
            ("Savings", budget.monthlySavings, .green)
        ]
        
        // Add pets if they have pets
        if petExpenses > 0 {
            data.append(("Pets", petExpenses, .brown))
        }
        
        // Add kids if they have kids
        if kidExpenses > 0 {
            data.append(("Kids", kidExpenses, Color(red: 0.2, green: 0.7, blue: 0.3)))
        }
        
        // Add buffer last
        if budget.remainingMoney > 0 {
            data.append(("Buffer", max(budget.remainingMoney - petExpenses - kidExpenses, 0), .blue))
        }
        
        return data
    }
    
    private var totalBudget: Double {
        budget.monthlyFood + budget.monthlyMiscellaneous + budget.monthlySavings + max(budget.remainingMoney, 0)
    }
    
    private func percentageString(for amount: Double) -> String {
        let percentage = Int((amount / totalBudget) * 100)
        return "(\(percentage)%)"
    }
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 20) {
            headerView
            chartView
            legendView
        }
        
        return content
            .padding(24)
            .background(Color.appCardBackground)  // UPDATED
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
            .padding(.horizontal, 24)
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.customAccentPurple)  // UPDATED
            
            Text("Budget Breakdown")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appPrimaryText)  // UPDATED
        }
    }
    
    private var chartView: some View {
        Chart(chartData, id: \.0) { item in
            SectorMark(
                angle: .value("Amount", item.1),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(4)
            .foregroundStyle(item.2.gradient)
        }
        .frame(height: 220)
    }
    
    private var legendView: some View {
        VStack(spacing: 12) {
            ForEach(chartData, id: \.0) { item in
                legendRow(for: item)
            }
        }
    }
    
    private func legendRow(for item: (String, Double, Color)) -> some View {
        HStack {
            Circle()
                .fill(item.2)
                .frame(width: 12, height: 12)
            
            Text(item.0)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appPrimaryText)  // UPDATED
            
            Spacer()
            
            Text("$\(Int(item.1))")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.appPrimaryText)  // UPDATED
            
            Text(percentageString(for: item.1))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.appSecondaryText)  // UPDATED
        }
    }
}

// MARK: - Savings Progress Card
struct SavingsProgressCard: View {
    let currentSavings: Double
    let goalAmount: Double
    let timeframe: String
    
    // Estimate months to goal
    var monthsToGoal: Int {
        guard currentSavings > 0 else { return 0 }
        return Int(ceil(goalAmount / currentSavings))
    }
    
    var progressPercentage: Double {
        guard goalAmount > 0 else { return 0 }
        return min((currentSavings / goalAmount) * 100, 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                
                Text("Savings Goal Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appPrimaryText)
            }
            
            // Goal Summary
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Goal")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("$\(Int(goalAmount))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appPrimaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Time to Goal")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(monthsToGoal) months")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }
            
            // Monthly Savings Display
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                
                Text("Saving $\(Int(currentSavings)) per month")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appPrimaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // Progress Bar
            VStack(spacing: 12) {
                HStack {
                    Text("\(Int(progressPercentage))% Complete")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    
                    Spacer()
                    
                    Text("$\(Int(currentSavings * Double(monthsToGoal))) / $\(Int(goalAmount))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 16)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.3, blue: 0.8),
                                        Color(red: 0.3, green: 0.5, blue: 0.9)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * min(progressPercentage / 100, 1.0), height: 16)
                    }
                }
                .frame(height: 16)
            }
            
            // Milestones
            HStack(spacing: 0) {
                ForEach([25, 50, 75, 100], id: \.self) { milestone in
                    VStack(spacing: 4) {
                        Image(systemName: progressPercentage >= Double(milestone) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundColor(progressPercentage >= Double(milestone) ? .green : .gray.opacity(0.3))
                        
                        Text("\(milestone)%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(progressPercentage >= Double(milestone) ? .black : .gray.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
            
            // Status Message
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                
                Text(progressPercentage >= 25 ? "Great progress! Keep it up!" : "Start saving to track your progress")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appPrimaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(24)
        .background(Color.appCardBackground)  // UPDATED
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        .padding(.horizontal, 24)
    }
}

// MARK: - Budget Categories Grid
struct BudgetCategoriesGrid: View {
    let budget: BudgetItem
    @ObservedObject var authManager: AuthenticationManager
    
    var petExpenses: Double {
        guard let pets = authManager.userData?.pets else { return 0 }
        return pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
    }
    
    var kidExpenses: Double {
        return Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                
                Text("Monthly Budget")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appPrimaryText)
            }
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CategoryCard(
                    icon: "fork.knife",
                    title: "Food",
                    amount: budget.monthlyFood,
                    color: .orange
                )
                
                CategoryCard(
                    icon: "sparkles",
                    title: "Entertainment",
                    amount: budget.monthlyMiscellaneous,
                    color: .purple
                )
                
                CategoryCard(
                    icon: "dollarsign.circle.fill",
                    title: "Savings",
                    amount: budget.monthlySavings,
                    color: .green
                )
                
                // Add pets if they have pets
                if petExpenses > 0 {
                    CategoryCard(
                        icon: "pawprint.fill",
                        title: "Pets",
                        amount: petExpenses,
                        color: .brown
                    )
                }
                
                // Add kids if they have kids
                if kidExpenses > 0 {
                    CategoryCard(
                        icon: "figure.2.and.child.holdinghands",
                        title: "Kids",
                        amount: kidExpenses,
                        color: Color(red: 0.2, green: 0.7, blue: 0.3)
                    )
                }
                
                CategoryCard(
                    icon: "banknote",
                    title: "Buffer",
                    amount: max(budget.remainingMoney, 0),
                    color: .blue
                )
            }
            .padding(.horizontal, 24)
        }
    }
}

struct CategoryCard: View {
    let icon: String
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.1))
                .cornerRadius(14)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appPrimaryText)
            
            Text("$\(Int(amount))")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appPrimaryText)
            
            Text("per month")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.appCardBackground)  // UPDATED
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Insights Card
struct InsightsCard: View {
    let budget: BudgetItem
    @ObservedObject var authManager: AuthenticationManager
    
    var petExpenses: Double {
        guard let pets = authManager.userData?.pets else { return 0 }
        return pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
    }
    
    var kidExpenses: Double {
        return Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
    }
    
    var insights: [String] {
        var tips: [String] = []
        
        if budget.savingsPercentage >= 20 {
            tips.append("🎉 Great job! You're saving \(Int(budget.savingsPercentage))% of your income.")
        } else if budget.savingsPercentage >= 10 {
            tips.append("💪 You're saving \(Int(budget.savingsPercentage))% - consider increasing to 20%.")
        } else {
            tips.append("💡 Try to increase savings to at least 10% of your income.")
        }
        
        if budget.monthlyFood > 500 {
            tips.append("🍽️ Your food budget is higher than average. Meal planning could save $100-200/month.")
        }
        
        // Add pet insights
        if petExpenses > 0 {
            if let pets = authManager.userData?.pets {
                let petNames = pets.map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")
                tips.append("🐾 Pet expenses for \(petNames): $\(Int(petExpenses))/month")
            }
        }
        
        // Add kid insights
        if kidExpenses > 0 {
            tips.append("👶 Kid expenses: $\(Int(kidExpenses))/month for \(authManager.userData?.numberOfKids ?? "0") children")
        }
        
        if budget.remainingMoney > 100 {
            tips.append("💰 You have $\(Int(budget.remainingMoney)) buffer - consider adding it to savings!")
        }
        
        return tips
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Text("Smart Insights")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appPrimaryText)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(insight)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.appPrimaryText)
                            .lineSpacing(4)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.appCardBackground)  // UPDATED
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        .padding(.horizontal, 24)
    }
}

#Preview {
    AnalyticsView(
        authManager: AuthenticationManager(),
        budget: BudgetItem(
            monthlyFood: 450,
            monthlyMiscellaneous: 300,
            monthlySavings: 500,
            remainingMoney: 250,
            savingsPercentage: 20,
            personalizedAdvice: "Great advice here",
            breakdown: "Breakdown here"
        )
    )
}
