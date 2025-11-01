//
//  MainTabView.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Main tab navigation after onboarding
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(Tab.schedule)
            
            BlocklistsView()
                .tabItem {
                    Label("Blocklists", systemImage: "shield.fill")
                }
                .tag(Tab.blocklists)
            
            ModesView()
                .tabItem {
                    Label("Modes", systemImage: "moon.fill")
                }
                .tag(Tab.modes)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .accentColor(.accentColor)
    }
    
    enum Tab {
        case home
        case schedule
        case blocklists
        case modes
        case settings
    }
}
