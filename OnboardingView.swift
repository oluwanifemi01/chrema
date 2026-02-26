import SwiftUI


// MARK: - Pet Model
struct Pet: Identifiable, Codable {
    var id = UUID()
    var type: PetType
    var name: String
    var monthlyExpenses: String
    
    var emoji: String {
        switch type {
        case .dog: return "🐕"
        case .cat: return "🐱"
        case .other: return "🐾"
        }
    }
}

enum PetType: String, Codable, CaseIterable {
    case dog = "Dog"
    case cat = "Cat"
    case other = "Other"
}

struct OnboardingView: View {
    @ObservedObject var authManager: AuthenticationManager
        @Binding var showOnboarding: Bool
        @State private var currentStep = 0
        @State private var age = ""
        @State private var location = ""
        @State private var relationshipStatus = "Single"
        @State private var hasPets = false  // NEW
        @State private var pets: [Pet] = []  // NEW
        @State private var hasKids = false  // NEW
        @State private var numberOfKids = ""  // NEW
        @State private var monthlyKidExpenses = ""  // NEW
        @State private var monthlyIncome = ""
        @State private var rent = ""
        @State private var utilities = ""
        @State private var phone = ""
        @State private var transportation = ""
        @State private var subscriptions = ""
        @State private var savingsGoal = ""
        @State private var savingsTimeframe = "6 months"
        
        let relationshipOptions = ["Single", "In a relationship", "Married"]
        let timeframeOptions = ["3 months", "6 months", "1 year", "2 years", "5 years"]
        
    let totalSteps = 8
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.3, blue: 0.8),
                    Color(red: 0.3, green: 0.5, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Step \(currentStep + 1) of \(totalSteps)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(Int((Double(currentStep + 1) / Double(totalSteps)) * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 6)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 24) {
                            switch currentStep {
                            case 0:
                                AgeQuestionView(age: $age)
                            case 1:
                                LocationQuestionView(location: $location)
                            case 2:
                                RelationshipQuestionView(relationshipStatus: $relationshipStatus, options: relationshipOptions)
                            case 3:
                                PetsQuestionView(hasPets: $hasPets, pets: $pets)  // NEW - Combined
                            case 4:
                                KidsQuestionView(hasKids: $hasKids, numberOfKids: $numberOfKids, monthlyKidExpenses: $monthlyKidExpenses)  // NEW - Combined
                            case 5:
                                IncomeQuestionView(monthlyIncome: $monthlyIncome)
                            case 6:
                                ExpensesQuestionView(
                                    rent: $rent,
                                    utilities: $utilities,
                                    phone: $phone,
                                    transportation: $transportation,
                                    subscriptions: $subscriptions
                                )
                            case 7:
                                SavingsGoalQuestionView(
                                    savingsGoal: $savingsGoal,
                                    savingsTimeframe: $savingsTimeframe,
                                    timeframeOptions: timeframeOptions
                                )
                            default:
                                Text("Done!")
                            }
                        }
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    .padding(.top, 20)
                }
                
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentStep -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                            )
                        }
                    }
                    
                    Button(action: {
                        if currentStep < totalSteps - 1 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentStep += 1
                            }
                        } else {
                            // Save data to Firebase
                            authManager.saveUserData(
                                age: age,
                                location: location,
                                relationshipStatus: relationshipStatus,
                                monthlyIncome: monthlyIncome,
                                rent: rent,
                                utilities: utilities,
                                phone: phone,
                                transportation: transportation,
                                subscriptions: subscriptions,
                                savingsGoal: savingsGoal,
                                savingsTimeframe: savingsTimeframe,
                                hasPets: hasPets,  // NEW
                                pets: pets,  // NEW
                                hasKids: hasKids,  // NEW
                                numberOfKids: numberOfKids,  // NEW
                                monthlyKidExpenses: monthlyKidExpenses  // NEW
                            )
                            
                            // Also set it directly for immediate use
                            authManager.userData = UserFinancialData(
                                age: age,
                                location: location,
                                relationshipStatus: relationshipStatus,
                                monthlyIncome: monthlyIncome,
                                rent: rent,
                                utilities: utilities,
                                phone: phone,
                                transportation: transportation,
                                subscriptions: subscriptions,
                                savingsGoal: savingsGoal,
                                savingsTimeframe: savingsTimeframe,
                                hasPets: hasPets,  // NEW
                                pets: pets,  // NEW
                                hasKids: hasKids,  // NEW
                                numberOfKids: numberOfKids,  // NEW
                                monthlyKidExpenses: monthlyKidExpenses  // NEW
                            )
                            
                            showOnboarding = false
                        }
                    }) {
                        HStack {
                            Text(currentStep < totalSteps - 1 ? "Continue" : "Finish")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isCurrentStepInvalid())
                    .opacity(isCurrentStepInvalid() ? 0.5 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Validation
    func isCurrentStepInvalid() -> Bool {
        switch currentStep {
        case 0:
            // Age step
            return age.isEmpty
        case 1:
            // Location step - must have both city and state
            return location.isEmpty
        case 2:
            // Relationship status - always valid (has default)
            return false
        case 3:
            // Pets - if they said yes, they need at least one pet
            return hasPets && pets.isEmpty
        case 4:
            // Kids - if they said yes, they need to fill in details
            return hasKids && (numberOfKids.isEmpty || monthlyKidExpenses.isEmpty)
        case 5:
            // Income step
            return monthlyIncome.isEmpty
        case 6:
            // Expenses - at least one field should be filled
            return rent.isEmpty && utilities.isEmpty && phone.isEmpty && transportation.isEmpty && subscriptions.isEmpty
        case 7:
            // Savings goal
            return savingsGoal.isEmpty
        default:
            return false
        }
    }
}

// MARK: - Individual Question Views

struct AgeQuestionView: View {
    @Binding var age: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("How old are you?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("This helps us personalize your budget recommendations")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            TextField("Enter your age", text: $age)
                .keyboardType(.numberPad)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.appPrimaryText)
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
        }
    }
}

struct LocationQuestionView: View {
    @Binding var location: String
    @State private var selectedState = "Select State"
    @State private var city = ""
    @State private var showStatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Where do you live?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("We'll adjust recommendations based on your local cost of living")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            // City Input
            VStack(alignment: .leading, spacing: 8) {
                Text("City")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                TextField("Enter your city", text: $city)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.appPrimaryText)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .onChange(of: city) { oldValue, newValue in
                        updateLocation()
                    }
            }
            
            // State Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("State")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                Button(action: {
                    showStatePicker = true
                }) {
                    HStack {
                        Text(selectedState)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(selectedState == "Select State" ? .gray : .black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            // Preview of full location
            if !city.isEmpty && selectedState != "Select State" {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    
                    Text("\(city), \(selectedState)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1))
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showStatePicker) {
            StatePickerSheet(selectedState: $selectedState, showPicker: $showStatePicker, onSelect: {
                updateLocation()
            })
        }
        .onAppear {
            // If location already has a value, parse it
            if !location.isEmpty {
                parseExistingLocation()
            }
        }
    }
    
    func updateLocation() {
        if !city.isEmpty && selectedState != "Select State" {
            location = "\(city), \(selectedState)"
        } else {
            location = ""
        }
    }
    
    func parseExistingLocation() {
        // Parse "City, State" format
        let components = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if components.count == 2 {
            city = components[0]
            selectedState = components[1]
        }
    }
}

// MARK: - State Picker Sheet
struct StatePickerSheet: View {
    @Binding var selectedState: String
    @Binding var showPicker: Bool
    let onSelect: () -> Void
    @State private var searchText = ""
    
    var filteredStates: [String] {
        if searchText.isEmpty {
            return usStates
        } else {
            return usStates.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search states", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(.appPrimaryText)
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // States list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredStates, id: \.self) { state in
                            Button(action: {
                                selectedState = state
                                onSelect()
                                showPicker = false
                            }) {
                                HStack {
                                    Text(state)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.appPrimaryText)
                                    
                                    Spacer()
                                    
                                    if selectedState == state {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showPicker = false
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }
        }
    }
}


struct RelationshipQuestionView: View {
    @Binding var relationshipStatus: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Relationship status")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("Helps us understand your financial situation")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        relationshipStatus = option
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(relationshipStatus == option ? .white : .black)
                            
                            Spacer()
                            
                            if relationshipStatus == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(relationshipStatus == option ?
                                      LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                                )
                        )
                    }
                }
            }
        }
    }
}

struct IncomeQuestionView: View {
    @Binding var monthlyIncome: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly income")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("Enter your take-home pay (after taxes)")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("$")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.gray)
                
                TextField("0", text: $monthlyIncome)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
}

struct ExpensesQuestionView: View {
    @Binding var rent: String
    @Binding var utilities: String
    @Binding var phone: String
    @Binding var transportation: String
    @Binding var subscriptions: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Fixed expenses")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("Monthly bills and recurring costs")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 12) {
                ExpenseField(icon: "house.fill", label: "Rent/Mortgage", value: $rent)
                ExpenseField(icon: "bolt.fill", label: "Utilities", value: $utilities)
                ExpenseField(icon: "phone.fill", label: "Phone", value: $phone)
                ExpenseField(icon: "car.fill", label: "Transportation", value: $transportation)
                ExpenseField(icon: "tv.fill", label: "Subscriptions", value: $subscriptions)
            }
        }
    }
}

struct ExpenseField: View {
    let icon: String
    let label: String
    @Binding var value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appPrimaryText)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("$")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appPrimaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct SavingsGoalQuestionView: View {
    @Binding var savingsGoal: String
    @Binding var savingsTimeframe: String
    let timeframeOptions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Savings goal")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("What are you saving for?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("$")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.gray)
                
                TextField("0", text: $savingsGoal)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Timeframe")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimaryText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(timeframeOptions, id: \.self) { option in
                            Button(action: {
                                savingsTimeframe = option
                            }) {
                                Text(option)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(savingsTimeframe == option ? .white : .black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(savingsTimeframe == option ?
                                                  Color(red: 0.4, green: 0.3, blue: 0.8) :
                                                  Color.gray.opacity(0.1)
                                            )
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Pets Question View
struct PetsQuestionView: View {
    @Binding var hasPets: Bool
    @Binding var pets: [Pet]
    @State private var showAddPet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Do you have pets?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("We'll help you budget for your furry friends")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            // Yes/No Toggle
            HStack(spacing: 12) {
                Button(action: {
                    hasPets = false
                    pets = []
                }) {
                    Text("No")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(!hasPets ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(!hasPets ?
                                      LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                                )
                        )
                }
                
                Button(action: {
                    hasPets = true
                }) {
                    Text("Yes")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(hasPets ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(hasPets ?
                                      LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                                )
                        )
                }
            }
            
            if hasPets {
                VStack(spacing: 16) {
                    // List of pets
                    ForEach(pets) { pet in
                        HStack(spacing: 12) {
                            Text(pet.emoji)
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pet.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appPrimaryText)
                                
                                Text("\(pet.type.rawValue) • $\(pet.monthlyExpenses)/month")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                pets.removeAll { $0.id == pet.id }
                                if pets.isEmpty {
                                    hasPets = false
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Add Pet Button
                    Button(action: {
                        showAddPet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            
                            Text("Add Another Pet")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPet) {
            AddPetSheet(pets: $pets)
        }
        .onAppear {
            if hasPets && pets.isEmpty {
                showAddPet = true
            }
        }
    }
}

// MARK: - Add Pet Sheet
struct AddPetSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var pets: [Pet]
    
    @State private var petType: PetType = .dog
    @State private var petName = ""
    @State private var monthlyExpenses = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Pet Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pet Type")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appPrimaryText)
                            
                            HStack(spacing: 12) {
                                ForEach(PetType.allCases, id: \.self) { type in
                                    Button(action: {
                                        petType = type
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(type == .dog ? "🐕" : type == .cat ? "🐱" : "🐾")
                                                .font(.system(size: 40))
                                            
                                            Text(type.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(petType == type ? .white : .appPrimaryText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            petType == type ?
                                            LinearGradient(
                                                colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)],
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
                                    }
                                }
                            }
                        }
                        
                        // Pet Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pet Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appPrimaryText)
                            
                            TextField("e.g., Max, Bella, Fluffy", text: $petName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appPrimaryText)
                                .padding(18)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Monthly Expenses
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Expenses")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appPrimaryText)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                TextField("0", text: $monthlyExpenses)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.appPrimaryText)
                            }
                            .padding(18)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            Text("Include food, treats, vet visits, grooming, etc.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        // Add Button
                        Button(action: {
                            let newPet = Pet(
                                type: petType,
                                name: petName,
                                monthlyExpenses: monthlyExpenses
                            )
                            pets.append(newPet)
                            dismiss()
                        }) {
                            Text("Add Pet")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
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
                        .disabled(petName.isEmpty || monthlyExpenses.isEmpty)
                        .opacity((petName.isEmpty || monthlyExpenses.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add Pet")
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
}

// MARK: - Kids Question View
struct KidsQuestionView: View {
    @Binding var hasKids: Bool
    @Binding var numberOfKids: String
    @Binding var monthlyKidExpenses: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Do you have kids?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appPrimaryText)
                
                Text("We'll help you budget for childcare and expenses")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            // Yes/No Toggle
            HStack(spacing: 12) {
                Button(action: {
                    hasKids = false
                    numberOfKids = ""
                    monthlyKidExpenses = ""
                }) {
                    Text("No")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(!hasKids ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(!hasKids ?
                                      LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                                )
                        )
                }
                
                Button(action: {
                    hasKids = true
                }) {
                    Text("Yes")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(hasKids ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(hasKids ?
                                      LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                                )
                        )
                }
            }
            
            if hasKids {
                VStack(spacing: 16) {
                    // Number of Kids
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Kids")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        TextField("How many?", text: $numberOfKids)
                            .keyboardType(.numberPad)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.appPrimaryText)
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    
                    // Monthly Expenses
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Kid Expenses")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("0", text: $monthlyKidExpenses)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.appPrimaryText)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                        
                        Text("Childcare, school, activities, etc.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// MARK: - US States List
let usStates = [
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
    "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
    "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
    "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
    "New Hampshire", "New Jersey", "New Mexico", "New York",
    "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
    "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
    "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
    "West Virginia", "Wisconsin", "Wyoming"
]

#Preview {
    OnboardingView(authManager: AuthenticationManager(), showOnboarding: .constant(true))
}
