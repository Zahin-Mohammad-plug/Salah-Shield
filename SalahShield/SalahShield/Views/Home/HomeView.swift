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
    // @State private var showPaywall = false // FUTURE: Premium feature paywall
    @State private var showLocationBanner = false
    
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
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
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
            // FUTURE: Premium feature paywall
            // .sheet(isPresented: $showPaywall) {
            //     PaywallView()
            // }
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
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: date)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
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
