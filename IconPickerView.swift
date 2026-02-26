//
//  IconPickerView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/24/26.
//
import SwiftUI

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String
    @State private var searchText = ""
    
    let popularIcons = CustomBudgetCategory.popularIcons
    
    let allIcons = [
        // Food & Drink
        "cup.and.saucer.fill", "fork.knife", "wineglass.fill", "birthday.cake.fill",
        "takeoutbag.and.cup.and.straw.fill", "fish.fill", "carrot.fill",
        
        // Activities & Hobbies
        "gamecontroller.fill", "paintbrush.fill", "music.note", "book.fill",
        "camera.fill", "film.fill", "guitar", "basketball.fill", "figure.run",
        
        // Shopping & Services
        "cart.fill", "bag.fill", "giftcard.fill", "gift.fill", "creditcard.fill",
        
        // Health & Fitness
        "dumbbell.fill", "figure.yoga", "heart.fill", "cross.case.fill",
        "pills.fill", "stethoscope",
        
        // Education & Work
        "graduationcap.fill", "pencil", "briefcase.fill", "laptopcomputer",
        
        // Transportation
        "car.fill", "bus.fill", "bicycle", "airplane", "fuelpump.fill",
        "parkingsign.circle.fill",
        
        // Home & Living
        "house.fill", "lightbulb.fill", "bed.double.fill", "sofa.fill",
        "washer.fill", "shower.fill", "toilet.fill",
        
        // Entertainment
        "tv.fill", "sportscourt.fill", "theatermasks.fill", "ticket.fill",
        
        // Pets & Animals
        "pawprint.fill", "hare.fill", "tortoise.fill", "bird.fill",
        
        // Travel
        "suitcase.fill", "map.fill", "tent.fill", "beach.umbrella.fill",
        
        // Technology
        "desktopcomputer", "iphone", "headphones", "applewatch",
        
        // Miscellaneous
        "leaf.fill", "flame.fill", "snowflake", "sun.max.fill", "moon.fill",
        "star.fill", "heart.fill", "sparkles", "gift.fill", "flag.fill"
    ]
    
    var filteredIcons: [String] {
        if searchText.isEmpty {
            return allIcons
        }
        return allIcons.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.appSecondaryText)
                        
                        TextField("Search icons", text: $searchText)
                            .font(.system(size: 16))
                            .foregroundColor(.appPrimaryText)
                    }
                    .padding(12)
                    .background(Color.appCardBackground)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Popular Icons
                            if searchText.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Popular")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.appPrimaryText)
                                        .padding(.horizontal, 16)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 16) {
                                        ForEach(popularIcons, id: \.self) { icon in
                                            IconButton(
                                                icon: icon,
                                                isSelected: selectedIcon == icon
                                            ) {
                                                selectedIcon = icon
                                                dismiss()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            // All Icons
                            VStack(alignment: .leading, spacing: 12) {
                                if !searchText.isEmpty {
                                    Text("Results (\(filteredIcons.count))")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.appPrimaryText)
                                        .padding(.horizontal, 16)
                                } else {
                                    Text("All Icons")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.appPrimaryText)
                                        .padding(.horizontal, 16)
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ForEach(filteredIcons, id: \.self) { icon in
                                        IconButton(
                                            icon: icon,
                                            isSelected: selectedIcon == icon
                                        ) {
                                            selectedIcon = icon
                                            dismiss()
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.customAccentPurple)
                }
            }
        }
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .customAccentPurple)
                .frame(width: 60, height: 60)
                .background {
                    if isSelected {
                        Color.appGradient
                    } else {
                        Color.appCardBackground
                    }
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color.customAccentPurple.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("star.fill"))
}
