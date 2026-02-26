//
//  AddCategoryView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/24/26.
//
import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var categoryManager: BudgetCategoryManager
    let remainingBudget: Double
    let totalIncome: Double
    
    @State private var categoryName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "blue"
    @State private var budgetAmount: Double = 100
    @State private var showIconPicker = false
    
    var suggestedAmount: String {
        let percentage = (budgetAmount / totalIncome) * 100
        if percentage < 5 {
            return "Conservative - Good for occasional expenses"
        } else if percentage < 10 {
            return "Moderate - Suitable for regular expenses"
        } else if percentage < 15 {
            return "Generous - For important categories"
        } else {
            return "High - Make sure this is intentional"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("What are you budgeting for?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Create a custom budget category")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.top, 20)
                        
                        // Category Name
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primaryText)
                            
                            TextField("e.g., Coffee, Gym, Hobbies", text: $categoryName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .padding(18)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                        }
                        
                        // Icon & Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon & Color")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primaryText)
                            
                            HStack(spacing: 16) {
                                // Icon Preview
                                Button(action: {
                                    showIconPicker = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: selectedIcon)
                                            .font(.system(size: 28))
                                            .foregroundColor(categoryColor(selectedColor))
                                            .frame(width: 60, height: 60)
                                            .background(categoryColor(selectedColor).opacity(0.1))
                                            .cornerRadius(12)
                                        
                                        Text("Change")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.accentPurple)
                                    }
                                }
                                
                                // Color Picker
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(CustomBudgetCategory.availableColors, id: \.self) { color in
                                            Button(action: {
                                                selectedColor = color
                                            }) {
                                                Circle()
                                                    .fill(categoryColor(color))
                                                    .frame(width: 44, height: 44)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white, lineWidth: 3)
                                                            .opacity(selectedColor == color ? 1 : 0)
                                                    )
                                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        // Budget Amount
                        // Budget Amount
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Monthly Budget")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primaryText)
                                
                                Spacer()
                                
                                AnimatedNumber(value: budgetAmount, format: .currency)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.accentPurple)
                            }
                            
                            let maxSliderValue = remainingBudget > 0 ? min(remainingBudget, 1000) : 500
                            
                            Slider(value: $budgetAmount, in: 0...max(maxSliderValue, 100), step: 10)
                                .tint(.accentPurple)
                            
                            HStack {
                                Text("$0")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondaryText)
                                
                                Spacer()
                                
                                if remainingBudget > 0 {
                                    Text("Remaining: $\(Int(remainingBudget))")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(budgetAmount > remainingBudget ? .red : .secondaryText)
                                } else {
                                    Text("Over budget - adjust categories")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                            
                            if remainingBudget <= 0 {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    
                                    Text("You've allocated all your budget. Consider reducing other categories first.")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        
                        // AI Suggestion
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                    .foregroundColor(.accentPurple)
                                
                                Text("AI Suggestion")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primaryText)
                            }
                            
                            Text(suggestedAmount)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(16)
                        .background(Color.accentPurple.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Add Button
                        Button(action: addCategory) {
                            Text("Add Category")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.appGradient)
                                .cornerRadius(16)
                        }
                        .pressAnimation()
                        .disabled(categoryName.isEmpty || budgetAmount <= 0)
                        .opacity((categoryName.isEmpty || budgetAmount <= 0) ? 0.5 : 1.0)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
        }
    }
    
    func addCategory() {
        categoryManager.addCategory(
            name: categoryName,
            icon: selectedIcon,
            monthlyBudget: budgetAmount,
            color: selectedColor
        )
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        dismiss()
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
    AddCategoryView(
        categoryManager: BudgetCategoryManager(),
        remainingBudget: 500,
        totalIncome: 3000
    )
}
