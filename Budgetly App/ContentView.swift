import SwiftUI
import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showOnboarding = false
    @State private var isCheckingData = true
    @State private var showWelcomeAnimation = false
    
    var body: some View {
        ZStack {
            if isCheckingData {
                LoadingView()
            } else if showWelcomeAnimation {
                WelcomeAnimationView(showAnimation: $showWelcomeAnimation)
                    .transition(.opacity)
            } else if authManager.userIsLoggedIn {
                if authManager.userData == nil {
                    OnboardingView(authManager: authManager, showOnboarding: $showOnboarding)
                } else {
                    DashboardView(authManager: authManager)
                }
            } else {
                WelcomeView(authManager: authManager, showOnboarding: $showOnboarding)
            }
        }
        .task {
            await handleUserLogin()
        }
        .onChange(of: authManager.userIsLoggedIn) { oldValue, newValue in
            if newValue && !oldValue {
                // User just logged in
                Task {
                    await handleUserLogin()
                }
            }
        }
    }
    
    func handleUserLogin() async {
        // Check if this is the first launch
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcomeAnimation")
        
        if authManager.userIsLoggedIn {
            // Load user data
            authManager.loadUserData()
            authManager.loadSavedBudget()
            
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                withAnimation {
                    isCheckingData = false
                }
                
                // Show welcome animation on first launch after sign in
                if !hasSeenWelcome && authManager.userData == nil {
                    withAnimation {
                        showWelcomeAnimation = true
                    }
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcomeAnimation")
                }
            }
        } else {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                withAnimation {
                    isCheckingData = false
                }
                
                // Show welcome animation on first launch for new users
                if !hasSeenWelcome {
                    withAnimation {
                        showWelcomeAnimation = true
                    }
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcomeAnimation")
                }
            }
        }
    }
}

struct WelcomeView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Binding var showOnboarding: Bool
    @State private var animateGradient = false
    @State private var isSigningIn = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.3, blue: 0.8),
                    Color(red: 0.3, green: 0.5, blue: 0.9),
                    Color(red: 0.5, green: 0.4, blue: 0.95)
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image("ChromaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Text("Chrema")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Wealth Made Simple")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        isSigningIn = true
                        authManager.signInWithGoogle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            isSigningIn = false
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if isSigningIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            
                            Text(isSigningIn ? "Signing in..." : "Continue with Google")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isSigningIn)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text("Continue with Apple")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.black.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        
                        Text("Coming soon")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
            
            if isSigningIn {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Signing you in...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .shadow(radius: 20)
                )
            }
        }
        .onChange(of: authManager.userIsLoggedIn) { oldValue, newValue in
            if newValue {
                isSigningIn = false
            }
        }
    }
}

#Preview {
    ContentView()
}
