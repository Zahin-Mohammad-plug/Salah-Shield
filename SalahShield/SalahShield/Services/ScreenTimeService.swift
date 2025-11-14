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
import SwiftUI

/// Service to manage Screen Time API authorization and app blocking
@MainActor
class ScreenTimeService: ObservableObject {
    @Published var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    @Published var selection: FamilyActivitySelection?
    
    private let store = ManagedSettingsStore()
    private let selectionKey = "SavedFamilyActivitySelection"
    
    nonisolated init() {
        // Initialize properties asynchronously on main actor
        // This is safe because @Published properties initialize before any access
        Task { @MainActor [self] in
            self.authorizationStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
            self.loadSelection()
        }
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
    
    /// Save the FamilyActivitySelection
    /// Note: FamilyActivitySelection tokens cannot be serialized, so we keep them in memory
    /// If the app is killed, user will need to reselect apps (this is a Screen Time API limitation)
    func saveSelection(_ selection: FamilyActivitySelection) {
        self.selection = selection
        
        // Save metadata (counts) for display purposes only
        // The actual tokens must remain in memory
        let metadata: [String: Int] = [
            "applicationCount": selection.applicationTokens.count,
            "webDomainCount": selection.webDomainTokens.count,
            "categoryCount": selection.categoryTokens.count
        ]
        UserDefaults.standard.set(metadata, forKey: selectionKey)
    }
    
    /// Load saved selection metadata (for display only - tokens are lost on app restart)
    @MainActor
    private func loadSelection() {
        // Note: We can't actually restore the tokens, but we can check if a selection was made
        _ = UserDefaults.standard.dictionary(forKey: selectionKey)
        // The actual selection tokens are lost - user will need to reselect if app restarts
    }
    
    /// Starts blocking the applications selected by the user
    func startBlocking(selection: FamilyActivitySelection) {
        saveSelection(selection)
        
        // Prevent app removals
        store.shield.applicationCategories = .all()
        
        // Shield the selected apps
        store.shield.applications = selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens
    }
    
    /// Starts blocking using saved selection
    func startBlocking() {
        guard let selection = selection else { return }
        startBlocking(selection: selection)
    }
    
    /// Stops blocking all applications
    func stopBlocking() {
        store.shield.applications = []
        store.shield.webDomains = []
        store.shield.applicationCategories = nil
    }
}

