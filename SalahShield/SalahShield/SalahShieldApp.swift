//
//  SalahShieldApp.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

@main
struct SalahShieldApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
            } else {
                OnboardingCoordinator()
                    .environmentObject(appState)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }
}
