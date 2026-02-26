import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            TabBarButton(
                icon: "chart.bar.doc.horizontal.fill",
                title: "Tracker",
                isSelected: selectedTab == 1
            ) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
            
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                title: "Analytics",
                isSelected: selectedTab == 2
            ) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }
            
            TabBarButton(
                icon: "slider.horizontal.3",
                title: "Settings",
                isSelected: selectedTab == 3
            ) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 3
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.cardBackground  // UPDATED
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
        .frame(maxWidth: .infinity)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? Color.accentPurple : .secondaryText)  // UPDATED
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.accentPurple : .secondaryText)  // UPDATED
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    BottomTabBar(selectedTab: .constant(0))
}
