//
//  BlocklistsView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Blocklists management screen
struct BlocklistsView: View {
    @State private var blocklists: [Blocklist] = [
        Blocklist(name: "Default", isDefault: true),
        Blocklist(name: "Social Media", isDefault: false),
    ]
    @State private var showAddBlocklist = false
    // @State private var showPaywall = false // FUTURE: Premium feature paywall
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
                            // FUTURE: Premium feature - limit to 1 free blocklist
                            // SSBanner(
                            //     message: "You have 1 free blocklist. Upgrade to Pro for unlimited blocklists.",
                            //     type: .info,
                            //     action: { showPaywall = true }
                            // )
                            // .padding(.horizontal, DesignSystem.Spacing.md)
                            
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
                        // FUTURE: Restrict to 1 free blocklist, require Pro for more
                        // if freeBlocklistsRemaining > 0 {
                        //     showAddBlocklist = true
                        // } else {
                        //     showPaywall = true
                        // }
                        showAddBlocklist = true
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
            // FUTURE: Premium feature paywall
            // .sheet(isPresented: $showPaywall) {
            //     PaywallView()
            // }
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
    @State private var showAddApp = false
    @State private var showAddWebsite = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Apps (\(blocklist.apps.count))")) {
                    if blocklist.apps.isEmpty {
                        Text("No apps added")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    } else {
                        ForEach(blocklist.apps) { app in
                            HStack {
                                Image(systemName: "app.fill")
                                    .foregroundColor(.accentColor)
                                Text(app.name)
                            }
                        }
                        .onDelete { indexSet in
                            blocklist.apps.remove(atOffsets: indexSet)
                        }
                    }
                    
                    Button(action: { showAddApp = true }) {
                        Label("Add App", systemImage: "plus.circle.fill")
                    }
                }
                
                Section(header: Text("Websites (\(blocklist.websites.count))")) {
                    if blocklist.websites.isEmpty {
                        Text("No websites added")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    } else {
                        ForEach(blocklist.websites) { website in
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.accentColor)
                                Text(website.name)
                            }
                        }
                        .onDelete { indexSet in
                            blocklist.websites.remove(atOffsets: indexSet)
                        }
                    }
                    
                    Button(action: { showAddWebsite = true }) {
                        Label("Add Website", systemImage: "plus.circle.fill")
                    }
                }
                
                Section(header: Text("Categories (\(blocklist.categories.count))")) {
                    if blocklist.categories.isEmpty {
                        Text("No categories added")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    } else {
                        ForEach(blocklist.categories, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.accentColor)
                                Text(category.rawValue)
                            }
                        }
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
            .sheet(isPresented: $showAddApp) {
                AddAppSheet { app in
                    blocklist.apps.append(app)
                    blocklist.lastUpdated = Date()
                    showAddApp = false
                }
            }
            .sheet(isPresented: $showAddWebsite) {
                AddWebsiteSheet { website in
                    blocklist.websites.append(website)
                    blocklist.lastUpdated = Date()
                    showAddWebsite = false
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
