//
//  WelcomeAnimationView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/26/26.
//
import SwiftUI

struct WelcomeAnimationView: View {
    @Binding var showAnimation: Bool
    
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var logoRotation: Double = -180
    
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0
    
    @State private var taglineOffset: CGFloat = 50
    @State private var taglineOpacity: Double = 0
    
    @State private var featuresOpacity: Double = 0
    @State private var featuresOffset: CGFloat = 30
    
    @State private var buttonScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0
    
    @State private var particlesOpacity: Double = 0
    
    let features = [
        ("chart.line.uptrend.xyaxis", "AI-Powered Budgets", "Personalized recommendations"),
        ("bell.badge.fill", "Smart Alerts", "Stay on track effortlessly"),
        ("chart.pie.fill", "Beautiful Analytics", "Understand your spending")
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.3, blue: 0.8),
                    Color(red: 0.3, green: 0.5, blue: 0.9),
                    Color(red: 0.5, green: 0.4, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles
            ForEach(0..<15, id: \.self) { index in
                FloatingParticle(delay: Double(index) * 0.2)
                    .opacity(particlesOpacity)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo Animation (Custom Image)
                Image("ChromaLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .rotationEffect(.degrees(logoRotation))
                    .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // App name
                Text("Chrema")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                
                // Tagline
                Text("Wealth Made Simple")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .offset(y: taglineOffset)
                    .opacity(taglineOpacity)
                
                Spacer()
                
                // Features
                VStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeatureRow(icon: feature.0, title: feature.1, subtitle: feature.2)
                            .offset(y: featuresOffset)
                            .opacity(featuresOpacity)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: featuresOpacity)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showAnimation = false
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 40)
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    func startAnimationSequence() {
        // 1. Logo appears and rotates
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoRotation = 0
        }
        
        // 2. Particles fade in
        withAnimation(.easeIn(duration: 1.0).delay(0.3)) {
            particlesOpacity = 1.0
        }
        
        // 3. Title slides up
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            titleOffset = 0
            titleOpacity = 1.0
        }
        
        // 4. Tagline slides up
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
            taglineOffset = 0
            taglineOpacity = 1.0
        }
        
        // 5. Features fade in
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            featuresOffset = 0
            featuresOpacity = 1.0
        }
        
        // 6. Button appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.3)) {
            buttonScale = 1.0
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

// MARK: - Floating Particle
struct FloatingParticle: View {
    let delay: Double
    
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0
    
    let randomX = CGFloat.random(in: -150...150)
    let randomY = CGFloat.random(in: -300...300)
    let randomSize = CGFloat.random(in: 4...12)
    let randomDuration = Double.random(in: 3...6)
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: randomSize, height: randomSize)
            .offset(x: randomX + xOffset, y: randomY + yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: randomDuration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    yOffset = CGFloat.random(in: -50...50)
                    xOffset = CGFloat.random(in: -30...30)
                    opacity = Double.random(in: 0.2...0.6)
                }
            }
    }
}

#Preview {
    WelcomeAnimationView(showAnimation: .constant(true))
}
