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
        
        // Get date components for today in the current timezone
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents(in: TimeZone.current, from: date)
        
        // Calculate prayer times using Adhan
        guard let prayerTimes = Adhan.PrayerTimes(
            coordinates: coordinates,
            date: dateComponents,
            calculationParameters: params
        ) else {
            calculationError = "Unable to calculate prayer times for this location"
            return []
        }
        
        // Debug: Print the actual times to console
        print("DEBUG Prayer Times for \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("Timezone: \(TimeZone.current.identifier)")
        print("Fajr: \(prayerTimes.fajr)")
        print("Dhuhr: \(prayerTimes.dhuhr)")
        print("Asr: \(prayerTimes.asr)")
        print("Maghrib: \(prayerTimes.maghrib)")
        print("Isha: \(prayerTimes.isha)")
        
        // Convert Adhan PrayerTimes to our Prayer models
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
            return Adhan.CalculationMethod.northAmerica.params
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
    private func updateNextPrayer() {
        let now = Date()
        nextPrayer = todaysPrayers.first { prayer in
            prayer.time > now
        }
    }
    
    /// Refresh prayer times (useful for when day changes or location updates)
    func refresh() {
        guard let location = location else { return }
        calculatePrayerTimes(for: location, method: calculationMethod)
    }
}
