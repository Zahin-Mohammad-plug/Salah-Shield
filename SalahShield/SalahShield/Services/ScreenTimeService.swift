//
//  ScreenTimeService.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import Foundation
import FamilyControls
import Combine
import ManagedSettings

/// Service to manage Screen Time API authorization and app blocking
@MainActor
class ScreenTimeService: ObservableObject {
    @Published var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    
    private let store = ManagedSettingsStore()
    
    init() {
        authorizationStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
    }
    
    /// Request authorization from the user to use the Screen Time API
    func requestAuthorization() {
        Task {
            do {
                try await FamilyControls.AuthorizationCenter.shared.requestAuthorization(for: .individual)
                authorizationStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
            } catch {
                print("Failed to request Screen Time authorization: \(error)")
            }
        }
    }
    
    /// Starts blocking the applications selected by the user
    func startBlocking(selection: FamilyActivitySelection) {
        // Prevent app removals
        store.shield.applicationCategories = .all()
        
        // Shield the selected apps
        store.shield.applications = selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens
    }
    
    /// Stops blocking all applications
    func stopBlocking() {
        store.shield.applications = []
        store.shield.webDomains = []
        store.shield.applicationCategories = nil
    }
}
