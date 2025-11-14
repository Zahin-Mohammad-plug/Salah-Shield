//
//  BlocklistsView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI
import FamilyControls

/// Blocklists management screen
struct BlocklistsView: View {
    @EnvironmentObject var appState: AppState
    @State private var blocklists: [Blocklist] = [
        Blocklist(name: "Default", isDefault: true),
        Blocklist(name: "Social Media", isDefault: false),
    ]
    @State private var showAddBlocklist = false
    @State private var showPaywall = false
    @State private var selectedBlocklist: Blocklist?
    
    var body: some View {
        NavigationView {
            Group {
                if blocklists.isEmpty {
                    SSEmptyState(
                        icon: "shield.slash",
                        title: "No Blocklists",
                        message: "Create your first blocklist to start managing distractions during prayer times",
                        actionTitle: "Create Blocklist",
                        action: {
                            showAddBlocklist = true
                        }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            // Premium banner if not Pro and at limit
                            if !appState.isPro && blocklists.count >= 1 {
                                SSBanner(
                                    message: "You have 1 free blocklist. Upgrade to Pro for unlimited blocklists.",
                                    type: .info,
                                    action: { showPaywall = true }
                                )
                                .padding(.horizontal, DesignSystem.Spacing.md)
                            }
                            
                            ForEach(blocklists) { blocklist in
                                BlocklistCard(
                                    blocklist: blocklist,
                                    onTap: {
                                        selectedBlocklist = blocklist
                                    }
                                )
                                .padding(.horizontal, DesignSystem.Spacing.md)
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.md)
                    }
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Blocklists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Restrict to 1 free blocklist, require Pro for more
                        if appState.isPro || blocklists.count < 1 {
                            showAddBlocklist = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBlocklist) {
                AddBlocklistSheet(onSave: { newBlocklist in
                    blocklists.append(newBlocklist)
                    showAddBlocklist = false
                })
            }
            .sheet(item: $selectedBlocklist) { blocklist in
                BlocklistDetailView(blocklist: binding(for: blocklist))
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
    
    // FUTURE: Track free blocklist limit for premium upsell
    // private var freeBlocklistsRemaining: Int {
    //     let freeCount = blocklists.filter { !$0.isPro }.count
    //     return max(0, 1 - freeCount)
    // }
    
    private func binding(for blocklist: Blocklist) -> Binding<Blocklist> {
        guard let index = blocklists.firstIndex(where: { $0.id == blocklist.id }) else {
            return .constant(blocklist)
        }
        return $blocklists[index]
    }
}

struct BlocklistCard: View {
    let blocklist: Blocklist
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            SSCard(padding: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Text(blocklist.name)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                if blocklist.isDefault {
                                    Text("DEFAULT")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue)
                                        .cornerRadius(4)
                                }
                                
                                // FUTURE: Show PRO badge for premium blocklists
                                // if blocklist.isPro {
                                //     Text("PRO")
                                //         .font(.system(size: 10, weight: .bold))
                                //         .foregroundColor(.white)
                                //         .padding(.horizontal, 6)
                                //         .padding(.vertical, 2)
                                //         .background(Color.purple)
                                //         .cornerRadius(4)
                                // }
                            }
                            
                            Text("\(blocklist.itemCount) items")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    if blocklist.itemCount > 0 {
                        Text("Last updated: \(blocklist.lastUpdated, style: .relative)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddBlocklistSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    let onSave: (Blocklist) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Blocklist Name")) {
                    TextField("Enter name", text: $name)
                }
                
                Section {
                    Text("You can add apps, websites, and categories after creating the blocklist.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Blocklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let blocklist = Blocklist(name: name)
                        onSave(blocklist)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct BlocklistDetailView: View {
    @Binding var blocklist: Blocklist
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var showActivityPicker = false
    @State private var showScreenTimeAuth = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Blocked Apps & Websites")) {
                    // Show Screen Time authorization status
                    if appState.screenTimeService.authorizationStatus != .approved {
                        SSBanner(
                            message: "Screen Time authorization required to block apps",
                            type: .warning,
                            action: {
                                showScreenTimeAuth = true
                            }
                        )
                    }
                    
                    // Show selected apps count if selection exists
                    if let selection = appState.screenTimeService.selection {
                        Text("\(selection.applicationTokens.count) apps selected")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("\(selection.webDomainTokens.count) websites selected")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    } else {
                        Text("No apps or websites selected")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    
                    Button(action: {
                        if appState.screenTimeService.authorizationStatus == .approved {
                            showActivityPicker = true
                        } else {
                            showScreenTimeAuth = true
                        }
                    }) {
                        Label(appState.screenTimeService.selection != nil ? "Change Selection" : "Select Apps & Websites", systemImage: "app.badge.checkmark")
                    }
                }
                
            }
            .navigationTitle(blocklist.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showActivityPicker) {
                FamilyActivityPickerView(
                    selection: Binding(
                        get: { appState.screenTimeService.selection ?? FamilyActivitySelection() },
                        set: { newSelection in
                            appState.screenTimeService.saveSelection(newSelection)
                            blocklist.lastUpdated = Date()
                        }
                    )
                )
            }
            .alert("Screen Time Authorization Required", isPresented: $showScreenTimeAuth) {
                Button("Settings") {
                    appState.screenTimeService.requestAuthorization()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Salah Shield needs Screen Time permissions to block apps during prayer times. Please authorize in Settings.")
            }
        }
    }
}

// MARK: - Family Activity Picker View
struct FamilyActivityPickerView: View {
    @Binding var selection: FamilyActivitySelection
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Select Apps & Websites")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}

struct AddAppSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var appName: String = ""
    @State private var bundleId: String = ""
    let onSave: (BlockedApp) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Details")) {
                    TextField("App Name", text: $appName)
                    TextField("Bundle Identifier", text: $bundleId)
                        .autocapitalization(.none)
                }
                
                Section {
                    Text("Example: com.instagram.app")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let app = BlockedApp(bundleIdentifier: bundleId, name: appName)
                        onSave(app)
                    }
                    .disabled(appName.isEmpty || bundleId.isEmpty)
                }
            }
        }
    }
}

struct AddWebsiteSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var domain: String = ""
    let onSave: (BlockedWebsite) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Website Domain")) {
                    TextField("example.com", text: $domain)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                
                Section {
                    Text("Enter the domain without http:// or www.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Website")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let website = BlockedWebsite(domain: domain)
                        onSave(website)
                    }
                    .disabled(domain.isEmpty)
                }
            }
        }
    }
}
