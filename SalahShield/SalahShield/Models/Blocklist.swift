//
//  Blocklist.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import Foundation

struct Blocklist: Identifiable, Codable {
    let id: UUID
    var name: String
    var apps: [BlockedApp]
    var websites: [BlockedWebsite]
    var categories: [AppCategory]
    var lastUpdated: Date
    
    // MARK: - Future Premium Feature
    // TODO: Implement premium blocklists after core functionality is complete
    // var isPro: Bool
    
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        apps: [BlockedApp] = [],
        websites: [BlockedWebsite] = [],
        categories: [AppCategory] = [],
        lastUpdated: Date = Date(),
        // isPro: Bool = false, // FUTURE: Premium blocklists feature
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.apps = apps
        self.websites = websites
        self.categories = categories
        self.lastUpdated = lastUpdated
        // self.isPro = isPro // FUTURE: Premium blocklists feature
        self.isDefault = isDefault
    }
    
    var itemCount: Int {
        apps.count + websites.count + categories.count
    }
}

struct BlockedApp: Identifiable, Codable, Hashable {
    let id: UUID
    let bundleIdentifier: String
    let name: String
    let iconName: String?
    
    init(id: UUID = UUID(), bundleIdentifier: String, name: String, iconName: String? = nil) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.iconName = iconName
    }
}

struct BlockedWebsite: Identifiable, Codable, Hashable {
    let id: UUID
    let domain: String
    let displayName: String?
    
    init(id: UUID = UUID(), domain: String, displayName: String? = nil) {
        self.id = id
        self.domain = domain
        self.displayName = displayName
    }
    
    var name: String {
        displayName ?? domain
    }
}

enum AppCategory: String, CaseIterable, Codable {
    case socialMedia = "Social Media"
    case games = "Games"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case news = "News"
    case messaging = "Messaging"
    
    var icon: String {
        switch self {
        case .socialMedia: return "person.2.fill"
        case .games: return "gamecontroller.fill"
        case .entertainment: return "play.rectangle.fill"
        case .shopping: return "cart.fill"
        case .news: return "newspaper.fill"
        case .messaging: return "message.fill"
        }
    }
}
