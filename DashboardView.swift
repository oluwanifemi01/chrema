import SwiftUI

struct DashboardView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var budget: BudgetItem?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedTab = 0
    @State private var showAddExpense = false
    @StateObject private var expenseManager = ExpenseManager()
    @ObservedObject private var animationState = AnimationStateManager.shared
    @State private var showMonthlySummary = false
    @StateObject private var summaryManager = MonthlySummaryManager()  // ADD THIS
    
    let budgetService = BudgetService()
    
    var body: some View {
        ZStack {
            // Background gradient - UPDATED
            Color.appBackground
                .ignoresSafeArea()
            
            if isLoading {
                LoadingView()
            } else if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Oops!")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Generate New Budget") {
                        Task {
                            await generateNewBudget()
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            } else if let budget = budget {
                ZStack {
                    VStack(spacing: 0) {
                        // Content
                        TabView(selection: $selectedTab) {
                            OverviewTab(
                                authManager: authManager,
                                animationState: animationState,
                                budget: budget,
                                summaryManager: summaryManager,
                                expenseManager: expenseManager,
                                showMonthlySummary: $showMonthlySummary
                            )
                                .tag(0)
                            
                            TrackerView(authManager: authManager, budget: budget)
                                .tag(1)
                            
                            AnalyticsView(authManager: authManager, budget: budget)
                                .tag(2)
                            
                            SettingsView(authManager: authManager)
                                .tag(3)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        Spacer(minLength: 0)
                        
                        // Bottom Tab Bar
                        BottomTabBar(selectedTab: $selectedTab)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    
                    // Global Floating Action Button
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            FloatingAddButton(showAddExpense: $showAddExpense)
                                .padding(.trailing, 24)
                                .padding(.bottom, 90) // Adjust to be above bottom tab bar
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            if let budget = budget {
                AddExpenseView(expenseManager: expenseManager, authManager: authManager, budget: budget)
            }
        }
        .sheet(isPresented: $showMonthlySummary) {
            if let summary = summaryManager.currentMonthSummary {
                MonthlySummaryView(summary: summary)
            }
        }
        .onAppear {
            expenseManager.processRecurringExpenses()  // NEW
            
            // Listen for regenerate notification
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RegenerateBudget"),
                object: nil,
                queue: .main
            ) { _ in
                Task {
                    await self.generateNewBudget()
                }
            }
        }
        .task {
            await loadBudget()
        }
    }
    func loadBudget() async {
        isLoading = true
        errorMessage = nil
        
        // Wait a moment for authManager to finish loading data
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // First, check if we have a saved budget
        if let savedBudget = authManager.savedBudget {
            // Use the saved budget
            budget = BudgetItem(
                monthlyFood: savedBudget.monthlyFood,
                monthlyMiscellaneous: savedBudget.monthlyMiscellaneous,
                monthlySavings: savedBudget.monthlySavings,
                remainingMoney: savedBudget.remainingMoney,
                savingsPercentage: savedBudget.savingsPercentage,
                personalizedAdvice: savedBudget.personalizedAdvice,
                breakdown: savedBudget.breakdown
            )
            isLoading = false
            return
        }
        
        // If no saved budget, generate a new one
        await generateNewBudget()
    }
    
    func generateNewBudget() async {
        isLoading = true
        errorMessage = nil
        
        guard let userData = authManager.userData else {
            errorMessage = "Please complete onboarding first"
            isLoading = false
            return
        }
        
        do {
            let recommendation = try await budgetService.generateBudget(
                age: userData.age,
                location: userData.location,
                relationshipStatus: userData.relationshipStatus,
                monthlyIncome: userData.monthlyIncome,
                rent: userData.rent,
                utilities: userData.utilities,
                phone: userData.phone,
                transportation: userData.transportation,
                subscriptions: userData.subscriptions,
                savingsGoal: userData.savingsGoal,
                savingsTimeframe: userData.savingsTimeframe,
                hasPets: userData.hasPets,  // NEW
                pets: userData.pets,  // NEW
                hasKids: userData.hasKids,  // NEW
                numberOfKids: userData.numberOfKids,  // NEW
                monthlyKidExpenses: userData.monthlyKidExpenses  // NEW
            )
            
            budget = recommendation
            
            // Save the budget to Firebase
            authManager.saveBudget(recommendation)
            
            isLoading = false
            
        } catch {
            errorMessage = "Couldn't generate your budget. Please try again."
            isLoading = false
        }
    }
    
    // MARK: - Overview Tab (Your existing dashboard)
    struct OverviewTab: View {
        @ObservedObject var authManager: AuthenticationManager
        @ObservedObject var animationState: AnimationStateManager
        let budget: BudgetItem
        @State private var showBudgetAdjustment = false
        @ObservedObject var summaryManager: MonthlySummaryManager
        @ObservedObject var expenseManager: ExpenseManager
        @Binding var showMonthlySummary: Bool
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Your Budget")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.appPrimaryText)  // UPDATED
                        
                        Text("AI-Powered & Personalized")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.appSecondaryText)  // UPDATED
                    }
                    .padding(.top, 60)
                    
                    // Main savings card
                    VStack(spacing: 16) {
                        Text("Monthly Savings Goal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        AnimatedNumber(value: budget.monthlySavings, format: .currency)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .semibold))
                            
                            AnimatedNumber(value: budget.savingsPercentage, format: .percentage)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("of income")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(Color.appGradient)  // UPDATED
                    .cornerRadius(24)
                    .shadow(color: Color.accentPurple.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 24)
                    .cardAppear(delay: 0.1, shouldAnimate: !animationState.hasPlayedHomeAnimation)
                    
                    // Budget breakdown
                    VStack(spacing: 16) {
                        BudgetItemView(
                            icon: "fork.knife",
                            title: "Food & Groceries",
                            amount: budget.monthlyFood,
                            color: Color.orange
                        )
                        .cardAppear(delay: 0.2, shouldAnimate: !animationState.hasPlayedHomeAnimation)  // UPDATED
                        
                        BudgetItemView(
                            icon: "sparkles",
                            title: "Entertainment & Misc",
                            amount: budget.monthlyMiscellaneous,
                            color: Color.purple
                        )
                        .cardAppear(delay: 0.3, shouldAnimate: !animationState.hasPlayedHomeAnimation)  // UPDATED
                        
                        BudgetItemView(
                            icon: "dollarsign.circle.fill",
                            title: "Monthly Savings",
                            amount: budget.monthlySavings,
                            color: Color.green
                        )
                        .cardAppear(delay: 0.4, shouldAnimate: !animationState.hasPlayedHomeAnimation)  // UPDATED
                        
                        // ADD PETS SECTION
                        if let pets = authManager.userData?.pets, !pets.isEmpty {
                            let petExpenses = pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
                            if petExpenses > 0 {
                                BudgetItemView(
                                    icon: "pawprint.fill",
                                    title: "Pets (\(pets.map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")))",
                                    amount: petExpenses,
                                    color: .brown
                                )
                                .cardAppear(delay: 0.5)
                            }
                        }
                        
                        // ADD KIDS SECTION
                        if let hasKids = authManager.userData?.hasKids, hasKids {
                            let kidExpenses = Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
                            if kidExpenses > 0 {
                                BudgetItemView(
                                    icon: "figure.2.and.child.holdinghands",
                                    title: "Kids (\(authManager.userData?.numberOfKids ?? "0") children)",
                                    amount: kidExpenses,
                                    color: Color(red: 0.2, green: 0.7, blue: 0.3)
                                )
                                .cardAppear(delay: 0.6)
                            }
                        }
                        
                        if budget.remainingMoney > 0 {
                            BudgetItemView(
                                icon: "banknote",
                                title: "Remaining Buffer",
                                amount: budget.remainingMoney,
                                color: Color.blue
                            )
                            .cardAppear(delay: 0.7)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Adjust Budget Button
                    Button(action: {
                        showBudgetAdjustment = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                            
                            Text("Adjust Budget")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondaryText)  // UPDATED
                        }
                        .foregroundColor(Color.accentPurple)  // UPDATED
                        .padding(20)
                        .background(Color.appCardBackground)  // UPDATED
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .sheet(isPresented: $showBudgetAdjustment) {
                        BudgetAdjustmentView(authManager: authManager, originalBudget: budget)
                    }
                    .padding(.horizontal, 24)
                    
                    // Advice card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color.accentPurple)  // UPDATED
                            
                            Text("AI Advice")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appPrimaryText)  // UPDATED
                        }
                        
                        Text(budget.personalizedAdvice)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.appSecondaryText)  // UPDATED
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.cardBackground)  // UPDATED
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    
                    // Monthly Summary Button
                    Button(action: {
                        // Access parent's summaryManager and expenseManager
                        summaryManager.generateCurrentMonthSummary(
                            authManager: authManager,
                            expenseManager: expenseManager,
                            budget: budget
                        )
                        showMonthlySummary = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Monthly Summary")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appPrimaryText)
                                
                                Text("See how you're doing this month")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.appSecondaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 20))
                                .foregroundColor(Color.accentPurple)
                        }
                        .padding(20)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    
                    // Breakdown explanation
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color.accentPurple)  // UPDATED
                            
                            Text("Budget Breakdown")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appPrimaryText)  // UPDATED
                        }
                        
                        Text(budget.breakdown)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.appSecondaryText)  // UPDATED
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.cardBackground)  // UPDATED
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    
                    // Sign out button
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.accentPurple)  // UPDATED
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.cardBackground)  // UPDATED
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Budget Item View
    struct BudgetItemView: View {
        let icon: String
        let title: String
        let amount: Double
        let color: Color
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimaryText)  // UPDATED
                    
                    Text("Recommended amount")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.appSecondaryText)  // UPDATED
                }
                
                Spacer()
                
                AnimatedNumber(value: amount, format: .currency)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appPrimaryText)  // UPDATED
            }
            .padding(16)
            .background(Color.cardBackground)  // UPDATED
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Floating Add Button
    struct FloatingAddButton: View {
        @Binding var showAddExpense: Bool
        @State private var isPressed = false
        @State private var rotationAngle: Double = 0
        
        var body: some View {
            Button(action: {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                // Rotate animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotationAngle += 90
                }
                
                showAddExpense = true
            }) {
                ZStack {
                    // Shadow layer
                    Circle()
                        .fill(Color.appGradient)  // UPDATED
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.accentPurple.opacity(0.4), radius: 20, x: 0, y: 10)  // UPDATED
                    
                    // Icon
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
        }
    }
}

#Preview {
    DashboardView(authManager: AuthenticationManager())
}

