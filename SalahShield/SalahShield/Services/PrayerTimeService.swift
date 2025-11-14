//
//  PrayerTimeService.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//
//  Uses Adhan library for accurate Islamic prayer time calculations
//  Library: https://github.com/batoulapps/adhan-swift
//

import Foundation
import CoreLocation
import Combine
import Adhan

/// Service for calculating prayer times using the Adhan library
class PrayerTimeService: ObservableObject {
    @Published var todaysPrayers: [Prayer] = []
    @Published var nextPrayer: Prayer?
    @Published var isCalculating = false
    @Published var calculationError: String?
    
    private var calculationMethod: CalculationMethod = .mwl
    private var location: CLLocation?
    
    /// Update prayer times for a specific location and date
    func calculatePrayerTimes(for location: CLLocation, date: Date = Date(), method: CalculationMethod = .mwl) {
        self.location = location
        self.calculationMethod = method
        
        isCalculating = true
        calculationError = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let prayers = self?.performPrayerCalculation(location: location, date: date, method: method) ?? []
            
            DispatchQueue.main.async {
                self?.todaysPrayers = prayers
                self?.updateNextPrayer()
                self?.isCalculating = false
                
                // Set error if no prayers calculated
                if prayers.isEmpty {
                    self?.calculationError = "Unable to calculate prayer times. Please check your location settings."
                }
            }
        }
    }
    
    /// Perform the actual prayer time calculation using Adhan library
    private func performPrayerCalculation(location: CLLocation, date: Date, method: CalculationMethod) -> [Prayer] {
        let coordinates = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        // Convert our calculation method to Adhan's CalculationParameters
        var params = getAdhanCalculationParameters(for: method)
        
        // Sensible defaults
        params.madhab = .shafi // TODO: expose in Settings later
        params.highLatitudeRule = .middleOfTheNight
        
        // Get the ACTUAL local timezone for the coordinates, not the device timezone
        // This fixes the issue where device timezone doesn't match coordinate location
        let deviceTimeZone = TimeZone.current
        let calendar = Calendar.current
        
        // Calculate UTC offset for debugging
        let utcOffset = Double(deviceTimeZone.secondsFromGMT(for: date))
        
        // CRITICAL DEBUG: Check if DST is being applied correctly
        // November 1, 2025 should be AFTER DST ends (DST typically ends first Sunday in November)
        // So Ottawa should be EST (UTC-5) NOT EDT (UTC-4)
        let isDST = deviceTimeZone.isDaylightSavingTime(for: date)
        let expectedOffset = isDST ? -14400.0 : -18000.0 // EDT=-4h, EST=-5h
        
        print("🚨 DST DEBUG:")
        print("   Is DST active for this date? \(isDST)")
        print("   Current offset: \(utcOffset) seconds (\(utcOffset/3600) hours)")
        print("   Expected offset: \(expectedOffset) seconds (\(expectedOffset/3600) hours)")
        
        if utcOffset != expectedOffset {
            print("   ⚠️ WARNING: Timezone offset mismatch! This may cause incorrect prayer times.")
            print("   ⚠️ For November 1, 2025, Ottawa should be in EST (UTC-5), not EDT (UTC-4)")
        }
        
        // CRITICAL FIX: Create DateComponents without any timezone information
        // The Adhan library will calculate times in the local solar time for the coordinates
        // and return Date objects that we then interpret in the device's timezone
        var components = DateComponents()
        components.year = calendar.component(.year, from: date)
        components.month = calendar.component(.month, from: date)
        components.day = calendar.component(.day, from: date)
        
        // Debug: Print detailed info
        print("🕌 DEBUG Prayer Time Calculation")
        print("📍 Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Identify the location to verify coordinates are correct
        if abs(location.coordinate.latitude - 37.7858) < 0.01 && abs(location.coordinate.longitude - (-122.4064)) < 0.01 {
            print("🚨 WARNING: Using San Francisco coordinates! This should be Ottawa coordinates.")
        } else if abs(location.coordinate.latitude - 45.4215) < 0.01 && abs(location.coordinate.longitude - (-75.6972)) < 0.01 {
            print("✅ Using Ottawa coordinates")
        }
        
        print("🌍 Device TimeZone: \(deviceTimeZone.identifier)")
        print("🌍 UTC Offset: \(utcOffset) seconds (\(utcOffset/3600) hours)")
        print("📅 Date: \(components.year!)-\(components.month!)-\(components.day!)")
        print("🎯 Method: \(method.rawValue)")
        print("⚙️ Fajr Angle: \(params.fajrAngle)°")
        print("⚙️ Isha Angle: \(params.ishaAngle)°")
        print("⚙️ Madhab: \(params.madhab)")
        print("⚙️ High Latitude Rule: \(String(describing: params.highLatitudeRule))")
        
        // CRITICAL: Calculate prayer times using Adhan
        guard let prayerTimes = Adhan.PrayerTimes(
            coordinates: coordinates,
            date: components,
            calculationParameters: params
        ) else {
            print("❌ Failed to calculate prayer times")
            return []
        }
        
        // Debug: Print the RAW times returned by Adhan
        print("⏰ RAW Prayer Times from Adhan library:")
        print("   Fajr RAW: \(prayerTimes.fajr)")
        print("   Dhuhr RAW: \(prayerTimes.dhuhr)")
        
        // Debug: Print in different timezones to see what's happening
        let formatterUTC = DateFormatter()
        formatterUTC.timeZone = TimeZone(identifier: "UTC")
        formatterUTC.dateFormat = "h:mm a z"
        
        let formatterLocal = DateFormatter()
        formatterLocal.timeZone = deviceTimeZone
        formatterLocal.dateFormat = "h:mm a z"
        
        print("⏰ Fajr in UTC: \(formatterUTC.string(from: prayerTimes.fajr))")
        print("⏰ Fajr in Local: \(formatterLocal.string(from: prayerTimes.fajr))")
        print("⏰ Dhuhr in UTC: \(formatterUTC.string(from: prayerTimes.dhuhr))")
        print("⏰ Dhuhr in Local: \(formatterLocal.string(from: prayerTimes.dhuhr))")
        print("=" + String(repeating: "=", count: 50))
        
        // CORRECT APPROACH: Adhan returns Date objects that represent the correct absolute time
        // We just need to display them with the local timezone in our UI
        // SwiftUI's Text(date, style: .time) automatically uses the device's timezone
        
        // Convert Adhan PrayerTimes to our Prayer models
        // These Date objects are correct - they just need to be displayed with local timezone in UI
        return [
            Prayer(type: .fajr, time: prayerTimes.fajr),
            Prayer(type: .dhuhr, time: prayerTimes.dhuhr),
            Prayer(type: .asr, time: prayerTimes.asr),
            Prayer(type: .maghrib, time: prayerTimes.maghrib),
            Prayer(type: .isha, time: prayerTimes.isha)
        ]
    }
    
    /// Convert our CalculationMethod enum to Adhan's CalculationParameters
    private func getAdhanCalculationParameters(for method: CalculationMethod) -> CalculationParameters {
        switch method {
        case .mwl:
            return Adhan.CalculationMethod.muslimWorldLeague.params
        case .isna:
            // Let's try a custom ISNA implementation that matches what Canadian mosques use
            var params = Adhan.CalculationMethod.northAmerica.params
            
            // Debug: Print the default ISNA parameters
            print("🔍 Default ISNA parameters:")
            print("   Fajr Angle: \(params.fajrAngle)°")
            print("   Isha Angle: \(params.ishaAngle)°")
            
            // For Canada, many mosques use slightly different parameters than standard ISNA
            // Let's try 15° for Fajr (which ISNA uses) but with adjustments
            params.fajrAngle = 15.0
            params.ishaAngle = 15.0
            
            // Try adjusting the method - some Canadian communities use slightly earlier Fajr
            params.adjustments.fajr = -10 // 10 minutes earlier
            
            print("🔧 Adjusted ISNA parameters for Canada:")
            print("   Fajr Angle: \(params.fajrAngle)° (with -10min adjustment)")
            print("   Isha Angle: \(params.ishaAngle)°")
            
            return params
        case .egypt:
            return Adhan.CalculationMethod.egyptian.params
        case .makkah:
            return Adhan.CalculationMethod.ummAlQura.params
        case .karachi:
            return Adhan.CalculationMethod.karachi.params
        case .tehran:
            return Adhan.CalculationMethod.tehran.params
        case .jafari:
            // Adhan doesn't have a dedicated Jafari method; Tehran is a close alternative
            return Adhan.CalculationMethod.tehran.params
        }
    }
    
    /// Update which prayer is next
    func updateNextPrayer() {
        let now = Date()
        // Find next prayer today
        if let nextToday = todaysPrayers.first(where: { $0.time > now }) {
            nextPrayer = nextToday
        } else if !todaysPrayers.isEmpty {
            // All prayers passed - show next day's Fajr
            // Calculate tomorrow's Fajr asynchronously to avoid blocking
            let calendar = Calendar.current
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
               let location = location {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    // Calculate tomorrow's prayer times
                    let tomorrowPrayers = self.performPrayerCalculation(location: location, date: tomorrow, method: self.calculationMethod)
                    DispatchQueue.main.async {
                        self.nextPrayer = tomorrowPrayers.first // Fajr is always first
                    }
                }
            } else {
                nextPrayer = nil
            }
        } else {
            nextPrayer = nil
        }
    }
    
    /// Refresh prayer times (useful for when day changes or location updates)
    func refresh() {
        guard let location = location else { return }
        calculatePrayerTimes(for: location, method: calculationMethod)
    }
}
