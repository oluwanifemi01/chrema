import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct SettingsView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    @State private var showExpenseHistory = false
    @StateObject private var expenseManager = ExpenseManager()
    @State private var showPrivacyPolicy = false  // ADD THIS
    @State private var showTerms = false  // ADD THIS
    @State private var showRecurringExpenses = false  // NEW
    @State private var showRegenerateConfirmation = false  // NEW
    @State private var showBudgetPreferences = false  // ADD THIS
    
    var userEmail: String {
        Auth.auth().currentUser?.email ?? "No email"
    }
    
    var userDisplayName: String {
        Auth.auth().currentUser?.displayName ?? "User"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primaryText)  // UPDATED
                    
                    Text("Manage your account")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondaryText)  // UPDATED
                }
                .padding(.top, 60)
                
                // Profile Section
                VStack(spacing: 20) {
                    // Profile Photo
                    ZStack {
                        Circle()
                            .fill(Color.appGradient)  // UPDATED
                            .frame(width: 100, height: 100)
                        
                        Text(userDisplayName.prefix(1).uppercased())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Camera button overlay
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                        .frame(width: 100, height: 100)
                    }
                    
                    VStack(spacing: 4) {
                        Text(userDisplayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primaryText)  // UPDATED
                        
                        Text(userEmail)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondaryText)  // UPDATED
                    }
                    
                    Text("Tap photo to change")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondaryText.opacity(0.7))  // UPDATED
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)  // UPDATED
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 24)
                
                // Account Settings
                VStack(spacing: 0) {
                    SettingsRow(
                        icon: "list.bullet.rectangle.fill",
                        title: "Expense History",
                        subtitle: "View all your transactions",
                        color: Color.accentPurple  // UPDATED
                    ) {
                        showExpenseHistory = true
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(
                        icon: "arrow.clockwise.circle.fill",
                        title: "Recurring Expenses",
                        subtitle: "Manage monthly bills",
                        color: .green
                    ) {
                        showRecurringExpenses = true
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(
                        icon: "person.fill",
                        title: "Edit Profile",
                        subtitle: "Update your information",
                        color: .blue
                    ) {
                        // TODO: Navigate to edit profile
                        print("Edit profile tapped")
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(
                        icon: "dollarsign.circle.fill",
                        title: "Budget Preferences",
                        subtitle: "Adjust your budget settings",
                        color: .green
                    ) {
                        showBudgetPreferences = true  // CHANGED from print statement
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(
                        icon: "arrow.clockwise.circle.fill",
                        title: "Regenerate Budget",
                        subtitle: "Get a fresh AI budget",
                        color: Color.customAccentPurple
                    ) {
                        showRegenerateConfirmation = true
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        subtitle: "Manage alerts and reminders",
                        color: .orange
                    ) {
                        // TODO: Navigate to notifications
                        print("Notifications tapped")
                    }
                }
                .background(Color.cardBackground)  // UPDATED
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 24)
                
              
                // Privacy & Security
                VStack(spacing: 0) {
                    SettingsRow(
                        icon: "lock.fill",
                        title: "Privacy Policy",
                        subtitle: "View our privacy policy",
                        color: .purple
                    ) {
                        showPrivacyPolicy = true  // CHANGED from print statement
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        title: "Terms of Service",
                        subtitle: "Read our terms",
                        color: .purple
                    ) {
                        showTerms = true  // CHANGED from print statement
                    }
                }
                .background(Color.cardBackground)  // UPDATED
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 24)
                // App Info
                VStack(spacing: 16) {
                    HStack {
                        Text("App Version")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondaryText)  // UPDATED
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primaryText)  // UPDATED
                    }
                }
                .padding(20)
                .background(Color.cardBackground)  // UPDATED
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 24)
                
                // Danger Zone
                VStack(spacing: 12) {
                    Button(action: {
                        showSignOutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            
                            Text("Delete Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())  // UPDATED
        .sheet(isPresented: $showExpenseHistory) {
            ExpenseHistoryView(expenseManager: expenseManager, authManager: authManager)
        }
        .sheet(isPresented: $showRecurringExpenses) {
            RecurringExpensesView(expenseManager: expenseManager)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTerms) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showBudgetPreferences) {
            if let userData = authManager.userData,
               let savedBudget = authManager.savedBudget {
                BudgetPreferencesView(
                    authManager: authManager,
                    budget: BudgetItem(
                        monthlyFood: savedBudget.monthlyFood,
                        monthlyMiscellaneous: savedBudget.monthlyMiscellaneous,
                        monthlySavings: savedBudget.monthlySavings,
                        remainingMoney: savedBudget.remainingMoney,
                        savingsPercentage: savedBudget.savingsPercentage,
                        personalizedAdvice: savedBudget.personalizedAdvice,
                        breakdown: savedBudget.breakdown
                    )
                )
            }
        }
        .onAppear {
            expenseManager.loadExpenses()
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
        .alert("Regenerate Budget?", isPresented: $showRegenerateConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Regenerate") {
                // Trigger budget regeneration
                NotificationCenter.default.post(name: NSNotification.Name("RegenerateBudget"), object: nil)
            }
        } message: {
            Text("This will create a new AI-powered budget. Your current budget will be replaced.")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Delete user data from Firestore
        let db = Firestore.firestore()
        let userId = user.uid
        
        // Delete user document
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
            }
        }
        
        // Delete expenses
        db.collection("expenses").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            snapshot?.documents.forEach { doc in
                doc.reference.delete()
            }
        }
        
        // Delete Firebase Auth account
        user.delete { error in
            if let error = error {
                print("Error deleting account: \(error.localizedDescription)")
                // May need to re-authenticate
            } else {
                authManager.signOut()
            }
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)  // UPDATED
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondaryText)  // UPDATED
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondaryText.opacity(0.5))  // UPDATED
            }
            .padding(20)
        }
    }
}

#Preview {
    SettingsView(authManager: AuthenticationManager())
}
