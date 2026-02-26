import SwiftUI

extension Color {
    // MARK: - Backgrounds
    static var appBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.059, green: 0.059, blue: 0.078, alpha: 1.0) // #0F0F14
                : UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1.0) // #F2F2F7
        })
    }
    
    static var appCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.102, green: 0.102, blue: 0.141, alpha: 1.0) // #1A1A24
                : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFF
        })
    }
    
    // MARK: - Text
    static var appPrimaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White
                : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black
        })
    }
    
    static var appSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.627, green: 0.627, blue: 0.722, alpha: 1.0) // #A0A0B8
                : UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.0) // #808080
        })
    }
    
    // MARK: - Accents
    static var customAccentPurple: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.482, green: 0.408, blue: 0.933, alpha: 1.0) // #7B68EE
                : UIColor(red: 0.400, green: 0.314, blue: 0.800, alpha: 1.0) // #6650CC
        })
    }
    
    static var customAccentBlue: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.357, green: 0.561, blue: 1.0, alpha: 1.0) // #5B8FFF
                : UIColor(red: 0.302, green: 0.498, blue: 0.902, alpha: 1.0) // #4D7FE6
        })
    }
    
    // MARK: - Gradient
    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [customAccentPurple, customAccentBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Status Colors (same in both modes)
    static let successGreen = Color(red: 0.306, green: 0.8, blue: 0.639) // #4ECCA3
    static let warningAmber = Color(red: 1.0, green: 0.702, blue: 0.278) // #FFB347
    static let dangerRed = Color(red: 1.0, green: 0.42, blue: 0.42) // #FF6B6B
}
