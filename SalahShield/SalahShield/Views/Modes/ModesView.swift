//
//  ModesView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Special modes for Jumu'ah and Ramadan
struct ModesView: View {
    @EnvironmentObject var appState: AppState
    @State private var jumuahEnabled = false
    @State private var ramadanEnabled = false
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Special Modes")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Preset configurations for special occasions")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Jumu'ah Mode Card
                    ModeCard(
                        icon: "mosque.fill",
                        iconColor: .green,
                        title: "Jumu'ah Mode",
                        description: "Extended Friday prayer support",
                        isEnabled: $jumuahEnabled,
                        isPro: true,
                        details: [
                            "Extended Dhuhr window on Fridays",
                            "Auto-activation for Jumu'ah prayers",
                            "Enhanced blocking during Khutbah time",
                            "30-minute post-prayer extension"
                        ],
                        onToggle: { newValue in
                            if !appState.isPro {
                                showPaywall = true
                                jumuahEnabled = false
                            } else {
                                jumuahEnabled = newValue
                            }
                        }
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Ramadan Mode Card
                    ModeCard(
                        icon: "moon.stars.fill",
                        iconColor: .indigo,
                        title: "Ramadan Mode",
                        description: "Special features for the blessed month",
                        isEnabled: $ramadanEnabled,
                        isPro: true,
                        details: [
                            "Taraweeh prayer tracking",
                            "Suhoor and Iftar reminders",
                            "Enhanced blocking during fasting hours",
                            "Daily reflection prompts"
                        ],
                        onToggle: { newValue in
                            if !appState.isPro {
                                showPaywall = true
                                ramadanEnabled = false
                            } else {
                                ramadanEnabled = newValue
                            }
                        }
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Pro Banner
                    if !appState.isPro {
                        SSBanner(
                            message: "Unlock special modes with Salah Shield Pro",
                            type: .info,
                            action: {
                                showPaywall = true
                            }
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Modes")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct ModeCard: View {
    @EnvironmentObject var appState: AppState
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let isPro: Bool
    let details: [String]
    let onToggle: (Bool) -> Void
    
    var body: some View {
        SSCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(iconColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Text(title)
                                .font(.system(size: 20, weight: .semibold))
                            
                            if isPro {
                                Text("PRO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { isEnabled },
                        set: { onToggle($0) }
                    ))
                    .disabled(isPro && !appState.isPro)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    ForEach(details, id: \.self) { detail in
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(iconColor)
                            
                            Text(detail)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}
