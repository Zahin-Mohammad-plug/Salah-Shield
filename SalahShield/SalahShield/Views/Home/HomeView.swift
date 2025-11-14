//
//  HomeView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Home screen showing next prayer and today's schedule
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaywall = false
    
    // Real prayer times from service
    private var todaysPrayers: [Prayer] {
        appState.prayerTimeService.todaysPrayers
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Location/Time Banner
                    if appState.locationPermissionStatus == .denied {
                        SSBanner(
                            message: "Location access required for accurate prayer times",
                            type: .warning,
                            action: {
                                appState.requestLocationAccess()
                            }
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    } else if appState.locationPermissionStatus == .notDetermined {
                        SSBanner(
                            message: "Enable location for automatic prayer times",
                            type: .info,
                            action: {
                                appState.requestLocationAccess()
                            }
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Loading banner when calculating prayer times
                    if appState.prayerTimeService.isCalculating {
                        SSBanner(
                            message: "Calculating prayer times...",
                            type: .info,
                            action: nil
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Error banner if calculation failed
                    if let error = appState.prayerTimeService.calculationError {
                        SSBanner(
                            message: error,
                            type: .warning,
                            action: {
                                // Retry calculation
                                if let location = appState.locationService.currentLocation {
                                    appState.prayerTimeService.calculatePrayerTimes(for: location, method: appState.calculationMethod)
                                }
                            }
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Status & Quick Actions
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack {
                            SSStatusChip(status: appState.currentStatus)
                            Spacer()
                            
                            // Quick action buttons
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                QuickActionButton(
                                    icon: appState.isPaused ? "play.fill" : "pause.fill",
                                    action: {
                                        appState.isPaused.toggle()
                                    }
                                )
                                
                                QuickActionButton(
                                    icon: "list.bullet",
                                    action: {
                                        // Navigate to schedule
                                    }
                                )
                            }
                        }
                        
                        // Enable/Disable Blocking Toggle
                        SSCard(padding: DesignSystem.Spacing.md) {
                            HStack {
                                Image(systemName: "shield.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("App Blocking")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text(appState.isActive ? "Active during prayer windows" : "Tap to enable blocking")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $appState.isActive)
                            }
                        }
                        
                        // Screen Time Authorization Banner
                        if appState.screenTimeService.authorizationStatus != .approved {
                            SSBanner(
                                message: "Screen Time authorization required for app blocking",
                                type: .warning,
                                action: {
                                    Task {
                                        appState.screenTimeService.requestAuthorization()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Qibla Direction Card
                    if let qiblaAngle = appState.qiblaService.qiblaAngle {
                        QiblaCompassCard(
                            angle: qiblaAngle,
                            direction: appState.qiblaService.formattedDirection,
                            heading: appState.qiblaService.heading
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    } else if appState.locationService.currentLocation != nil {
                        // Show loading state if location exists but qibla not calculated yet
                        SSCard(padding: DesignSystem.Spacing.lg) {
                            HStack {
                                ProgressView()
                                Text("Calculating Qibla...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Next Prayer Card
                    if let nextPrayer = nextPrayer {
                        NextPrayerCard(prayer: nextPrayer)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Today's Prayers
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Today's Prayers")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(todaysPrayers) { prayer in
                                PrayerRowCard(prayer: prayer)
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Salah Shield")
            .navigationBarTitleDisplayMode(.large)
            .environment(\.timeZone, .autoupdatingCurrent)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
    
    private var nextPrayer: Prayer? {
        return appState.prayerTimeService.nextPrayer
    }
}

struct NextPrayerCard: View {
    let prayer: Prayer
    @State private var timeRemaining: String = ""
    
    var body: some View {
        SSCard(padding: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Next Prayer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack(alignment: .center) {
                    Image(systemName: prayer.type.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prayer.type.displayName)
                            .font(.system(size: 28, weight: .bold))
                        
                        Text(prayer.time, style: .time)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeUntil(prayer.time))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.accentColor)
                        
                        Text("remaining")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func timeUntil(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: date)
        var hours = components.hour ?? 0
        var minutes = components.minute ?? 0
        
        // Handle negative time (prayer already passed)
        if date < now {
            // Calculate time until next occurrence (tomorrow)
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                let tomorrowComponents = Calendar.current.dateComponents([.hour, .minute], from: now, to: tomorrow)
                hours = tomorrowComponents.hour ?? 0
                minutes = tomorrowComponents.minute ?? 0
            } else {
                return "0m"
            }
        }
        
        // Ensure non-negative
        hours = max(0, hours)
        minutes = max(0, minutes)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct PrayerRowCard: View {
    let prayer: Prayer
    
    var body: some View {
        SSCard(padding: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: prayer.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.type.displayName)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Window: \(prayer.bufferBefore + prayer.bufferAfter) min")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(prayer.time, style: .time)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(10)
        }
    }
}

struct QiblaCompassCard: View {
    let angle: Double // Angle in degrees (0 = North, 90 = East) - relative to device orientation
    let direction: String
    let heading: Double? // Device heading for display
    
    var body: some View {
        SSCard(padding: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Qibla Direction")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let heading = heading {
                            Text("Device: \(formatHeading(heading))")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(direction)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accentColor)
                        
                        if let qibla = heading != nil ? angle : nil {
                            Text("\(Int(qibla))°")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                }
                
                // Compass
                ZStack {
                    // Background circle
                    Circle()
                        .fill(DesignSystem.Colors.secondaryBackground)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                        )
                    
                    // Cardinal directions
                    VStack {
                        Text("N")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                        Spacer()
                        Text("S")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                    
                    HStack {
                        Text("W")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("E")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 200)
                    
                    // Qibla arrow - points to Qibla direction
                    // This rotates based on device orientation relative to Qibla
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                        .offset(y: -70)
                        .rotationEffect(.degrees(angle))
                        .shadow(color: .accentColor.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .frame(height: 200)
                
                // Instructions
                Text("Point your device toward the arrow to face Qibla")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func formatHeading(_ heading: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                         "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((heading + 11.25) / 22.5) % 16
        return directions[index]
    }
}
