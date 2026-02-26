import SwiftUI

struct TrackerView: View {
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var expenseManager = ExpenseManager()
    @StateObject private var categoryManager = BudgetCategoryManager()  // ADD THIS
    let budget: BudgetItem
    @State private var isRefreshing = false
    @ObservedObject private var animationState = AnimationStateManager.shared
    
    // Calculate spending by category
    var spendingByCategory: [ExpenseCategory: Double] {
        expenseManager.getSpendingByCategory()
    }
    
    var totalBudget: Double {
        var total = budget.monthlyFood + budget.monthlyMiscellaneous + budget.monthlySavings
        
        // Add pet expenses
        if let pets = authManager.userData?.pets {
            total += pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
        }
        
        // Add kid expenses
        if let kidExpenses = authManager.userData?.monthlyKidExpenses {
            total += Double(kidExpenses) ?? 0
        }
        
        return total
    }
    
    var totalSpent: Double {
        expenseManager.getTotalSpentThisMonth()
    }
    
    var overallPercentage: Double {
        guard totalBudget > 0 else { return 0 }
        return (totalSpent / totalBudget) * 100
    }
    
    var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)
        let totalDays = range?.count ?? 30
        let currentDay = calendar.component(.day, from: today)
        return totalDays - currentDay
    }
    
    var activeWarnings: [String] {
        var warnings: [String] = []
        
        // Check food budget
        let foodSpent = spendingByCategory[.food] ?? 0
        let foodBudget = budget.monthlyFood
        let foodPercentage = (foodSpent / foodBudget) * 100
        
        if foodPercentage >= 90 {
            let remaining = foodBudget - foodSpent
            if remaining > 0 {
                warnings.append("Food budget: Only $\(Int(remaining)) left")
            } else {
                warnings.append("Food budget: $\(Int(abs(remaining))) over budget")
            }
        }
        
        // Check entertainment budget
        let entertainmentSpent = spendingByCategory[.entertainment] ?? 0
        let entertainmentBudget = budget.monthlyMiscellaneous
        let entertainmentPercentage = (entertainmentSpent / entertainmentBudget) * 100
        
        if entertainmentPercentage >= 90 {
            let remaining = entertainmentBudget - entertainmentSpent
            if remaining > 0 {
                warnings.append("Entertainment budget: Only $\(Int(remaining)) left")
            } else {
                warnings.append("Entertainment budget: $\(Int(abs(remaining))) over budget")
            }
        }
        
        // Check pet budget
        if let pets = authManager.userData?.pets, !pets.isEmpty {
            let petBudget = pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
            let petSpent = spendingByCategory[.pets] ?? 0
            let petPercentage = (petSpent / petBudget) * 100
            
            if petPercentage >= 90 {
                let remaining = petBudget - petSpent
                if remaining > 0 {
                    warnings.append("Pet budget: Only $\(Int(remaining)) left")
                } else {
                    warnings.append("Pet budget: $\(Int(abs(remaining))) over budget")
                }
            }
        }
        
        // Check kid budget
        if let kidBudget = authManager.userData?.monthlyKidExpenses, !kidBudget.isEmpty {
            let budget = Double(kidBudget) ?? 0
            let kidSpent = spendingByCategory[.kids] ?? 0
            let kidPercentage = (kidSpent / budget) * 100
            
            if kidPercentage >= 90 {
                let remaining = budget - kidSpent
                if remaining > 0 {
                    warnings.append("Kid budget: Only $\(Int(remaining)) left")
                } else {
                    warnings.append("Kid budget: $\(Int(abs(remaining))) over budget")
                }
            }
        }
        
        return warnings
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Tracker")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primaryText)  // UPDATED
                    
                    Text("Monitor your spending in real-time")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondaryText)  // UPDATED
                }
                .padding(.top, 60)
                
                // Monthly Summary Card
                VStack(spacing: 16) {
                    Text("This Month")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        AnimatedNumber(value: totalSpent, format: .currency)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("/ $\(Int(totalBudget))")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Overall progress bar
                    VStack(spacing: 8) {
                        AnimatedProgressBar(
                            value: totalSpent,
                            total: totalBudget,
                            color: progressColor(overallPercentage)
                        )
                        
                        HStack {
                            HStack(spacing: 4) {
                                AnimatedNumber(value: overallPercentage, format: .percentage)
                                    .font(.system(size: 14, weight: .medium))
                                Text("of budget used")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text("\(daysLeftInMonth) days left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(24)
                .background(Color.appGradient)  // UPDATED
                .cornerRadius(20)
                .shadow(color: Color.customAccentPurple.opacity(0.3), radius: 20, x: 0, y: 10)  // UPDATED
                .padding(.horizontal, 24)
                .cardAppear(delay: 0.1, shouldAnimate: !animationState.hasPlayedTrackerAnimation)
                
                // Active Warnings
                if !activeWarnings.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.warningAmber)  // UPDATED
                            
                            Text("Active Warnings (\(activeWarnings.count))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primaryText)  // UPDATED
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(activeWarnings, id: \.self) { warning in
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.warningAmber)  // UPDATED
                                    
                                    Text(warning)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primaryText)  // UPDATED
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.warningAmber.opacity(0.1))  // UPDATED
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.cardBackground)  // UPDATED
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                }
                
                // Category Progress Trackers
                VStack(spacing: 16) {
                    CategoryProgressTracker(
                        icon: "fork.knife",
                        title: "Food & Groceries",
                        spent: spendingByCategory[.food] ?? 0,
                        budget: budget.monthlyFood,
                        color: .orange
                    )
                    
                    CategoryProgressTracker(
                        icon: "sparkles",
                        title: "Entertainment",
                        spent: spendingByCategory[.entertainment] ?? 0,
                        budget: budget.monthlyMiscellaneous,
                        color: .purple
                    )
                    
                    // Pets
                    if let pets = authManager.userData?.pets, !pets.isEmpty {
                        let petBudget = pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
                        let petNames = pets.map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")
                        
                        CategoryProgressTracker(
                            icon: "pawprint.fill",
                            title: "Pets (\(petNames))",
                            spent: spendingByCategory[.pets] ?? 0,
                            budget: petBudget,
                            color: .brown
                        )
                    }
                    
                    // Kids
                    if let hasKids = authManager.userData?.hasKids, hasKids {
                        let kidBudget = Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
                        if kidBudget > 0 {
                            CategoryProgressTracker(
                                icon: "figure.2.and.child.holdinghands",
                                title: "Kids (\(authManager.userData?.numberOfKids ?? "0") children)",
                                spent: spendingByCategory[.kids] ?? 0,
                                budget: kidBudget,
                                color: Color(red: 0.2, green: 0.7, blue: 0.3)
                            )
                        }
                    }
                    
                    // ADD CUSTOM CATEGORIES
                    ForEach(categoryManager.customCategories) { category in
                        CustomCategoryProgressTracker(
                            category: category,
                            spent: 0  // We'll implement custom category spending later
                        )
                    }
                    
                    // Buffer/Emergency Fund
                    CategoryProgressTracker(
                        icon: "shield.fill",
                        title: "Emergency Fund",
                        spent: 0,
                        budget: max(budget.remainingMoney, 0),
                        color: .blue,
                        isBuffer: true
                    )
                }
                .padding(.horizontal, 24)
                
                // Recent Transactions Preview
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        
                        Text("Recent Transactions")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appPrimaryText)
                        
                        Spacer()
                        
                        NavigationLink(destination: Text("All Expenses")) {
                            Text("View All")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        }
                    }
                    
                    if expenseManager.expenses.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No expenses yet this month")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(expenseManager.expenses.prefix(5)) { expense in
                                CompactExpenseRow(expense: expense)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.cardBackground)  // UPDATED
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                
                // Smart Suggestions
                SmartSuggestionsCard(
                    budget: budget,
                    totalSpent: totalSpent,
                    spendingByCategory: spendingByCategory,
                    authManager: authManager
                )
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())  // UPDATED
        .refreshable {
            await refreshData()
        }
        .onAppear {
            expenseManager.loadExpenses()
            expenseManager.processRecurringExpenses()  // NEW
            categoryManager.loadCategories()  // ADD THIS
            
            if !animationState.hasPlayedTrackerAnimation {
                    animationState.hasPlayedTrackerAnimation = true
                }
        }
    }
    
    func refreshData() async {
        isRefreshing = true
        expenseManager.loadExpenses()
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        isRefreshing = false
    }
    
    func progressColor(_ percentage: Double) -> Color {
        if percentage < 70 {
            return .green
        } else if percentage < 90 {
            return .yellow
        } else if percentage < 100 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Category Progress Tracker
struct CategoryProgressTracker: View {
    let icon: String
    let title: String
    let spent: Double
    let budget: Double
    let color: Color
    var isBuffer: Bool = false
    
    var percentage: Double {
        guard budget > 0 else { return 0 }
        return min((spent / budget) * 100, 100)
    }
    
    var remaining: Double {
        budget - spent
    }
    
    var statusColor: Color {
        if isBuffer {
            return .blue
        }
        if percentage < 70 {
            return .green
        } else if percentage < 90 {
            return .yellow
        } else if percentage < 100 {
            return .orange
        } else {
            return .red
        }
    }
    
    var statusIcon: String {
        if isBuffer {
            return "checkmark.circle.fill"
        }
        if percentage < 70 {
            return "checkmark.circle.fill"
        } else if percentage < 90 {
            return "exclamationmark.circle.fill"
        } else {
            return "exclamationmark.triangle.fill"
        }
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
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryText)  // UPDATED
                        .lineLimit(1)
                    
                    if !isBuffer {
                        HStack(spacing: 6) {
                            AnimatedNumber(value: spent, format: .currency)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(statusColor)
                            
                            Text("/ $\(Int(budget))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondaryText)  // UPDATED
                        }
                    } else {
                        AnimatedNumber(value: budget, format: .currency)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if !isBuffer {
                        HStack(spacing: 4) {
                            Image(systemName: statusIcon)
                                .font(.system(size: 14))
                                .foregroundColor(statusColor)
                            
                            AnimatedNumber(value: percentage, format: .percentage)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(statusColor)
                        }
                        
                        if remaining >= 0 {
                            Text("$\(Int(remaining)) left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondaryText)  // UPDATED
                        } else {
                            Text("$\(Int(abs(remaining))) over")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.dangerRed)  // UPDATED
                        }
                    } else {
                        Text("Available")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondaryText)  // UPDATED
                    }
                }
            }
            
            // Progress Bar
            if !isBuffer {
                AnimatedProgressBar(
                    value: spent,
                    total: budget,
                    color: statusColor
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)  // UPDATED
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Compact Expense Row
struct CompactExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .font(.system(size: 18))
                .foregroundColor(categoryColor(expense.category.color))
                .frame(width: 36, height: 36)
                .background(categoryColor(expense.category.color).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.description)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryText)  // UPDATED
                
                Text(expense.category.rawValue)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondaryText)  // UPDATED
            }
            
            Spacer()
            
            Text("-$\(Int(expense.amount))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primaryText)  // UPDATED
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
        case "green": return Color(red: 0.2, green: 0.7, blue: 0.3)
        default: return .gray
        }
    }
}

// MARK: - Smart Suggestions Card
struct SmartSuggestionsCard: View {
    let budget: BudgetItem
    let totalSpent: Double
    let spendingByCategory: [ExpenseCategory: Double]
    @ObservedObject var authManager: AuthenticationManager
    
    var suggestions: [String] {
        var tips: [String] = []
        
        // Check if on track for savings
        let savingsPercentage = (budget.monthlySavings / (Double(authManager.userData?.monthlyIncome ?? "0") ?? 1)) * 100
        if savingsPercentage >= 20 {
            tips.append("🎉 Excellent! You're saving \(Int(savingsPercentage))% of your income")
        }
        
        // Check food overspending
        let foodSpent = spendingByCategory[.food] ?? 0
        if foodSpent > budget.monthlyFood * 0.9 {
            tips.append("🍽️ Consider meal planning to stay within your food budget")
        }
        
        // Check entertainment
        let entertainmentSpent = spendingByCategory[.entertainment] ?? 0
        if entertainmentSpent > budget.monthlyMiscellaneous * 0.8 {
            tips.append("🎬 You're close to your entertainment limit - maybe skip one outing?")
        }
        
        // Positive reinforcement
        if totalSpent < budget.monthlyFood + budget.monthlyMiscellaneous {
            tips.append("💪 Great job staying under budget this month!")
        }
        
        return tips
    }
    
    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.yellow)
                    
                    Text("Smart Insights")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryText)  // UPDATED
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color.customAccentPurple)  // UPDATED
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            
                            Text(suggestion)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primaryText)  // UPDATED
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.cardBackground)  // UPDATED
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Custom Category Progress Tracker
struct CustomCategoryProgressTracker: View {
    let category: CustomBudgetCategory
    let spent: Double
    
    var percentage: Double {
        guard category.monthlyBudget > 0 else { return 0 }
        return min((spent / category.monthlyBudget) * 100, 100)
    }
    
    var remaining: Double {
        category.monthlyBudget - spent
    }
    
    var statusColor: Color {
        if percentage < 70 {
            return .successGreen
        } else if percentage < 90 {
            return .warningAmber
        } else if percentage < 100 {
            return .orange
        } else {
            return .dangerRed
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(categoryColor(category.color))
                    .frame(width: 40, height: 40)
                    .background(categoryColor(category.color).opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appPrimaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        AnimatedNumber(value: spent, format: .currency)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(statusColor)
                        
                        Text("/ $\(Int(category.monthlyBudget))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appSecondaryText)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: percentage < 70 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(statusColor)
                        
                        AnimatedNumber(value: percentage, format: .percentage)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(statusColor)
                    }
                    
                    if remaining >= 0 {
                        Text("$\(Int(remaining)) left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appSecondaryText)
                    } else {
                        Text("$\(Int(abs(remaining))) over")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.dangerRed)
                    }
                }
            }
            
            AnimatedProgressBar(
                value: spent,
                total: category.monthlyBudget,
                color: statusColor
            )
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
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
    TrackerView(
        authManager: AuthenticationManager(),
        budget: BudgetItem(
            monthlyFood: 450,
            monthlyMiscellaneous: 300,
            monthlySavings: 500,
            remainingMoney: 250,
            savingsPercentage: 20,
            personalizedAdvice: "Great advice",
            breakdown: "Breakdown"
        )
    )
}
