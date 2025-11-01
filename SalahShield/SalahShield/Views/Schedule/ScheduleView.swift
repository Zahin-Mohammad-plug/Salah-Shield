//
//  ScheduleView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Schedule view showing prayer windows with customization
struct ScheduleView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPeriod: TimePeriod = .today
    @State private var selectedPrayer: Prayer?
    @State private var editingPrayer: Prayer?
    @State private var showBufferEditor = false
    
    private var prayers: [Prayer] {
        appState.prayerTimeService.todaysPrayers
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                
                // Prayer Schedule
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(prayers) { prayer in
                            PrayerScheduleCard(
                                prayer: prayer,
                                onTap: {
                                    selectedPrayer = prayer
                                    editingPrayer = prayer
                                    showBufferEditor = true
                                }
                            )
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.md)
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showBufferEditor) {
                if let prayer = editingPrayer {
                    BufferEditorSheet(
                        prayer: Binding(
                            get: { prayer },
                            set: { newValue in editingPrayer = newValue }
                        ),
                        onSave: {
                            if let updatedPrayer = editingPrayer,
                               let index = appState.prayerTimeService.todaysPrayers.firstIndex(where: { $0.id == updatedPrayer.id }) {
                                appState.prayerTimeService.todaysPrayers[index] = updatedPrayer
                            }
                            showBufferEditor = false
                        }
                    )
                }
            }
        }
    }
    

}

struct PrayerScheduleCard: View {
    let prayer: Prayer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            SSCard(padding: DesignSystem.Spacing.md) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack {
                        Image(systemName: prayer.type.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prayer.type.displayName)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text(prayer.time, style: .time)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    // Window Timeline
                    TimelineView(prayer: prayer)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimelineView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Timeline bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Active window
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: geometry.size.width, height: 8)
                    
                    // Prayer time marker
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 12, height: 12)
                        .offset(x: bufferRatio * geometry.size.width - 6)
                }
            }
            .frame(height: 12)
            
            // Time labels
            HStack {
                Text(prayer.windowStart, style: .time)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(prayer.bufferBefore)m")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(4)
                
                Text(prayer.time, style: .time)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(prayer.bufferAfter)m")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(prayer.windowEnd, style: .time)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var bufferRatio: CGFloat {
        let total = CGFloat(prayer.bufferBefore + prayer.bufferAfter)
        return total > 0 ? CGFloat(prayer.bufferBefore) / total : 0.5
    }
}

struct BufferEditorSheet: View {
    @Binding var prayer: Prayer
    @Environment(\.presentationMode) var presentationMode
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Prayer Time")) {
                    HStack {
                        Image(systemName: prayer.type.icon)
                            .foregroundColor(.accentColor)
                        Text(prayer.type.displayName)
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Text(prayer.time, style: .time)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Buffer Before (\(prayer.bufferBefore) minutes)")) {
                    Slider(value: Binding(
                        get: { Double(prayer.bufferBefore) },
                        set: { prayer.bufferBefore = Int($0) }
                    ), in: 0...30, step: 1)
                    
                    Text("Blocking starts \(prayer.bufferBefore) minutes before prayer")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Buffer After (\(prayer.bufferAfter) minutes)")) {
                    Slider(value: Binding(
                        get: { Double(prayer.bufferAfter) },
                        set: { prayer.bufferAfter = Int($0) }
                    ), in: 0...60, step: 1)
                    
                    Text("Blocking ends \(prayer.bufferAfter) minutes after prayer")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Toggle("Enable for this prayer", isOn: $prayer.isEnabled)
                }
            }
            .navigationTitle("Edit Window")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
}
