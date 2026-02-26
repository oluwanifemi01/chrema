//
//  EditCategoryView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/24/26.
//
import SwiftUI

struct EditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var categoryManager: BudgetCategoryManager
    @State var category: CustomBudgetCategory
    let remainingBudget: Double
    
    @State private var categoryName: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var budgetAmount: Double
    @State private var showIconPicker = false
    @State private var showDeleteConfirmation = false
    
    init(categoryManager: BudgetCategoryManager, category: CustomBudgetCategory, remainingBudget: Double) {
        self.categoryManager = categoryManager
        self.category = category
        self.remainingBudget = remainingBudget
        _categoryName = State(initialValue: category.name)
        _selectedIcon = State(initialValue: category.icon)
        _selectedColor = State(initialValue: category.color)
        _budgetAmount = State(initialValue: category.monthlyBudget)
    }
    
    var hasChanges: Bool {
        categoryName != category.name ||
        selectedIcon != category.icon ||
        selectedColor != category.color ||
        budgetAmount != category.monthlyBudget
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Preview
                        VStack(spacing: 16) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 48))
                                .foregroundColor(categoryColor(selectedColor))
                                .frame(width: 100, height: 100)
                                .background(categoryColor(selectedColor).opacity(0.1))
                                .cornerRadius(20)
                            
                            Text(categoryName.isEmpty ? "Category Name" : categoryName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            AnimatedNumber(value: budgetAmount, format: .currency)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.accentPurple)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.cardBackground)
                        .cornerRadius(20)
                        .padding(.top, 20)
                        
                        // Category Name
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primaryText)
                            
                            TextField("Category name", text: $categoryName)
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
                                
                                Text("$\(Int(budgetAmount))")
                                    .font(.system(size: 20, weight: .bold))
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
                                    Text("Available: $\(Int(remainingBudget))")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(budgetAmount > remainingBudget ? .red : .secondaryText)
                                } else {
                                    Text("Over budget")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                            
                            if budgetAmount > remainingBudget && remainingBudget > 0 {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    
                                    Text("This exceeds your remaining budget")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            if remainingBudget <= 0 {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    
                                    Text("Budget fully allocated. Reduce other categories to increase this one.")
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
                        
                        // Save Button
                        Button(action: saveChanges) {
                            Text("Save Changes")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.appGradient)
                                .cornerRadius(16)
                        }
                        .pressAnimation()
                        .disabled(!hasChanges || categoryName.isEmpty || budgetAmount <= 0)
                        .opacity((!hasChanges || categoryName.isEmpty || budgetAmount <= 0) ? 0.5 : 1.0)
                        
                        // Delete Button
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16))
                                
                                Text("Delete Category")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            .alert("Delete Category?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteCategory()
                }
            } message: {
                Text("This will permanently delete '\(category.name)'. Existing expenses in this category will remain.")
            }
        }
    }
    
    func saveChanges() {
        var updatedCategory = category
        updatedCategory.name = categoryName
        updatedCategory.icon = selectedIcon
        updatedCategory.color = selectedColor
        updatedCategory.monthlyBudget = budgetAmount
        
        categoryManager.updateCategory(updatedCategory)
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        dismiss()
    }
    
    func deleteCategory() {
        categoryManager.deleteCategory(category)
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
        
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
    EditCategoryView(
        categoryManager: BudgetCategoryManager(),
        category: CustomBudgetCategory(
            name: "Coffee",
            icon: "cup.and.saucer.fill",
            monthlyBudget: 100,
            color: "brown",
            isCustom: true,
            userId: "test"
        ),
        remainingBudget: 500
    )
}
