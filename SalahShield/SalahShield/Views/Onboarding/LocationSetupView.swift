//
//  LocationSetupView.swift
//  SalahShield
//
//  Created on November 1, 2025.
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
                                
                                Text("Automatically updates when traveling")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $useLocation)
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
                            
                            // Sample cities
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                CityRow(name: "New York, USA", isSelected: selectedCity == "New York") {
                                    selectedCity = "New York"
                                }
                                CityRow(name: "London, UK", isSelected: selectedCity == "London") {
                                    selectedCity = "London"
                                }
                                CityRow(name: "Dubai, UAE", isSelected: selectedCity == "Dubai") {
                                    selectedCity = "Dubai"
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
                    if useLocation {
                        // Request location permission
                        appState.locationPermissionStatus = .authorized
                    } else {
                        appState.selectedCity = selectedCity
                    }
                    onContinue()
                }
                .disabled(!useLocation && selectedCity.isEmpty)
                
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
