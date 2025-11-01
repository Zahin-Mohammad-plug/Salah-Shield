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
    // @State private var showPaywall = false // FUTURE: Premium feature paywall
    @State private var showAbout = false
    
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
                            // Edit method
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
                
                // MARK: - Future Premium Features
                // TODO: Implement after core functionality is complete
                // Account Section
                // Section(header: Text("Account")) {
                //     SSListRow(
                //         title: "Upgrade to Pro",
                //         subtitle: "Unlock all features",
                //         icon: "crown.fill",
                //         iconColor: .yellow,
                //         accessory: .chevron,
                //         action: { showPaywall = true }
                //     )
                //     
                //     SSListRow(
                //         title: "Restore Purchases",
                //         icon: "arrow.clockwise",
                //         action: { /* Restore purchases */ }
                //     )
                // }
                
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
            // FUTURE: Premium feature paywall
            // .sheet(isPresented: $showPaywall) {
            //     PaywallView()
            // }
        }
    }
    

}
