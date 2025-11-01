//
//  OnboardingCoordinator.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Coordinates the onboarding flow
struct OnboardingCoordinator: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: OnboardingStep = .welcome
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView(onContinue: {
                    withAnimation {
                        currentStep = .location
                    }
                })
            case .location:
                LocationSetupView(onContinue: {
                    withAnimation {
                        currentStep = .calculation
                    }
                })
            case .calculation:
                CalculationMethodView(onContinue: {
                    withAnimation {
                        currentStep = .blocklist
                    }
                })
            case .blocklist:
                OnboardingBlocklistView(onComplete: {
                    appState.completeOnboarding()
                })
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}

enum OnboardingStep {
    case welcome
    case location
    case calculation
    case blocklist
}
