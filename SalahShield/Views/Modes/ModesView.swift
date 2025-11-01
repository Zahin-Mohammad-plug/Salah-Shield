//
//  ModesView.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Special modes for Jumu'ah and Ramadan
struct ModesView: View {
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
                    
                    // Jumu'ah Mode
                    ModeCard(
                        icon: "mosque.fill",
                        iconColor: .blue,
                        title: "Jumu'ah Mode",
                        description: "Extended Friday prayer window with enhanced blocking",
                        isEnabled: jumuahEnabled,
                        isPro: true,
                        details: [
                            "Extended prayer window (60 minutes)",
                            "Stricter app blocking",
                            "Special notification tone",
                            "Auto-activates on Fridays"
                        ],
                        onToggle: { enabled in
                            if enabled {
                                showPaywall = true
                            } else {
                                jumuahEnabled = false
                            }
                        }
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Ramadan Mode
                    ModeCard(
                        icon: "moon.stars.fill",
                        iconColor: .purple,
                        title: "Ramadan Mode",
                        description: "Enhanced focus during the blessed month",
                        isEnabled: ramadanEnabled,
                        isPro: true,
                        details: [
                            "Includes Taraweeh prayer times",
                            "Suhoor & Iftar reminders",
                            "Enhanced Qur'an reading time",
                            "Special night prayer windows"
                        ],
                        onToggle: { enabled in
                            if enabled {
                                showPaywall = true
                            } else {
                                ramadanEnabled = false
                            }
                        }
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Pro Banner
                    SSCard {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unlock Special Modes")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Upgrade to Pro for Jumu'ah and Ramadan presets")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .onTapGesture {
                        showPaywall = true
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
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isEnabled: Bool
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
