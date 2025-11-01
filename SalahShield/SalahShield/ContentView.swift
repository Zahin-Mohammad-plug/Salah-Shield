//
//  ContentView.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingCoordinator()
            }
        }
    }
}
