//
//  WelcomeView.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Welcome screen - first step of onboarding
struct WelcomeView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon/Logo
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, DesignSystem.Spacing.xl)
            
            // Title
            Text("Salah Shield")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            // Subtitle
            Text("Stay present during prayer")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .padding(.top, DesignSystem.Spacing.sm)
            
            Spacer()
            
            // Features
            VStack(spacing: DesignSystem.Spacing.lg) {
                FeatureRow(
                    icon: "bell.fill",
                    title: "Prayer Notifications",
                    description: "Get notified before each prayer time"
                )
                
                FeatureRow(
                    icon: "app.badge.fill",
                    title: "Smart Blocking",
                    description: "Reduce distractions during prayer windows"
                )
                
                FeatureRow(
                    icon: "calendar",
                    title: "Customizable Schedule",
                    description: "Adjust prayer windows to fit your routine"
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            
            Spacer()
            
            // Continue Button
            VStack(spacing: DesignSystem.Spacing.md) {
                SSButton("Get Started", style: .primary, size: .large) {
                    onContinue()
                }
                
                Text("By continuing, you agree to our Terms & Privacy Policy")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(DesignSystem.Colors.background)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
