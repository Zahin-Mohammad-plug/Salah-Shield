//
//  CalculationMethodView.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Calculation method selection - third step of onboarding
struct CalculationMethodView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMethod: CalculationMethod = .mwl
    
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Spacer()
                    Text("2 of 3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("Calculation Method")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Choose the method used to calculate prayer times in your region")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.xxl)
            
            // Methods List
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(CalculationMethod.allCases, id: \.self) { method in
                        MethodCard(
                            method: method,
                            isSelected: selectedMethod == method,
                            action: {
                                selectedMethod = method
                            }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            
            // Buttons
            VStack(spacing: DesignSystem.Spacing.md) {
                SSButton("Continue", style: .primary, size: .large) {
                    appState.calculationMethod = selectedMethod
                    onContinue()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(DesignSystem.Colors.background)
    }
}

struct MethodCard: View {
    let method: CalculationMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(method.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary.opacity(0.3))
                    }
                }
                
                Text(method.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                isSelected ?
                    Color.accentColor.opacity(0.1) :
                    DesignSystem.Colors.secondaryBackground
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
