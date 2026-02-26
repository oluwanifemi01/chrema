//
//  AnimationHelpers.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/24/26.
//
import SwiftUI
import Combine

// MARK: - Animation State Manager
class AnimationStateManager: ObservableObject {
    static let shared = AnimationStateManager()
    
    @Published var hasPlayedHomeAnimation = false
    @Published var hasPlayedTrackerAnimation = false
    @Published var hasPlayedAnalyticsAnimation = false
    
    private init() {}
    
    func reset() {
        hasPlayedHomeAnimation = false
        hasPlayedTrackerAnimation = false
        hasPlayedAnalyticsAnimation = false
    }
}

// MARK: - Number Counter Animation (Fixed - No Glitches)
struct AnimatedNumber: View {
    let value: Double
    let format: NumberFormat
    @State private var displayValue: Double = 0
    
    enum NumberFormat {
        case currency       // $1,234
        case percentage     // 56%
        case plain          // 1234
        
        func formatted(_ value: Double) -> String {
            switch self {
            case .currency:
                return "$\(Int(value).formatted())"
            case .percentage:
                return "\(Int(value))%"
            case .plain:
                return "\(Int(value))"
            }
        }
    }
    
    var body: some View {
        Text(format.formatted(displayValue))
            .onAppear {
                // Animate from 0 to value on first appear
                withAnimation(.easeOut(duration: 1.5)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { oldValue, newValue in
                // Smooth transition when value changes
                withAnimation(.easeInOut(duration: 0.5)) {
                    displayValue = newValue
                }
            }
    }
}

// MARK: - Card Entrance Animation (Play Once)
struct CardAppearModifier: ViewModifier {
    @State private var appeared = false
    let delay: Double
    let shouldAnimate: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1.0 : (shouldAnimate ? 0.9 : 1.0))
            .opacity(appeared ? 1.0 : (shouldAnimate ? 0 : 1.0))
            .onAppear {
                if shouldAnimate && !appeared {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                        appeared = true
                    }
                } else {
                    appeared = true
                }
            }
    }
}

extension View {
    func cardAppear(delay: Double = 0, shouldAnimate: Bool = true) -> some View {
        modifier(CardAppearModifier(delay: delay, shouldAnimate: shouldAnimate))
    }
}

// MARK: - Button Press Animation
struct ButtonPressModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

extension View {
    func pressAnimation() -> some View {
        modifier(ButtonPressModifier())
    }
}

// MARK: - Shimmer Effect (Loading) - Improved Visibility
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let isAnimating: Bool
    
    init(isAnimating: Bool = true) {
        self.isAnimating = isAnimating
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.6),  // More visible
                            .white.opacity(0.8),  // Peak brightness
                            .white.opacity(0.6),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                    .blendMode(.overlay)
                }
                .allowsHitTesting(false)
            )
            .onAppear {
                guard isAnimating else { return }
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer(isAnimating: Bool = true) -> some View {
        modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

// MARK: - Progress Bar Animation
struct AnimatedProgressBar: View {
    let value: Double
    let total: Double
    let color: Color
    @State private var animatedValue: Double = 0
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return min((value / total), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: geometry.size.width * animatedValue, height: 10)
            }
        }
        .frame(height: 10)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedValue = percentage
            }
        }
        .onChange(of: value) { oldValue, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedValue = percentage
            }
        }
    }
}

// MARK: - Success Checkmark Animation
struct SuccessCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.successGreen)
                .frame(width: 80, height: 80)
                .scaleEffect(scale)
            
            Path { path in
                path.move(to: CGPoint(x: 25, y: 40))
                path.addLine(to: CGPoint(x: 35, y: 50))
                path.addLine(to: CGPoint(x: 55, y: 30))
            }
            .trim(from: 0, to: trimEnd)
            .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                trimEnd = 1.0
            }
        }
    }
}
