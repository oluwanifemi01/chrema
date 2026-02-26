//
//  CustomBudgetCategory.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/24/26.
//
import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth


// MARK: - Custom Budget Category Model
struct CustomBudgetCategory: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var icon: String  // SF Symbol name
    var monthlyBudget: Double
    var color: String  // Color identifier
    var isCustom: Bool
    var userId: String
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, monthlyBudget, color, isCustom, userId, createdAt
    }
    
    // Predefined color options
    static let availableColors = [
        "orange", "purple", "blue", "pink", "red", "brown", "green",
        "yellow", "teal", "indigo", "cyan", "mint"
    ]
    
    // Popular icon suggestions
    static let popularIcons = [
        "cup.and.saucer.fill",    // Coffee
        "gamecontroller.fill",     // Gaming
        "dumbbell.fill",          // Gym
        "book.fill",              // Books
        "graduationcap.fill",     // Education
        "cross.case.fill",        // Health
        "airplane",               // Travel
        "gift.fill",              // Gifts
        "paintbrush.fill",        // Hobbies
        "house.fill",             // Home
        "wrench.and.screwdriver.fill",  // Repairs
        "cart.fill",              // Shopping
        "film.fill",              // Movies
        "music.note",             // Music
        "leaf.fill"               // Environment
    ]
}

// MARK: - Budget Category Manager
class BudgetCategoryManager: ObservableObject {
    @Published var customCategories: [CustomBudgetCategory] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Load Categories
    func loadCategories() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("budgetCategories")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading categories: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                self.customCategories = documents.compactMap { doc -> CustomBudgetCategory? in
                    let data = doc.data()
                    guard let id = data["id"] as? String,
                          let name = data["name"] as? String,
                          let icon = data["icon"] as? String,
                          let monthlyBudget = data["monthlyBudget"] as? Double,
                          let color = data["color"] as? String,
                          let isCustom = data["isCustom"] as? Bool,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return CustomBudgetCategory(
                        id: id,
                        name: name,
                        icon: icon,
                        monthlyBudget: monthlyBudget,
                        color: color,
                        isCustom: isCustom,
                        userId: userId,
                        createdAt: timestamp.dateValue()
                    )
                }
                
                self.isLoading = false
            }
    }
    
    // MARK: - Add Category
    func addCategory(name: String, icon: String, monthlyBudget: Double, color: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let category = CustomBudgetCategory(
            name: name,
            icon: icon,
            monthlyBudget: monthlyBudget,
            color: color,
            isCustom: true,
            userId: userId
        )
        
        do {
            try db.collection("budgetCategories").document(category.id).setData([
                "id": category.id,
                "name": category.name,
                "icon": category.icon,
                "monthlyBudget": category.monthlyBudget,
                "color": category.color,
                "isCustom": category.isCustom,
                "userId": category.userId,
                "createdAt": Timestamp(date: category.createdAt)
            ])
        } catch {
            print("Error adding category: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update Category
    func updateCategory(_ category: CustomBudgetCategory) {
        db.collection("budgetCategories").document(category.id).updateData([
            "name": category.name,
            "icon": category.icon,
            "monthlyBudget": category.monthlyBudget,
            "color": category.color
        ]) { error in
            if let error = error {
                print("Error updating category: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Delete Category
    func deleteCategory(_ category: CustomBudgetCategory) {
        db.collection("budgetCategories").document(category.id).delete { error in
            if let error = error {
                print("Error deleting category: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Get Total Custom Budget
    func getTotalCustomBudget() -> Double {
        return customCategories.reduce(0) { $0 + $1.monthlyBudget }
    }
}
