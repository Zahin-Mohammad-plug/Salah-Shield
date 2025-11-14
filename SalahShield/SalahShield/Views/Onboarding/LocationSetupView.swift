//
//  LocationSetupView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Location setup screen - second step of onboarding
struct LocationSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCity: String = ""
    @State private var searchText: String = ""
    @State private var useLocation: Bool = true
    
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Spacer()
                    Text("1 of 3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("Location")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("We need your location to calculate accurate prayer times")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.xxl)
            
            Spacer()
            
            // Location Options
            VStack(spacing: DesignSystem.Spacing.lg) {
                SSCard {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Use Current Location")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                if let city = appState.selectedCity, appState.locationPermissionStatus == .authorized {
                                    Text(city)
                                        .font(.system(size: 14))
                                        .foregroundColor(.accentColor)
                                } else {
                                    Text("Automatically updates when traveling")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $useLocation)
                        }
                        
                        // Show location status
                        if useLocation && appState.locationPermissionStatus == .denied {
                            SSBanner(
                                message: "Location access denied. Please enable in Settings.",
                                type: .error,
                                action: {
                                    appState.requestLocationAccess()
                                }
                            )
                        }
                    }
                }
                
                if !useLocation {
                    SSCard {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Select City")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            TextField("Search for your city", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            // Sample cities (TODO: Replace with actual city search)
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                CityRow(name: "New York, USA", isSelected: selectedCity == "New York") {
                                    selectedCity = "New York"
                                    appState.setManualCity("New York, USA", latitude: 40.7128, longitude: -74.0060)
                                }
                                CityRow(name: "London, UK", isSelected: selectedCity == "London") {
                                    selectedCity = "London"
                                    appState.setManualCity("London, UK", latitude: 51.5074, longitude: -0.1278)
                                }
                                CityRow(name: "Dubai, UAE", isSelected: selectedCity == "Dubai") {
                                    selectedCity = "Dubai"
                                    appState.setManualCity("Dubai, UAE", latitude: 25.2048, longitude: 55.2708)
                                }
                                CityRow(name: "Toronto, Canada", isSelected: selectedCity == "Toronto") {
                                    selectedCity = "Toronto"
                                    appState.setManualCity("Toronto, Canada", latitude: 43.6532, longitude: -79.3832)
                                }
                                CityRow(name: "Ottawa, Canada", isSelected: selectedCity == "Ottawa") {
                                    selectedCity = "Ottawa"
                                    appState.setManualCity("Ottawa, Canada", latitude: 45.4215, longitude: -75.6972)
                                }
                                CityRow(name: "Makkah, Saudi Arabia", isSelected: selectedCity == "Makkah") {
                                    selectedCity = "Makkah"
                                    appState.setManualCity("Makkah, Saudi Arabia", latitude: 21.4225, longitude: 39.8262)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            
            Spacer()
            
            // Buttons
            VStack(spacing: DesignSystem.Spacing.md) {
                SSButton("Continue", style: .primary, size: .large) {
                    handleContinue()
                }
                .disabled(!canContinue)
                
                Button("Skip for now") {
                    onContinue()
                }
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(DesignSystem.Colors.background)
        .onAppear {
            // Request location permission immediately when view appears if using location
            if useLocation && appState.locationPermissionStatus == .notDetermined {
                appState.requestLocationAccess()
            }
        }
        .onChange(of: useLocation) { newValue in
            if newValue {
                // Request location permission when toggled on
                appState.requestLocationAccess()
            }
        }
    }
    
    private var canContinue: Bool {
        if useLocation {
            return appState.locationPermissionStatus == .authorized
        } else {
            return !selectedCity.isEmpty
        }
    }
    
    private func handleContinue() {
        if useLocation {
            // Already handled by AppState binding
            onContinue()
        } else {
            // Manual city already set via CityRow action
            onContinue()
        }
    }
}

struct CityRow: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
