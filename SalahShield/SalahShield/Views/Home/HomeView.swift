//
//  HomeView.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Home screen showing next prayer and today's schedule
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaywall = false
    @State private var showLocationBanner = false
    
    // Mock data - replace with real prayer times
    @State private var todaysPrayers: [Prayer] = [
        Prayer(type: .fajr, time: Calendar.current.date(bySettingHour: 5, minute: 30, second: 0, of: Date())!),
        Prayer(type: .dhuhr, time: Calendar.current.date(bySettingHour: 12, minute: 45, second: 0, of: Date())!),
        Prayer(type: .asr, time: Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!),
        Prayer(type: .maghrib, time: Calendar.current.date(bySettingHour: 17, minute: 45, second: 0, of: Date())!),
        Prayer(type: .isha, time: Calendar.current.date(bySettingHour: 19, minute: 15, second: 0, of: Date())!)
    ]
    
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
                                // Open settings
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
    
    private var nextPrayer: Prayer? {
        let now = Date()
        return todaysPrayers.first(where: { $0.time > now })
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
