//
//  PrivacyPolicyView.swift
//  Budgetly App
//
//  Created by Oluwanifemi Oloyede on 2/23/26.
//
import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let policyText = loadPrivacyPolicy() {
                        Text(policyText)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black)
                            .padding(24)
                    } else {
                        Text("Privacy Policy could not be loaded.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }
        }
    }
    
    func loadPrivacyPolicy() -> String? {
        guard let path = Bundle.main.path(forResource: "privacy-policy", ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            return nil
        }
        return content
    }
}

#Preview {
    PrivacyPolicyView()
}
