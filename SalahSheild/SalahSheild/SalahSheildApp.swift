//
//  SalahSheildApp.swift
//  SalahSheild
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

@main
struct SalahSheildApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
