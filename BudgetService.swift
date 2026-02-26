import Foundation

class BudgetService {
    // Replace with your actual Anthropic API key
    private let apiKey = "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"
    private let apiURL = "https://api.anthropic.com/v1/messages"
    
    func generateBudget(
        age: String,
        location: String,
        relationshipStatus: String,
        monthlyIncome: String,
        rent: String,
        utilities: String,
        phone: String,
        transportation: String,
        subscriptions: String,
        savingsGoal: String,
        savingsTimeframe: String,
        hasPets: Bool,  // NEW
        pets: [Pet],  // NEW
        hasKids: Bool,  // NEW
        numberOfKids: String,  // NEW
        monthlyKidExpenses: String  // NEW
    ) async throws -> BudgetItem {
        
        let fixedExpenses = [rent, utilities, phone, transportation, subscriptions]
            .compactMap { Double($0) }
            .reduce(0, +)
        
        let petExpenses = pets.compactMap { Double($0.monthlyExpenses) }.reduce(0, +)
        let kidExpenses = Double(monthlyKidExpenses) ?? 0
        
        let income = Double(monthlyIncome) ?? 0
        
        // Build pets description
        var petsDescription = ""
        if hasPets && !pets.isEmpty {
            let petList = pets.map { "\($0.emoji) \($0.name) (\($0.type.rawValue))" }.joined(separator: ", ")
            petsDescription = "\n- Pets: \(petList) - Monthly expenses: $\(String(format: "%.2f", petExpenses))"
        }
        
        // Build kids description
        var kidsDescription = ""
        if hasKids {
            kidsDescription = "\n- Kids: \(numberOfKids) children - Monthly expenses: $\(monthlyKidExpenses)"
        }
        
        let prompt = """
        You are a financial advisor helping a \(age)-year-old person who is \(relationshipStatus.lowercased()) and lives in \(location).
        
        Their financial situation:
        - Location: \(location) (IMPORTANT: Consider local cost of living, average food prices, and regional expenses)
        - Monthly income (after tax): $\(monthlyIncome)
        - Fixed expenses (rent, utilities, phone, transport, subscriptions): $\(String(format: "%.2f", fixedExpenses))\(petsDescription)\(kidsDescription)
        - Money available after fixed expenses: $\(String(format: "%.2f", income - fixedExpenses - petExpenses - kidExpenses))
        - Savings goal: $\(savingsGoal) in \(savingsTimeframe)
        
        Please provide a location-aware monthly budget recommendation:
        1. Food budget - adjust for local grocery and restaurant prices in \(location)
        2. Entertainment/miscellaneous - adjust for local activity costs
        3. Savings amount (considering their goal and cost of living)
        4. Personalized advice mentioning their location\(hasPets ? " and pets" : "")\(hasKids ? " and kids" : "")
        
        Respond ONLY in this exact JSON format (no markdown, no extra text):
        {
            "food": 450,
            "miscellaneous": 300,
            "savings": 500,
            "advice": "Your personalized advice here mentioning their location\(hasPets ? ", pets" : "")\(hasKids ? ", and kids" : "")",
            "breakdown": "Brief explanation mentioning how location\(hasPets ? ", pets" : "")\(hasKids ? ", and kids" : "") affect the budget"
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        guard let responseData = text.data(using: .utf8),
              let budgetJSON = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let food = budgetJSON["food"] as? Double,
              let misc = budgetJSON["miscellaneous"] as? Double,
              let savings = budgetJSON["savings"] as? Double,
              let advice = budgetJSON["advice"] as? String,
              let breakdown = budgetJSON["breakdown"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        let remaining = income - fixedExpenses - food - misc - savings
        let savingsPercent = (savings / income) * 100
        
        return BudgetItem(
            monthlyFood: food,
            monthlyMiscellaneous: misc,
            monthlySavings: savings,
            remainingMoney: remaining,
            savingsPercentage: savingsPercent,
            personalizedAdvice: advice,
            breakdown: breakdown
        )
    }
}

struct BudgetItem {
    let monthlyFood: Double
    let monthlyMiscellaneous: Double
    let monthlySavings: Double
    let remainingMoney: Double
    let savingsPercentage: Double
    let personalizedAdvice: String
    let breakdown: String
}
