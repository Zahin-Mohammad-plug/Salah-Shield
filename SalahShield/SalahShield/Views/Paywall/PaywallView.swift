//
//  PaywallView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

// MARK: - FUTURE PREMIUM FEATURE
// TODO: This entire paywall system will be implemented after core functionality is complete
// Premium features planned:
// - Unlimited blocklists (vs 1 free)
// - Per-prayer custom buffers
// - Ramadan mode with Taraweeh
// - Jumu'ah mode with auto-activation
// - Travel mode with auto prayer time updates
// - Priority support

/// Paywall screen for Pro upgrade (FUTURE IMPLEMENTATION)
struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPlan: SubscriptionPlan = .annual
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, DesignSystem.Spacing.xxl)
                        
                        Text("Unlock Salah Shield Pro")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Enhance your prayer experience with premium features")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Features
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        ProFeatureRow(
                            icon: "shield.fill",
                            iconColor: .blue,
                            title: "Unlimited Blocklists",
                            description: "Create as many custom blocklists as you need"
                        )
                        
                        ProFeatureRow(
                            icon: "slider.horizontal.3",
                            iconColor: .purple,
                            title: "Per-Prayer Buffers",
                            description: "Customize prayer windows for each salah individually"
                        )
                        
                        ProFeatureRow(
                            icon: "moon.stars.fill",
                            iconColor: .indigo,
                            title: "Ramadan Mode",
                            description: "Special features for the blessed month including Taraweeh"
                        )
                        
                        ProFeatureRow(
                            icon: "mosque.fill",
                            iconColor: .green,
                            title: "Jumu'ah Mode",
                            description: "Extended Friday prayer support with auto-activation"
                        )
                        
                        ProFeatureRow(
                            icon: "location.fill",
                            iconColor: .red,
                            title: "Travel Mode",
                            description: "Automatic prayer time updates when traveling"
                        )
                        
                        ProFeatureRow(
                            icon: "sparkles",
                            iconColor: .orange,
                            title: "Premium Support",
                            description: "Priority customer support and feature requests"
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Plans
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Choose Your Plan")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PlanCard(
                            plan: .monthly,
                            isSelected: selectedPlan == .monthly,
                            onSelect: {
                                selectedPlan = .monthly
                            }
                        )
                        
                        PlanCard(
                            plan: .annual,
                            isSelected: selectedPlan == .annual,
                            onSelect: {
                                selectedPlan = .annual
                            }
                        )
                        
                        PlanCard(
                            plan: .lifetime,
                            isSelected: selectedPlan == .lifetime,
                            onSelect: {
                                selectedPlan = .lifetime
                            }
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Subscribe Button
                    VStack(spacing: DesignSystem.Spacing.md) {
                        SSButton("Continue with \(selectedPlan.displayName)", style: .primary, size: .large) {
                            // Handle subscription
                        }
                        
                        HStack(spacing: 4) {
                            Button("Restore Purchases") {
                                // Restore purchases
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Button("Terms") {
                                // Show terms
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Button("Privacy") {
                                // Show privacy
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .background(DesignSystem.Colors.background)
            
            // Close Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
                    .padding(DesignSystem.Spacing.md)
            }
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text(plan.displayName)
                            .font(.system(size: 18, weight: .semibold))
                        
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(plan.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let perMonth = plan.pricePerMonth {
                        Text(perMonth)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .accentColor : .secondary.opacity(0.3))
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

enum SubscriptionPlan {
    case monthly
    case annual
    case lifetime
    
    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        case .lifetime: return "Lifetime"
        }
    }
    
    var price: String {
        switch self {
        case .monthly: return "$4.99"
        case .annual: return "$39.99"
        case .lifetime: return "$99.99"
        }
    }
    
    var pricePerMonth: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "$3.33/month"
        case .lifetime: return "One-time payment"
        }
    }
    
    var description: String {
        switch self {
        case .monthly: return "Billed monthly"
        case .annual: return "Save 33%"
        case .lifetime: return "Pay once, use forever"
        }
    }
    
    var badge: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "POPULAR"
        case .lifetime: return "BEST VALUE"
        }
    }
}
