//
//  LoadingView.swift
//  Chrema
//
//  Created by Oluwanifemi Oloyede on 2/22/26.
//
import SwiftUI

struct LoadingView: View {
    @State private var animateGradient = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background - Properly animated
            LinearGradient(
                colors: [
                    Color.customAccentPurple,
                    Color.customAccentBlue,
                    Color.customAccentPurple.opacity(0.8)
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
            
            VStack(spacing: 24) {
                // Logo with rotating ring
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Chrema Logo (Custom Image)
                    Image("ChromaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
                
                // App name
                Text("Chrema")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Loading your financial data...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    LoadingView()
}
