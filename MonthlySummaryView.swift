//
//  MonthlySummaryView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/26/26.
//
import SwiftUI

struct MonthlySummaryView: View {
    @Environment(\.dismiss) var dismiss
    let summary: MonthlySummary
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        VStack(spacing: 16) {
                            Text("\(summary.monthName) \(String(summary.year))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Monthly Summary")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.vertical, 8)
                            
                            // Income vs Spent vs Saved
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("Income")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("$\(Int(summary.totalIncome))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                    .background(Color.white.opacity(0.3))
                                
                                VStack(spacing: 4) {
                                    Text("Spent")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("$\(Int(summary.totalSpent))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                    .background(Color.white.opacity(0.3))
                                
                                VStack(spacing: 4) {
                                    Text("Saved")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("$\(Int(summary.totalSaved))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(summary.savingsGoalMet ? Color.green : .white)
                                }
                            }
                            
                            // Savings percentage
                            VStack(spacing: 8) {
                                Text("Saved \(Int(summary.savingsPercentage))% of income")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                ProgressView(value: summary.savingsPercentage / 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                        }
                        .padding(24)
                        .background(Color.appGradient)
                        .cornerRadius(20)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Achievements
                        if !summary.achievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.yellow)
                                    
                                    Text("Achievements")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primaryText)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(summary.achievements, id: \.self) { achievement in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.yellow.opacity(0.2))
                                                .frame(width: 8, height: 8)
                                            
                                            Text(achievement)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primaryText)
                                            
                                            Spacer()
                                        }
                                        .padding(16)
                                        .background(Color.cardBackground)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Category Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.accentPurple)
                                
                                Text("Category Breakdown")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primaryText)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(summary.budgetCategories, id: \.name) { category in
                                    CategorySummaryCard(category: category)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Insights
                        if !summary.insights.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.orange)
                                    
                                    Text("Insights")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primaryText)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(summary.insights, id: \.self) { insight in
                                        HStack(alignment: .top, spacing: 12) {
                                            Circle()
                                                .fill(Color.accentPurple)
                                                .frame(width: 6, height: 6)
                                                .padding(.top, 6)
                                            
                                            Text(insight)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.primaryText)
                                            
                                            Spacer()
                                        }
                                        .padding(16)
                                        .background(Color.accentPurple.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Monthly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accentPurple)
                }
            }
        }
    }
}

// MARK: - Category Summary Card
struct CategorySummaryCard: View {
    let category: CategorySummary
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(categoryColor(category.color))
                    .frame(width: 40, height: 40)
                    .background(categoryColor(category.color).opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryText)
                    
                    HStack(spacing: 6) {
                        Text("$\(Int(category.spent))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(category.wasOverBudget ? .red : .primaryText)
                        
                        Text("/ $\(Int(category.budgeted))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(category.percentageUsed))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(category.wasOverBudget ? .red : .green)
                    
                    if category.wasOverBudget {
                        Text("Over")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.red)
                    } else {
                        Text("Under")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(category.wasOverBudget ? Color.red : Color.green)
                        .frame(width: geometry.size.width * min(category.percentageUsed / 100, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(category.wasOverBudget ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
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
        default: return .gray
        }
    }
}

#Preview {
    MonthlySummaryView(
        summary: MonthlySummary(
            userId: "test",
            month: 2,
            year: 2026,
            totalIncome: 3000,
            totalSpent: 2200,
            totalSaved: 800,
            savingsGoalMet: true,
            budgetCategories: [
                CategorySummary(
                    name: "Food",
                    budgeted: 450,
                    spent: 420,
                    percentageUsed: 93,
                    icon: "fork.knife",
                    color: "orange"
                )
            ],
            achievements: [
                "🎯 Hit your savings goal!",
                "💎 Saved 20%+ of income"
            ],
            insights: [
                "💚 Great job! You only spent 73% of income"
            ]
        )
    )
}
