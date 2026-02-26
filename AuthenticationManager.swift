import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import Combine

class AuthenticationManager: ObservableObject {
    @Published var userIsLoggedIn = false
    @Published var currentUser: User?
    @Published var userData: UserFinancialData?
    @Published var savedBudget: SavedBudget?
    
    private let db = Firestore.firestore()
    private var currentNonce: String?
    
    init() {
        // Check if user is already logged in
        if Auth.auth().currentUser != nil {
            userIsLoggedIn = true
            
            // Load data immediately
            Task {
                await loadDataOnStartup()
            }
        }
    }
    
    // MARK: - Load Data on Startup
    private func loadDataOnStartup() async {
        // Load user data first
        loadUserData()
        
        // Wait a bit for Firestore to respond
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Then load saved budget
        loadSavedBudget()
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.userIsLoggedIn = true
                }
            }
        }
    }
    
    // MARK: - Apple Sign In Helpers
    private func generateRandomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func generateSha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - Apple Sign In
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = generateRandomNonceString()
        currentNonce = nonce
        request.nonce = generateSha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result {
            print("Authorization failed: \(error.localizedDescription)")
            return
        }
        
        guard case .success(let authorization) = result else {
            return
        }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data")
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.userIsLoggedIn = true
                }
            }
        }
    }
    
    // MARK: - Save User Data
    func saveUserData(
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
    ) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Convert pets to dictionary array
        let petsData = pets.map { pet -> [String: Any] in
            return [
                "type": pet.type.rawValue,
                "name": pet.name,
                "monthlyExpenses": pet.monthlyExpenses
            ]
        }
        
        let userData: [String: Any] = [
            "age": age,
            "location": location,
            "relationshipStatus": relationshipStatus,
            "monthlyIncome": monthlyIncome,
            "fixedExpenses": [
                "rent": rent,
                "utilities": utilities,
                "phone": phone,
                "transportation": transportation,
                "subscriptions": subscriptions
            ],
            "savingsGoal": savingsGoal,
            "savingsTimeframe": savingsTimeframe,
            "hasPets": hasPets,  // NEW
            "pets": petsData,  // NEW
            "hasKids": hasKids,  // NEW
            "numberOfKids": numberOfKids,  // NEW
            "monthlyKidExpenses": monthlyKidExpenses,  // NEW
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).setData(userData) { [weak self] error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                self?.loadUserData()
            }
        }
    }
    
    // MARK: - Load User Data
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error loading user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                let age = data["age"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let relationshipStatus = data["relationshipStatus"] as? String ?? ""
                let monthlyIncome = data["monthlyIncome"] as? String ?? ""
                let savingsGoal = data["savingsGoal"] as? String ?? ""
                let savingsTimeframe = data["savingsTimeframe"] as? String ?? ""
                
                let fixedExpenses = data["fixedExpenses"] as? [String: String] ?? [:]
                let rent = fixedExpenses["rent"] ?? ""
                let utilities = fixedExpenses["utilities"] ?? ""
                let phone = fixedExpenses["phone"] ?? ""
                let transportation = fixedExpenses["transportation"] ?? ""
                let subscriptions = fixedExpenses["subscriptions"] ?? ""
                
                // Load pets
                let hasPets = data["hasPets"] as? Bool ?? false
                var pets: [Pet] = []
                if let petsData = data["pets"] as? [[String: Any]] {
                    pets = petsData.compactMap { petDict -> Pet? in
                        guard let typeString = petDict["type"] as? String,
                              let type = PetType(rawValue: typeString),
                              let name = petDict["name"] as? String,
                              let expenses = petDict["monthlyExpenses"] as? String else {
                            return nil
                        }
                        return Pet(type: type, name: name, monthlyExpenses: expenses)
                    }
                }
                
                // Load kids
                let hasKids = data["hasKids"] as? Bool ?? false
                let numberOfKids = data["numberOfKids"] as? String ?? ""
                let monthlyKidExpenses = data["monthlyKidExpenses"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self?.userData = UserFinancialData(
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
                        hasPets: hasPets,
                        pets: pets,
                        hasKids: hasKids,
                        numberOfKids: numberOfKids,
                        monthlyKidExpenses: monthlyKidExpenses
                    )
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.userIsLoggedIn = false
                self.currentUser = nil
                self.userData = nil
                self.savedBudget = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Budget
    func saveBudget(_ budget: BudgetItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let budgetData: [String: Any] = [
            "monthlyFood": budget.monthlyFood,
            "monthlyMiscellaneous": budget.monthlyMiscellaneous,
            "monthlySavings": budget.monthlySavings,
            "remainingMoney": budget.remainingMoney,
            "savingsPercentage": budget.savingsPercentage,
            "personalizedAdvice": budget.personalizedAdvice,
            "breakdown": budget.breakdown,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).updateData(["budget": budgetData]) { error in
            if let error = error {
                print("Error saving budget: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Load Budget
    func loadSavedBudget() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error loading budget: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let data = document.data(),
               let budgetData = data["budget"] as? [String: Any],
               let food = budgetData["monthlyFood"] as? Double,
               let misc = budgetData["monthlyMiscellaneous"] as? Double,
               let savings = budgetData["monthlySavings"] as? Double,
               let remaining = budgetData["remainingMoney"] as? Double,
               let percentage = budgetData["savingsPercentage"] as? Double,
               let advice = budgetData["personalizedAdvice"] as? String,
               let breakdown = budgetData["breakdown"] as? String,
               let timestamp = budgetData["createdAt"] as? Timestamp {
                
                DispatchQueue.main.async {
                    self?.savedBudget = SavedBudget(
                        monthlyFood: food,
                        monthlyMiscellaneous: misc,
                        monthlySavings: savings,
                        remainingMoney: remaining,
                        savingsPercentage: percentage,
                        personalizedAdvice: advice,
                        breakdown: breakdown,
                        createdAt: timestamp.dateValue()
                    )
                }
            }
        }
    }
}

struct User {
    var id: String
    var age: String
    var relationshipStatus: String
    var monthlyIncome: String
}

struct UserFinancialData {
    let age: String
    let location: String
    let relationshipStatus: String
    let monthlyIncome: String
    let rent: String
    let utilities: String
    let phone: String
    let transportation: String
    let subscriptions: String
    let savingsGoal: String
    let savingsTimeframe: String
    let hasPets: Bool  // NEW
    let pets: [Pet]  // NEW
    let hasKids: Bool  // NEW
    let numberOfKids: String  // NEW
    let monthlyKidExpenses: String  // NEW
}
struct SavedBudget: Codable {
    let monthlyFood: Double
    let monthlyMiscellaneous: Double
    let monthlySavings: Double
    let remainingMoney: Double
    let savingsPercentage: Double
    let personalizedAdvice: String
    let breakdown: String
    let createdAt: Date
}

