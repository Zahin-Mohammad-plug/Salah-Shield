//
//  ContentView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
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
