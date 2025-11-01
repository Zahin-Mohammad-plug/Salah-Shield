//
//  AppState.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI
import Combine

/// Central app state manager
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    @Published var selectedCity: String?
    @Published var calculationMethod: CalculationMethod = .mwl
    @Published var notificationsEnabled: Bool = false
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    var currentStatus: AppStatus {
        if !hasCompletedOnboarding || locationPermissionStatus == .denied {
            return .needsSetup
        }
        if isPaused {
            return .paused
        }
        return isActive ? .active : .idle
    }
}

enum AppStatus {
    case active
    case idle
    case paused
    case needsSetup
    
    var title: String {
        switch self {
        case .active: return "Active"
        case .idle: return "Idle"
        case .paused: return "Paused"
        case .needsSetup: return "Setup Required"
        }
    }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .idle: return .gray
        case .paused: return .orange
        case .needsSetup: return .red
        }
    }
}

enum LocationPermissionStatus {
    case notDetermined
    case authorized
    case denied
}
