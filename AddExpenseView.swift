import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseManager: ExpenseManager
    let authManager: AuthenticationManager
    let budget: BudgetItem
    
    @State private var amount = ""
    @State private var sliderAmount: Double = 50
    @State private var useSlider = true // Toggle between slider and text input
    @State private var category: ExpenseCategory = .food
    @State private var description = ""
    @State private var date = Date()
    @State private var showWarningAlert = false
    @State private var warningMessage = ""
    @State private var isRecurring = false  // NEW
    @State private var recurringFrequency: RecurringFrequency = .monthly  // NEW
    @State private var showSuccess = false  // ADD THIS
    
    var finalAmount: Double {
        if useSlider {
            return sliderAmount
        } else {
            return Double(amount) ?? 0
        }
    }
    
    // Calculate spending in category
    var categorySpent: Double {
        expenseManager.getSpendingByCategory()[category] ?? 0
    }
    
    // Get budget for category
    var categoryBudget: Double {
        switch category {
        case .food:
            return budget.monthlyFood
        case .entertainment:
            return budget.monthlyMiscellaneous
        case .pets:
            if let pets = authManager.userData?.pets {
                return pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
            }
            return 0
        case .kids:
            return Double(authManager.userData?.monthlyKidExpenses ?? "0") ?? 0
        default:
            return 0
        }
    }
    
    // Calculate percentage after this expense
    var percentageAfterExpense: Double {
        guard categoryBudget > 0 else { return 0 }
        return ((categorySpent + finalAmount) / categoryBudget) * 100
    }
    
    // Check if warning needed
    var needsWarning: Bool {
        percentageAfterExpense >= 90
    }
    
    // Generate warning message
    func generateWarningMessage() -> String {
        let newTotal = categorySpent + finalAmount
        let remaining = categoryBudget - newTotal
        
        if percentageAfterExpense >= 100 {
            return "⚠️ This will put you $\(Int(abs(remaining))) OVER your \(category.rawValue) budget!\n\nBudget: $\(Int(categoryBudget))\nAlready spent: $\(Int(categorySpent))\nThis expense: $\(Int(finalAmount))\n\nProceed anyway?"
        } else {
            return "⚠️ Warning: This will use \(Int(percentageAfterExpense))% of your \(category.rawValue) budget.\n\nYou'll only have $\(Int(remaining)) left.\n\nProceed?"
        }
    }
    
    var availableCategories: [ExpenseCategory] {
        var categories: [ExpenseCategory] = [.food, .entertainment, .transport, .shopping, .bills]
        
        // Add pets category if user has pets
        if authManager.userData?.hasPets == true {
            categories.append(.pets)
        }
        
        // Add kids category if user has kids
        if authManager.userData?.hasKids == true {
            categories.append(.kids)
        }
        
        categories.append(.other)
        
        return categories
    }
    
    var categoryHint: String {
            switch category {
            case .pets:
                if let pets = authManager.userData?.pets, !pets.isEmpty {
                    let petNames = pets.map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")
                    return "For: \(petNames)"
                }
                return "Pet expenses"
            case .kids:
                if let hasKids = authManager.userData?.hasKids, hasKids {
                    return "Kid expenses"
                }
                return "Kid expenses"
            default:
                return ""
            }
        }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        amountInputSection
                        categorySelectionSection
                        descriptionSection
                        datePickerSection
                        recurringExpenseSection
                        addExpenseButton
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Budget Warning", isPresented: $showWarningAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Proceed Anyway", role: .destructive) {
                    saveExpense(amount: finalAmount)
                }
            } message: {
                Text(warningMessage)
            }
            .overlay {
                if showSuccess {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            SuccessCheckmark()
                            
                            Text("Expense Added!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Amount")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
                
                Spacer()
                
                inputToggleButtons
            }
            
            amountDisplayAndInput
        }
    }
    
    private var inputToggleButtons: some View {
        HStack(spacing: 8) {
            Button(action: {
                withAnimation {
                    useSlider = true
                }
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(useSlider ? .white : .appSecondaryText)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(useSlider ? Color.customAccentPurple : Color.clear)
                    )
            }
            
            Button(action: {
                withAnimation {
                    useSlider = false
                }
            }) {
                Image(systemName: "keyboard")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(!useSlider ? .white : .appSecondaryText)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(!useSlider ? Color.customAccentPurple : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appCardBackground)
        )
    }
    
    private var amountDisplayAndInput: some View {
        VStack(spacing: 20) {
            // Display Amount
            HStack {
                Text("$")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.appSecondaryText)
                
                Text(String(format: "%.2f", finalAmount))
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            if useSlider {
                sliderInputView
            } else {
                textInputView
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private var sliderInputView: some View {
        VStack(spacing: 12) {
            Slider(value: $sliderAmount, in: 1...500, step: 1)
                .tint(Color.customAccentPurple)
            
            HStack {
                Text("$1")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appSecondaryText)
                
                Spacer()
                
                Text("$500")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appSecondaryText)
            }
            
            // Quick amount buttons
            HStack(spacing: 8) {
                QuickAmountButton(amount: 10, sliderAmount: $sliderAmount)
                QuickAmountButton(amount: 25, sliderAmount: $sliderAmount)
                QuickAmountButton(amount: 50, sliderAmount: $sliderAmount)
                QuickAmountButton(amount: 100, sliderAmount: $sliderAmount)
            }
        }
    }
    
    private var textInputView: some View {
        HStack {
            Text("$")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appSecondaryText)
            
            TextField("0.00", text: $amount)
                .keyboardType(.decimalPad)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appPrimaryText)
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
    
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appPrimaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableCategories, id: \.self) { cat in
                    CategoryButton(
                        category: cat,
                        isSelected: category == cat
                    ) {
                        category = cat
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appPrimaryText)
            
            if !categoryHint.isEmpty {
                Text(categoryHint)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.customAccentPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.customAccentPurple.opacity(0.1))
                    .cornerRadius(8)
            }
            
            TextField("What did you buy?", text: $description)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appPrimaryText)
                .padding(18)
                .background(Color.appCardBackground)
                .cornerRadius(16)
        }
    }
    
    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appPrimaryText)
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(12)
                .background(Color.appCardBackground)
                .cornerRadius(16)
        }
    }
    
    private var recurringExpenseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isRecurring) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.customAccentPurple)
                    
                    Text("Recurring Expense")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimaryText)
                }
            }
            .tint(.customAccentPurple)
            .padding(16)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            
            if isRecurring {
                recurringFrequencyPicker
            }
        }
    }
    
    private var recurringFrequencyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Frequency")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appSecondaryText)
            
            HStack(spacing: 12) {
                ForEach([RecurringFrequency.weekly, .biweekly, .monthly], id: \.self) { freq in
                    frequencyButton(for: freq)
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func frequencyButton(for freq: RecurringFrequency) -> some View {
        Button(action: {
            recurringFrequency = freq
        }) {
            VStack(spacing: 6) {
                Image(systemName: freq.icon)
                    .font(.system(size: 18))
                    .foregroundColor(recurringFrequency == freq ? .white : .customAccentPurple)
                
                Text(freq.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(recurringFrequency == freq ? .white : .appPrimaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if recurringFrequency == freq {
                    Color.appGradient
                } else {
                    Color.appCardBackground
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.customAccentPurple.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var addExpenseButton: some View {
        Button(action: addExpense) {
            Text("Add Expense")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.appGradient)
                .cornerRadius(16)
        }
        .pressAnimation()
        .disabled(finalAmount <= 0 || description.isEmpty)
        .opacity((finalAmount <= 0 || description.isEmpty) ? 0.5 : 1.0)
    }
    
    func addExpense() {
        // Check if we need to show warning
        if needsWarning {
            warningMessage = generateWarningMessage()
            showWarningAlert = true
        } else {
            // No warning needed, add directly
            saveExpense(amount: finalAmount)
        }
    }
    
    func saveExpense(amount: Double) {
        if isRecurring {
            expenseManager.addRecurringExpense(
                amount: amount,
                category: category,
                description: description,
                date: date,
                frequency: recurringFrequency
            )
        } else {
            expenseManager.addExpense(
                amount: amount,
                category: category,
                description: description,
                date: date
            )
        }
        
        // Show success animation
        showSuccess = true
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

// MARK: - Quick Amount Button
struct QuickAmountButton: View {
    let amount: Double
    @Binding var sliderAmount: Double
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                sliderAmount = amount
            }
        }) {
            Text("$\(Int(amount))")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.customAccentPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.customAccentPurple.opacity(0.1))
                )
        }
    }
}

struct CategoryButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : categoryColor(category.color))
                
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.3, blue: 0.8),
                        Color(red: 0.3, green: 0.5, blue: 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [Color.white, Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    func categoryColor(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return .orange
        case "purple": return .purple
        case "blue": return .blue
        case "pink": return .pink
        case "red": return .red
        case "brown": return .brown  // ADD THIS
        case "green": return .green  // This was already there but make sure
        default: return .gray
        }
    }
}

#Preview {
    AddExpenseView(
        expenseManager: ExpenseManager(),
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
