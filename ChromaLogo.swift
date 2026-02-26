//
//  ChromaLogo.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/26/26.
//
import SwiftUI

struct ChromaLogo: View {
    let size: CGFloat
    let glowIntensity: Double
    
    init(size: CGFloat = 100, glowIntensity: Double = 0.3) {
        self.size = size
        self.glowIntensity = glowIntensity
    }
    
    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.03
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 2)
                .opacity(glowIntensity)
            
            // Inner circle background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.3),  .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
            
            // Chi symbol with gradient
            Text("Χ")
                .font(.system(size: size * 0.7, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(red: 0.9, green: 0.9, blue: 1.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .shadow(color: .white.opacity(glowIntensity * 0.5), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    ZStack {
        Color(red: 0.4, green: 0.3, blue: 0.8)
        ChromaLogo(size: 120, glowIntensity: 0.5)
    }
}
