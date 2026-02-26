//
//  BudgetAdjustmentView.swift
//  Chrema
//
//  Created by Oluwanifemi Oloyede on 2/23/26.
//
import SwiftUI

struct BudgetAdjustmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authManager: AuthenticationManager
    
    let originalBudget: BudgetItem
    @State private var foodBudget: Double
    @State private var miscBudget: Double
    @State private var savingsBudget: Double
    @State private var savingsLocked: Bool = true
    
    var totalIncome: Double {
        Double(authManager.userData?.monthlyIncome ?? "0") ?? 0
    }
    
    var fixedExpenses: Double {
        let rent = Double(authManager.userData?.rent ?? "0") ?? 0
        let utilities = Double(authManager.userData?.utilities ?? "0") ?? 0
        let phone = Double(authManager.userData?.phone ?? "0") ?? 0
        let transport = Double(authManager.userData?.transportation ?? "0") ?? 0
        let subscriptions = Double(authManager.userData?.subscriptions ?? "0") ?? 0
        return rent + utilities + phone + transport + subscriptions
    }
    
    var availableMoney: Double {
        totalIncome - fixedExpenses
    }
    
    var totalAllocated: Double {
        foodBudget + miscBudget + savingsBudget
    }
    
    var remainingMoney: Double {
        availableMoney - totalAllocated
    }
    
    var savingsPercentage: Double {
        guard totalIncome > 0 else { return 0 }
        return (savingsBudget / totalIncome) * 100
    }
    
    var hasChanges: Bool {
        foodBudget != originalBudget.monthlyFood ||
        miscBudget != originalBudget.monthlyMiscellaneous ||
        savingsBudget != originalBudget.monthlySavings
    }
    
    init(authManager: AuthenticationManager, originalBudget: BudgetItem) {
        self.authManager = authManager
        self.originalBudget = originalBudget
        _foodBudget = State(initialValue: originalBudget.monthlyFood)
        _miscBudget = State(initialValue: originalBudget.monthlyMiscellaneous)
        _savingsBudget = State(initialValue: originalBudget.monthlySavings)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary Card
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Available")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("$\(Int(availableMoney))")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Remaining")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("$\(Int(remainingMoney))")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(remainingMoney < 0 ? .red : .white)
                                }
                            }
                            
                            // Warning if overspent
                            if remainingMoney < 0 {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 14))
                                    
                                    Text("You're over budget by $\(Int(abs(remainingMoney)))")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
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
                        
                        // Food Budget Slider
                        BudgetSliderCard(
                            title: "Food & Groceries",
                            icon: "fork.knife",
                            color: .orange,
                            value: $foodBudget,
                            maxValue: availableMoney,
                            originalValue: originalBudget.monthlyFood
                        )
                        
                        // Entertainment Budget Slider
                        BudgetSliderCard(
                            title: "Entertainment & Misc",
                            icon: "sparkles",
                            color: .purple,
                            value: $miscBudget,
                            maxValue: availableMoney,
                            originalValue: originalBudget.monthlyMiscellaneous
                        )
                        
                        // Savings Budget Slider (with lock toggle)
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                                    .frame(width: 44, height: 44)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Monthly Savings")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 8) {
                                        Text("$\(Int(savingsBudget))")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.green)
                                        
                                        Text("(\(Int(savingsPercentage))%)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                // Lock/Unlock toggle
                                Button(action: {
                                    withAnimation {
                                        savingsLocked.toggle()
                                    }
                                }) {
                                    Image(systemName: savingsLocked ? "lock.fill" : "lock.open.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(savingsLocked ? .green : .gray)
                                        .frame(width: 40, height: 40)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            
                            if !savingsLocked {
                                VStack(spacing: 12) {
                                    Slider(value: $savingsBudget, in: 0...availableMoney, step: 10)
                                        .tint(.green)
                                    
                                    HStack {
                                        Text("$0")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("$\(Int(availableMoney))")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.green)
                                    
                                    Text("Savings is locked. Unlock to adjust.")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.green.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                        
                        // Emergency Fund Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                                
                                Text("Emergency Fund / Buffer")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            
                            HStack {
                                Text("$\(Int(max(remainingMoney, 0)))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text("Unallocated funds")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            if remainingMoney > 100 {
                                Text("💡 Consider adding this to your savings or creating an emergency fund!")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                        
                        // Reset & Save Buttons
                        HStack(spacing: 12) {
                            // Reset Button
                            Button(action: {
                                withAnimation {
                                    foodBudget = originalBudget.monthlyFood
                                    miscBudget = originalBudget.monthlyMiscellaneous
                                    savingsBudget = originalBudget.monthlySavings
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Reset")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .disabled(!hasChanges)
                            .opacity(hasChanges ? 1.0 : 0.5)
                            
                            // Save Button
                            Button(action: {
                                saveBudget()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Save Changes")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.3, blue: 0.8),
                                            Color(red: 0.3, green: 0.5, blue: 0.9)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(!hasChanges || remainingMoney < 0)
                            .opacity((hasChanges && remainingMoney >= 0) ? 1.0 : 0.5)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Adjust Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saveBudget() {
        let newBudget = BudgetItem(
            monthlyFood: foodBudget,
            monthlyMiscellaneous: miscBudget,
            monthlySavings: savingsBudget,
            remainingMoney: remainingMoney,
            savingsPercentage: savingsPercentage,
            personalizedAdvice: "You've customized your budget. Great job taking control of your finances!",
            breakdown: "Food: $\(Int(foodBudget)), Entertainment: $\(Int(miscBudget)), Savings: $\(Int(savingsBudget)), Emergency Fund: $\(Int(max(remainingMoney, 0)))"
        )
        
        // Save to Firebase
        authManager.saveBudget(newBudget)
        
        dismiss()
    }
}

// MARK: - Budget Slider Card
struct BudgetSliderCard: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var value: Double
    let maxValue: Double
    let originalValue: Double
    
    var hasChanged: Bool {
        abs(value - originalValue) > 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        Text("$\(Int(value))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(color)
                        
                        if hasChanged {
                            HStack(spacing: 4) {
                                Image(systemName: value > originalValue ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 10, weight: .bold))
                                Text("$\(Int(abs(value - originalValue)))")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(value > originalValue ? .green : .orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                Slider(value: $value, in: 0...maxValue, step: 10)
                    .tint(color)
                
                HStack {
                    Text("$0")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("$\(Int(maxValue))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
    }
}

#Preview {
    BudgetAdjustmentView(
        authManager: AuthenticationManager(),
        originalBudget: BudgetItem(
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
