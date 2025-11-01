//
//  PrayerTimeService.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import Foundation
import CoreLocation
import Combine

/// Service for calculating prayer times using astronomical calculations
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
            do {
                let prayers = try self?.performPrayerCalculation(location: location, date: date, method: method) ?? []
                
                DispatchQueue.main.async {
                    self?.todaysPrayers = prayers
                    self?.updateNextPrayer()
                    self?.isCalculating = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.calculationError = "Failed to calculate prayer times: \(error.localizedDescription)"
                    self?.isCalculating = false
                }
            }
        }
    }
    
    /// Perform the actual prayer time calculation
    private func performPrayerCalculation(location: CLLocation, date: Date, method: CalculationMethod) throws -> [Prayer] {
        let calculator = PrayerTimeCalculator(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timeZone: TimeZone.current
        )
        
        let times = try calculator.calculatePrayerTimes(for: date, method: method)
        
        return [
            Prayer(type: .fajr, time: times.fajr),
            Prayer(type: .dhuhr, time: times.dhuhr),
            Prayer(type: .asr, time: times.asr),
            Prayer(type: .maghrib, time: times.maghrib),
            Prayer(type: .isha, time: times.isha)
        ]
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

// MARK: - Prayer Time Calculator
struct PrayerTimeCalculator {
    let latitude: Double
    let longitude: Double
    let timeZone: TimeZone
    
    struct PrayerTimes {
        let fajr: Date
        let dhuhr: Date
        let asr: Date
        let maghrib: Date
        let isha: Date
    }
    
    func calculatePrayerTimes(for date: Date, method: CalculationMethod) throws -> PrayerTimes {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        // Calculate solar declination
        let declination = calculateDeclination(dayOfYear: dayOfYear)
        
        // Calculate equation of time
        let equationOfTime = calculateEquationOfTime(dayOfYear: dayOfYear)
        
        // Get method parameters
        let params = getMethodParameters(method)
        
        // Calculate prayer times
        let dhuhr = calculateDhuhr(date: date, equationOfTime: equationOfTime)
        let fajr = calculateFajr(dhuhr: dhuhr, declination: declination, fajrAngle: params.fajrAngle)
        let asr = calculateAsr(dhuhr: dhuhr, declination: declination, asrFactor: params.asrFactor)
        let maghrib = calculateMaghrib(dhuhr: dhuhr, declination: declination, maghribAngle: params.maghribAngle)
        let isha = calculateIsha(dhuhr: dhuhr, maghrib: maghrib, declination: declination, ishaAngle: params.ishaAngle, ishaInterval: params.ishaInterval)
        
        return PrayerTimes(
            fajr: fajr,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha
        )
    }
    
    // MARK: - Calculation Methods Parameters
    private struct MethodParameters {
        let fajrAngle: Double
        let ishaAngle: Double
        let ishaInterval: Double? // minutes after maghrib
        let maghribAngle: Double
        let asrFactor: Double
    }
    
    private func getMethodParameters(_ method: CalculationMethod) -> MethodParameters {
        switch method {
        case .mwl:
            return MethodParameters(fajrAngle: 18.0, ishaAngle: 17.0, ishaInterval: nil, maghribAngle: 0.83, asrFactor: 1.0)
        case .isna:
            return MethodParameters(fajrAngle: 15.0, ishaAngle: 15.0, ishaInterval: nil, maghribAngle: 0.83, asrFactor: 1.0)
        case .egypt:
            return MethodParameters(fajrAngle: 19.5, ishaAngle: 17.5, ishaInterval: nil, maghribAngle: 0.83, asrFactor: 1.0)
        case .makkah:
            return MethodParameters(fajrAngle: 18.5, ishaAngle: 0.0, ishaInterval: 90, maghribAngle: 0.83, asrFactor: 1.0)
        case .karachi:
            return MethodParameters(fajrAngle: 18.0, ishaAngle: 18.0, ishaInterval: nil, maghribAngle: 0.83, asrFactor: 1.0)
        case .tehran:
            return MethodParameters(fajrAngle: 17.7, ishaAngle: 14.0, ishaInterval: nil, maghribAngle: 4.5, asrFactor: 1.0)
        case .jafari:
            return MethodParameters(fajrAngle: 16.0, ishaAngle: 14.0, ishaInterval: nil, maghribAngle: 4.0, asrFactor: 1.0)
        }
    }
    
    // MARK: - Astronomical Calculations
    
    private func calculateDeclination(dayOfYear: Int) -> Double {
        let p = asin(0.39795 * cos(0.98563 * Double(dayOfYear - 173) * .pi / 180))
        return p
    }
    
    private func calculateEquationOfTime(dayOfYear: Int) -> Double {
        let b = 2 * .pi * (Double(dayOfYear) - 81) / 365
        let e = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b)
        return e / 60.0 // Convert to hours
    }
    
    private func calculateDhuhr(date: Date, equationOfTime: Double) -> Date {
        let calendar = Calendar.current
        
        // Solar noon occurs when the sun is at its highest point
        let solarNoon = 12.0 - (longitude / 15.0) - equationOfTime
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let hours = Int(solarNoon)
        let minutes = Int((solarNoon - Double(hours)) * 60)
        
        components.hour = hours
        components.minute = minutes
        components.second = 0
        
        return calendar.date(from: components) ?? date
    }
    
    private func calculateFajr(dhuhr: Date, declination: Double, fajrAngle: Double) -> Date {
        let t = calculateTimeForAngle(declination: declination, angle: fajrAngle)
        return Calendar.current.date(byAdding: .minute, value: Int(-t * 60), to: dhuhr) ?? dhuhr
    }
    
    private func calculateAsr(dhuhr: Date, declination: Double, asrFactor: Double) -> Date {
        let shadowLength = asrFactor + tan(abs(latitude * .pi / 180 - declination))
        let angle = atan(1.0 / shadowLength) * 180 / .pi
        let t = calculateTimeForAngle(declination: declination, angle: 90 - angle)
        return Calendar.current.date(byAdding: .minute, value: Int(t * 60), to: dhuhr) ?? dhuhr
    }
    
    private func calculateMaghrib(dhuhr: Date, declination: Double, maghribAngle: Double) -> Date {
        let t = calculateTimeForAngle(declination: declination, angle: maghribAngle)
        return Calendar.current.date(byAdding: .minute, value: Int(t * 60), to: dhuhr) ?? dhuhr
    }
    
    private func calculateIsha(dhuhr: Date, maghrib: Date, declination: Double, ishaAngle: Double, ishaInterval: Double?) -> Date {
        if let interval = ishaInterval {
            // Method uses fixed interval after maghrib (e.g., Makkah method)
            return Calendar.current.date(byAdding: .minute, value: Int(interval), to: maghrib) ?? maghrib
        } else {
            // Method uses sun angle
            let t = calculateTimeForAngle(declination: declination, angle: ishaAngle)
            return Calendar.current.date(byAdding: .minute, value: Int(t * 60), to: dhuhr) ?? dhuhr
        }
    }
    
    private func calculateTimeForAngle(declination: Double, angle: Double) -> Double {
        let latRad = latitude * .pi / 180
        let decRad = declination
        let angleRad = angle * .pi / 180
        
        let numerator = sin(angleRad) - sin(decRad) * sin(latRad)
        let denominator = cos(decRad) * cos(latRad)
        
        guard denominator != 0 else { return 0 }
        
        let t = acos(numerator / denominator) * 180 / .pi / 15.0
        return t
    }
}