//
//  Prayer.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import Foundation

struct Prayer: Identifiable, Hashable {
    let id: UUID
    let type: PrayerType
    let time: Date
    var bufferBefore: Int // minutes
    var bufferAfter: Int // minutes
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        type: PrayerType,
        time: Date,
        bufferBefore: Int = 5,
        bufferAfter: Int = 15,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.type = type
        self.time = time
        self.bufferBefore = bufferBefore
        self.bufferAfter = bufferAfter
        self.isEnabled = isEnabled
    }
    
    var windowStart: Date {
        Calendar.current.date(byAdding: .minute, value: -bufferBefore, to: time) ?? time
    }
    
    var windowEnd: Date {
        Calendar.current.date(byAdding: .minute, value: bufferAfter, to: time) ?? time
    }
    
    var totalDuration: Int {
        bufferBefore + bufferAfter
    }
}

enum PrayerType: String, CaseIterable, Codable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    var icon: String {
        switch self {
        case .fajr: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.stars.fill"
        }
    }
    
    var displayName: String {
        rawValue
    }
}

enum CalculationMethod: String, CaseIterable, Codable {
    case mwl = "Muslim World League"
    case isna = "ISNA"
    case egypt = "Egyptian General Authority"
    case makkah = "Umm Al-Qura University"
    case karachi = "University of Karachi"
    case tehran = "Institute of Geophysics, Tehran"
    case jafari = "Shia Ithna-Ashari (Jafari)"
    
    var description: String {
        switch self {
        case .mwl: return "Used in Europe, Far East, parts of America"
        case .isna: return "Islamic Society of North America"
        case .egypt: return "Used in Africa, Syria, Iraq, Lebanon, Malaysia"
        case .makkah: return "Used in Saudi Arabia"
        case .karachi: return "Used in Pakistan, Bangladesh, India, Afghanistan"
        case .tehran: return "Used in Iran, some Shia communities"
        case .jafari: return "Used by Shia communities worldwide"
        }
    }
}
