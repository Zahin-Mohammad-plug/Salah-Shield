//
//  SalahShieldApp.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

@main
struct SalahShieldApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
