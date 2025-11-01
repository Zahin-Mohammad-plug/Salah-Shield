//
//  AppState.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI
import Combine
import CoreLocation

/// Central app state manager
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    @Published var selectedCity: String?
    @Published var calculationMethod: CalculationMethod = .mwl {
        didSet {
            UserDefaults.standard.set(calculationMethod.rawValue, forKey: "calculationMethod")
            // Recalculate prayer times when method changes
            if let location = locationService.currentLocation {
                prayerTimeService.calculatePrayerTimes(for: location, method: calculationMethod)
            }
        }
    }
    @Published var notificationsEnabled: Bool = false
    
    // Services
    @Published var locationService = LocationService()
    @Published var prayerTimeService = PrayerTimeService()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Load saved calculation method
        if let savedMethod = UserDefaults.standard.string(forKey: "calculationMethod"),
           let method = CalculationMethod(rawValue: savedMethod) {
            self.calculationMethod = method
        }
        
        setupLocationServiceBindings()
        setupPrayerTimeBindings()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    /// Request location permission and start prayer time calculations
    func requestLocationAccess() {
        locationService.requestLocationPermission()
    }
    
    /// Manually set city (for users who don't want to use location)
    func setManualCity(_ city: String, latitude: Double, longitude: Double) {
        selectedCity = city
        UserDefaults.standard.set(city, forKey: "selectedCity")
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        prayerTimeService.calculatePrayerTimes(for: location, method: calculationMethod)
    }
    
    private func setupLocationServiceBindings() {
        // Bind location service authorization status
        locationService.$authorizationStatus
            .map { status in
                switch status {
                case .notDetermined:
                    return LocationPermissionStatus.notDetermined
                case .authorizedWhenInUse, .authorizedAlways:
                    return LocationPermissionStatus.authorized
                case .denied, .restricted:
                    return LocationPermissionStatus.denied
                @unknown default:
                    return LocationPermissionStatus.denied
                }
            }
            .assign(to: &$locationPermissionStatus)
        
        // Bind current city from location service
        locationService.$currentCity
            .compactMap { $0 }
            .sink { [weak self] city in
                self?.selectedCity = city
                UserDefaults.standard.set(city, forKey: "selectedCity")
            }
            .store(in: &cancellables)
        
        // Calculate prayer times when location is updated
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self = self else { return }
                self.prayerTimeService.calculatePrayerTimes(for: location, method: self.calculationMethod)
            }
            .store(in: &cancellables)
    }
    
    private func setupPrayerTimeBindings() {
        // Load saved city on startup
        if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
            selectedCity = savedCity
        }
        
        // Refresh prayer times daily at midnight
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                let calendar = Calendar.current
                let now = Date()
                
                // Check if it's a new day (around midnight)
                if calendar.component(.hour, from: now) == 0 && calendar.component(.minute, from: now) < 2 {
                    self?.prayerTimeService.refresh()
                }
            }
            .store(in: &cancellables)
    }
    
    var currentStatus: AppStatus {
        if !hasCompletedOnboarding || locationPermissionStatus == .denied {
            return .needsSetup
        }
        if isPaused {
            return .paused
        }
        return isActive ? .active : .idle
    }
}

enum AppStatus {
    case active
    case idle
    case paused
    case needsSetup
    
    var title: String {
        switch self {
        case .active: return "Active"
        case .idle: return "Idle"
        case .paused: return "Paused"
        case .needsSetup: return "Setup Required"
        }
    }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .idle: return .gray
        case .paused: return .orange
        case .needsSetup: return .red
        }
    }
}

enum LocationPermissionStatus {
    case notDetermined
    case authorized
    case denied
    
    var displayText: String {
        switch self {
        case .notDetermined:
            return "Not set"
        case .authorized:
            return "Enabled"
        case .denied:
            return "Denied - Tap to enable"
        }
    }
}
