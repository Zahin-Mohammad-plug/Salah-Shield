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
    @State private var showLocationPicker = false
    @State private var showCalculationMethodPicker = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // Location Section
                Section(header: Text("Location")) {
                    if let city = appState.selectedCity {
                        SSListRow(
                            title: "Current City",
                            subtitle: city,
                            icon: "mappin.circle.fill",
                            accessory: .chevron,
                            action: {
                                showLocationPicker = true
                            }
                        )
                    } else {
                        SSListRow(
                            title: "Set Location",
                            subtitle: "Required for prayer times",
                            icon: "location.fill",
                            iconColor: .red,
                            accessory: .chevron,
                            action: {
                                showLocationPicker = true
                            }
                        )
                    }
                    
                    // Location permission status
                    SSListRow(
                        title: "Location Access",
                        subtitle: appState.locationPermissionStatus.displayText,
                        icon: "location.circle.fill",
                        iconColor: locationStatusColor,
                        accessory: appState.locationPermissionStatus == .denied ? .chevron : .none,
                        action: {
                            if appState.locationPermissionStatus == .denied {
                                appState.requestLocationAccess()
                            }
                        }
                    )
                    
                    // Show location error if any
                    if let locationError = appState.locationService.locationError {
                        SSListRow(
                            title: "Location Error",
                            subtitle: locationError,
                            icon: "exclamationmark.triangle.fill",
                            iconColor: .red
                        )
                    }
                }
                
                // Prayer Settings Section
                Section(header: Text("Prayer Settings")) {
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
                            // TODO: Edit sound
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
                
                // Support Section
                Section(header: Text("Support")) {
                    SSListRow(
                        title: "Help & FAQ",
                        icon: "questionmark.circle.fill",
                        accessory: .chevron,
                        action: {
                            // TODO: Open help
                        }
                    )
                    
                    SSListRow(
                        title: "Contact Us",
                        icon: "envelope.fill",
                        accessory: .chevron,
                        action: {
                            // TODO: Contact support
                        }
                    )
                    
                    SSListRow(
                        title: "Rate Salah Shield",
                        icon: "star.fill",
                        iconColor: .yellow,
                        accessory: .chevron,
                        action: {
                            // TODO: Open App Store
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
                            // TODO: Open privacy policy
                        }
                    )
                    
                    SSListRow(
                        title: "Terms of Service",
                        icon: "doc.text.fill",
                        accessory: .chevron,
                        action: {
                            // TODO: Open terms
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
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerSheet(isPresented: $showLocationPicker)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showCalculationMethodPicker) {
                CalculationMethodPickerSheet(isPresented: $showCalculationMethodPicker)
                    .environmentObject(appState)
            }
        }
    }
    
    private var locationStatusColor: Color {
        switch appState.locationPermissionStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        }
    }
}

// MARK: - Location Picker Sheet
struct LocationPickerSheet: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var useLocation: Bool = true
    @State private var selectedCity: String = ""
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Use Current Location Toggle
                SSCard {
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
                                Text("Automatically detect location")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $useLocation)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Manual City Selection
                if (!useLocation) {
                    SSCard {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Select City")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            TextField("Search for your city", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            ScrollView {
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
                                    CityRow(name: "Makkah, Saudi Arabia", isSelected: selectedCity == "Makkah") {
                                        selectedCity = "Makkah"
                                        appState.setManualCity("Makkah, Saudi Arabia", latitude: 21.4225, longitude: 39.8262)
                                    }
                                    CityRow(name: "Madinah, Saudi Arabia", isSelected: selectedCity == "Madinah") {
                                        selectedCity = "Madinah"
                                        appState.setManualCity("Madinah, Saudi Arabia", latitude: 24.5247, longitude: 39.5692)
                                    }
                                    CityRow(name: "Istanbul, Turkey", isSelected: selectedCity == "Istanbul") {
                                        selectedCity = "Istanbul"
                                        appState.setManualCity("Istanbul, Turkey", latitude: 41.0082, longitude: 28.9784)
                                    }
                                    CityRow(name: "Cairo, Egypt", isSelected: selectedCity == "Cairo") {
                                        selectedCity = "Cairo"
                                        appState.setManualCity("Cairo, Egypt", latitude: 30.0444, longitude: 31.2357)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                Spacer()
            }
            .padding(.top, DesignSystem.Spacing.lg)
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if useLocation {
                            appState.requestLocationAccess()
                        }
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: useLocation) { newValue in
                if newValue {
                    appState.requestLocationAccess()
                }
            }
        }
    }
}

// MARK: - Calculation Method Picker Sheet
struct CalculationMethodPickerSheet: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(CalculationMethod.allCases, id: \.self) { method in
                    Button(action: {
                        appState.calculationMethod = method
                        isPresented = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(method.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text(method.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if appState.calculationMethod == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Calculation Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
