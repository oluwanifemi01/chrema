import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    var id: String = UUID().uuidString
    var amount: Double
    var category: ExpenseCategory
    var description: String
    var date: Date
    var userId: String
    var isRecurring: Bool = false  // NEW
    var recurringFrequency: RecurringFrequency? = nil  // NEW
    
    enum CodingKeys: String, CodingKey {
        case id, amount, category, description, date, userId, isRecurring, recurringFrequency
    }
}

// MARK: - Recurring Frequency
enum RecurringFrequency: String, Codable {
    case monthly = "Monthly"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    
    var icon: String {
        switch self {
        case .monthly: return "calendar"
        case .weekly: return "calendar.badge.clock"
        case .biweekly: return "calendar.badge.exclamationmark"
        }
    }
}

// MARK: - Expense Category
enum ExpenseCategory: String, Codable, CaseIterable {
    case food = "Food"
    case entertainment = "Entertainment"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case pets = "Pets"  // NEW
    case kids = "Kids"  // NEW
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .entertainment: return "sparkles"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        case .pets: return "pawprint.fill"  // NEW
        case .kids: return "figure.2.and.child.holdinghands"  // NEW
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "orange"
        case .entertainment: return "purple"
        case .transport: return "blue"
        case .shopping: return "pink"
        case .bills: return "red"
        case .pets: return "brown"  // NEW
        case .kids: return "green"  // NEW
        case .other: return "gray"
        }
    }
}

// MARK: - Expense Manager
class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    // Add new expense
    func addExpense(amount: Double, category: ExpenseCategory, description: String, date: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let expense = Expense(
            amount: amount,
            category: category,
            description: description,
            date: date,
            userId: userId
        )
        
        // Add to Firestore
        do {
            let _ = try db.collection("expenses").document(expense.id).setData([
                "id": expense.id,
                "amount": expense.amount,
                "category": expense.category.rawValue,
                "description": expense.description,
                "date": Timestamp(date: expense.date),
                "userId": expense.userId
            ])
            
            // Add to local array
            DispatchQueue.main.async {
                self.expenses.insert(expense, at: 0)
            }
            
        } catch {
            print("Error adding expense: \(error.localizedDescription)")
        }
    }
    
    // Load expenses from Firestore
    func loadExpenses() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading expenses: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                let loadedExpenses = documents.compactMap { doc -> Expense? in
                    let data = doc.data()
                    guard let id = data["id"] as? String,
                          let amount = data["amount"] as? Double,
                          let categoryString = data["category"] as? String,
                          let category = ExpenseCategory(rawValue: categoryString),
                          let description = data["description"] as? String,
                          let timestamp = data["date"] as? Timestamp else {
                        return nil
                    }
                    
                    let isRecurring = data["isRecurring"] as? Bool ?? false
                    let recurringFrequency: RecurringFrequency? = {
                        if let freqString = data["recurringFrequency"] as? String {
                            return RecurringFrequency(rawValue: freqString)
                        }
                        return nil
                    }()
                    
                    return Expense(
                        id: id,
                        amount: amount,
                        category: category,
                        description: description,
                        date: timestamp.dateValue(),
                        userId: userId,
                        isRecurring: isRecurring,
                        recurringFrequency: recurringFrequency
                    )
                }
                
                DispatchQueue.main.async {
                    self.expenses = loadedExpenses
                    self.isLoading = false
                }
            }
    }
    
    // Delete expense
    func deleteExpense(_ expense: Expense) {
        db.collection("expenses").document(expense.id).delete { [weak self] error in
            if let error = error {
                print("Error deleting expense: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.expenses.removeAll { $0.id == expense.id }
                }
            }
        }
    }
    
    // Get total spent this month
    func getTotalSpentThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        return expenses
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Get spending by category this month
    func getSpendingByCategory() -> [ExpenseCategory: Double] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonthExpenses = expenses.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        var categoryTotals: [ExpenseCategory: Double] = [:]
        for expense in thisMonthExpenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        
        return categoryTotals
    }
    
    // MARK: - Add Recurring Expense
    func addRecurringExpense(
        amount: Double,
        category: ExpenseCategory,
        description: String,
        date: Date,
        frequency: RecurringFrequency
    ) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let expense = Expense(
            amount: amount,
            category: category,
            description: description,
            date: date,
            userId: userId,
            isRecurring: true,
            recurringFrequency: frequency
        )
        
        // Add to Firestore
        do {
            let _ = try db.collection("expenses").document(expense.id).setData([
                "id": expense.id,
                "amount": expense.amount,
                "category": expense.category.rawValue,
                "description": expense.description,
                "date": Timestamp(date: expense.date),
                "userId": expense.userId,
                "isRecurring": expense.isRecurring,
                "recurringFrequency": expense.recurringFrequency?.rawValue ?? ""
            ])
            
            // Add to local array
            DispatchQueue.main.async {
                self.expenses.insert(expense, at: 0)
            }
            
        } catch {
            print("Error adding recurring expense: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Process Recurring Expenses
    func processRecurringExpenses() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Get all recurring expenses
        db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .whereField("isRecurring", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                
                for doc in documents {
                    let data = doc.data()
                    guard let lastDate = (data["date"] as? Timestamp)?.dateValue(),
                          let frequencyString = data["recurringFrequency"] as? String,
                          let frequency = RecurringFrequency(rawValue: frequencyString),
                          let amount = data["amount"] as? Double,
                          let categoryString = data["category"] as? String,
                          let category = ExpenseCategory(rawValue: categoryString),
                          let description = data["description"] as? String else {
                        continue
                    }
                    
                    // Check if we need to create a new instance
                    var shouldCreate = false
                    var newDate = lastDate
                    
                    switch frequency {
                    case .monthly:
                        if let monthsDiff = calendar.dateComponents([.month], from: lastDate, to: today).month,
                           monthsDiff >= 1 {
                            shouldCreate = true
                            newDate = calendar.date(byAdding: .month, value: 1, to: lastDate) ?? today
                        }
                    case .weekly:
                        if let weeksDiff = calendar.dateComponents([.weekOfYear], from: lastDate, to: today).weekOfYear,
                           weeksDiff >= 1 {
                            shouldCreate = true
                            newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: lastDate) ?? today
                        }
                    case .biweekly:
                        if let weeksDiff = calendar.dateComponents([.weekOfYear], from: lastDate, to: today).weekOfYear,
                           weeksDiff >= 2 {
                            shouldCreate = true
                            newDate = calendar.date(byAdding: .weekOfYear, value: 2, to: lastDate) ?? today
                        }
                    }
                    
                    if shouldCreate {
                        // Create new expense instance
                        self.addExpense(
                            amount: amount,
                            category: category,
                            description: description,
                            date: newDate
                        )
                    }
                }
            }
    }
    
    // MARK: - Get Recurring Expenses
    func getRecurringExpenses() -> [Expense] {
        return expenses.filter { $0.isRecurring }
    }
    
    // MARK: - Export Expenses
    func exportExpensesAsCSV() -> String {
        var csv = "Date,Category,Description,Amount\n"
        
        for expense in expenses {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: expense.date)
            
            csv += "\(dateString),\(expense.category.rawValue),\(expense.description),\(expense.amount)\n"
        }
        
        return csv
    }
    
    func shareExpenses() -> URL? {
        let csv = exportExpensesAsCSV()
        
        let fileName = "Chrema_Expenses_\(Date().timeIntervalSince1970).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csv.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Error creating CSV: \(error)")
            return nil
        }
    }
}
