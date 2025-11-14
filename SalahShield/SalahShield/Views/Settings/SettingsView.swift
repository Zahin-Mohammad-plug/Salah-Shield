//
//  SettingsView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Settings and preferences screen
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showPaywall = false
    @State private var showCalculationMethodPicker = false
    
    var body: some View {
        NavigationView {
            List {
                // Location Section
                Section(header: Text("Location")) {
                    if let city = appState.selectedCity {
                        SSListRow(
                            title: "City",
                            subtitle: city,
                            icon: "mappin.circle.fill",
                            accessory: .chevron,
                            action: {
                                // Edit city
                            }
                        )
                    } else {
                        SSListRow(
                            title: "Use Current Location",
                            subtitle: appState.locationPermissionStatus.displayText,
                            icon: "location.fill",
                            accessory: .chevron,
                            action: {
                                appState.requestLocationAccess()
                            }
                        )
                    }
                    
                    // Show location error if any
                    if let locationError = appState.locationService.locationError {
                        SSListRow(
                            title: "Location Error",
                            subtitle: locationError,
                            icon: "exclamationmark.triangle.fill",
                            iconColor: .red
                        )
                    }
                    
                    SSListRow(
                        title: "Calculation Method",
                        subtitle: appState.calculationMethod.rawValue,
                        icon: "calendar.badge.clock",
                        accessory: .chevron,
                        action: {
                            showCalculationMethodPicker = true
                        }
                    )
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    SSListRow(
                        title: "Prayer Reminders",
                        icon: "bell.fill",
                        accessory: .toggle($appState.notificationsEnabled)
                    )
                    
                    SSListRow(
                        title: "Notification Sound",
                        subtitle: "Default",
                        icon: "speaker.wave.2.fill",
                        accessory: .chevron,
                        action: {
                            // Edit sound
                        }
                    )
                }
                
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $themeManager.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Account Section
                Section(header: Text("Account")) {
                    SSListRow(
                        title: appState.isPro ? "Salah Shield Pro" : "Upgrade to Pro",
                        subtitle: appState.isPro ? "Active" : "Unlock all features",
                        icon: "crown.fill",
                        iconColor: .yellow,
                        accessory: appState.isPro ? .none : .chevron,
                        action: {
                            if !appState.isPro {
                                showPaywall = true
                            }
                        }
                    )
                    
                    if !appState.isPro {
                        SSListRow(
                            title: "Restore Purchases",
                            icon: "arrow.clockwise",
                            accessory: .chevron,
                            action: {
                                // Restore purchases
                            }
                        )
                    }
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    SSListRow(
                        title: "Help & FAQ",
                        icon: "questionmark.circle.fill",
                        accessory: .chevron,
                        action: {
                            // Open help
                        }
                    )
                    
                    SSListRow(
                        title: "Contact Us",
                        icon: "envelope.fill",
                        accessory: .chevron,
                        action: {
                            // Contact support
                        }
                    )
                    
                    SSListRow(
                        title: "Rate Salah Shield",
                        icon: "star.fill",
                        iconColor: .yellow,
                        accessory: .chevron,
                        action: {
                            // Open App Store
                        }
                    )
                }
                
                // About Section
                Section(header: Text("About")) {
                    SSListRow(
                        title: "Version",
                        subtitle: "1.0.0 (Build 1)",
                        icon: "info.circle.fill"
                    )
                    
                    SSListRow(
                        title: "Privacy Policy",
                        icon: "hand.raised.fill",
                        accessory: .chevron,
                        action: {
                            // Open privacy policy
                        }
                    )
                    
                    SSListRow(
                        title: "Terms of Service",
                        icon: "doc.text.fill",
                        accessory: .chevron,
                        action: {
                            // Open terms
                        }
                    )
                }
                
                // Danger Zone
                Section {
                    Button(action: {
                        // Reset onboarding
                        appState.hasCompletedOnboarding = false
                    }) {
                        Text("Reset Onboarding")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCalculationMethodPicker) {
                CalculationMethodPickerView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Calculation Method Picker
struct CalculationMethodPickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach([CalculationMethod.mwl, .isna, .egypt, .makkah, .karachi, .tehran, .jafari], id: \.self) { method in
                    Button(action: {
                        // Mark that user manually changed the method
                        UserDefaults.standard.set(true, forKey: "hasSetDefaultMethod")
                        
                        appState.calculationMethod = method
                        
                        // Recalculate prayer times immediately with new method
                        if let location = appState.locationService.currentLocation {
                            appState.prayerTimeService.calculatePrayerTimes(for: location, method: method)
                        }
                        
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(methodDisplayName(method))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text(methodDescription(method))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if appState.calculationMethod == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Calculation Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func methodDisplayName(_ method: CalculationMethod) -> String {
        switch method {
        case .mwl: return "Muslim World League"
        case .isna: return "ISNA (North America)"
        case .egypt: return "Egyptian General Authority"
        case .makkah: return "Umm Al-Qura (Makkah)"
        case .karachi: return "University of Karachi"
        case .tehran: return "Institute of Geophysics, Tehran"
        case .jafari: return "Jafari (Shia Ithna Ashari)"
        }
    }
    
    private func methodDescription(_ method: CalculationMethod) -> String {
        switch method {
        case .mwl: return "Used in Europe, parts of Americas"
        case .isna: return "Recommended for USA & Canada"
        case .egypt: return "Used in Egypt and nearby regions"
        case .makkah: return "Used in Saudi Arabia"
        case .karachi: return "Used in Pakistan, Bangladesh, India"
        case .tehran: return "Used in Iran"
        case .jafari: return "Shia Ithna Ashari jurisprudence"
        }
    }
}

