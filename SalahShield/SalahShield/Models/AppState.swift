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
            let value = hasCompletedOnboarding
            DispatchQueue.main.async {
                UserDefaults.standard.set(value, forKey: "hasCompletedOnboarding")
            }
        }
    }
    
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    @Published var selectedCity: String?
    @Published var calculationMethod: CalculationMethod {
        didSet {
            let method = calculationMethod
            DispatchQueue.main.async {
                UserDefaults.standard.set(method.rawValue, forKey: "calculationMethod")
                print("💾 Saved calculation method: \(method.rawValue)")
            }
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
    @Published var screenTimeService = ScreenTimeService()
    @Published var qiblaService = QiblaService()
    
    // Premium features demo flag
    @Published var isPro: Bool = true // Set to true for demo
    
    private var cancellables = Set<AnyCancellable>()
    private var blockingTimer: Timer?
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // CRITICAL FIX: Load saved calculation method FIRST, before setting up bindings
        // Default to ISNA for North America if no saved method exists
        if let savedMethod = UserDefaults.standard.string(forKey: "calculationMethod"),
           let method = CalculationMethod(rawValue: savedMethod) {
            self.calculationMethod = method
            print("📖 Loaded saved calculation method: \(method.rawValue)")
        } else {
            // First time user - default to ISNA for best experience in North America
            // This will be overridden by country detection if needed
            self.calculationMethod = .isna
            print("🆕 First time user - defaulting to ISNA")
        }
        
        setupLocationServiceBindings()
        setupPrayerTimeBindings()
        setupBlockingManager()
    }
    
    deinit {
        blockingTimer?.invalidate()
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
        DispatchQueue.main.async {
            UserDefaults.standard.set(city, forKey: "selectedCity")
        }
        
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
                DispatchQueue.main.async {
                    UserDefaults.standard.set(city, forKey: "selectedCity")
                }
            }
            .store(in: &cancellables)
        
        // Calculate prayer times when location is updated
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self = self else { return }
                
                // Calculate Qibla direction
                self.qiblaService.calculateQibla(from: location)
                
                // Suggest a default calculation method based on country FIRST
                self.suggestDefaultCalculationMethod(for: location) {
                    // Then calculate prayer times with the correct method
                    self.prayerTimeService.calculatePrayerTimes(for: location, method: self.calculationMethod)
                }
            }
            .store(in: &cancellables)
        
        // Update Qibla angle with live heading updates
        locationService.$heading
            .compactMap { $0 }
            .sink { [weak self] heading in
                self?.qiblaService.updateHeading(heading)
            }
            .store(in: &cancellables)
    }
    
    /// Suggests and applies a default calculation method based on the user's country.
    private func suggestDefaultCalculationMethod(for location: CLLocation, completion: @escaping () -> Void) {
        // Only set the default method once during the first run or if it hasn't been manually changed
        let hasSetDefaultMethod = UserDefaults.standard.bool(forKey: "hasSetDefaultMethod")
        if hasSetDefaultMethod { 
            print("ℹ️ User has manually set calculation method, skipping auto-suggestion")
            completion()
            return 
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, let countryCode = placemark.isoCountryCode else { 
                completion()
                return 
            }
            
            var suggestedMethod: CalculationMethod = .mwl // Default for most
            
            switch countryCode {
            case "US", "CA":
                suggestedMethod = .isna
            case "SA":
                suggestedMethod = .makkah
            case "EG":
                suggestedMethod = .egypt
            case "PK", "IN", "BD", "AF":
                suggestedMethod = .karachi
            case "IR":
                suggestedMethod = .tehran
            default:
                suggestedMethod = .mwl
            }
            
            DispatchQueue.main.async {
                print("🌍 Auto-setting calculation method for country '\(countryCode)': \(suggestedMethod.rawValue)")
                self.calculationMethod = suggestedMethod
                
                // Now mark that we've set the default (so we don't override user's manual changes later)
                UserDefaults.standard.set(true, forKey: "hasSetDefaultMethod")
                
                completion()
            }
        }
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
                
                // Check if it's a new day (first hour after midnight)
                // This checks every minute, so we catch any time in the first hour
                let hour = calendar.component(.hour, from: now)
                if hour == 0 || (hour == 23 && calendar.component(.minute, from: now) >= 59) {
                    // Refresh at start of new day, or right before midnight
                    // refresh() already calls updateNextPrayer() internally
                    self?.prayerTimeService.refresh()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Setup blocking manager to automatically block/unblock apps during prayer windows
    private func setupBlockingManager() {
        // Monitor prayer times and current time to determine when to block
        Timer.publish(every: 30, on: .main, in: .common) // Check every 30 seconds
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndUpdateBlocking()
            }
            .store(in: &cancellables)
        
        // Also check immediately when prayers update
        prayerTimeService.$todaysPrayers
            .sink { [weak self] _ in
                self?.checkAndUpdateBlocking()
            }
            .store(in: &cancellables)
    }
    
    /// Check if we're currently in a prayer window and block/unblock accordingly
    private func checkAndUpdateBlocking() {
        // Don't block if paused or inactive
        guard !isPaused && isActive else {
            Task { @MainActor in
                screenTimeService.stopBlocking()
            }
            return
        }
        
        // Check if we're in any prayer window
        let now = Date()
        let isInPrayerWindow = prayerTimeService.todaysPrayers.contains { prayer in
            guard prayer.isEnabled else { return false }
            return now >= prayer.windowStart && now <= prayer.windowEnd
        }
        
        Task { @MainActor in
            if isInPrayerWindow {
                // Start blocking - get the default blocklist
                if let defaultBlocklist = getDefaultBlocklist() {
                    await startBlockingWithBlocklist(defaultBlocklist)
                }
            } else {
                // Stop blocking
                screenTimeService.stopBlocking()
            }
        }
    }
    
    /// Get the default blocklist from storage
    @MainActor
    private func getDefaultBlocklist() -> Blocklist? {
        // Check if we have a saved selection in ScreenTimeService
        // If selection exists, we can block
        guard screenTimeService.selection != nil else {
            return nil
        }
        
        // Return a default blocklist - the actual apps are stored in FamilyActivitySelection
        return Blocklist(name: "Default", isDefault: true)
    }
    
    /// Start blocking with the given blocklist
    @MainActor
    private func startBlockingWithBlocklist(_ blocklist: Blocklist) async {
        // Check authorization first
        guard screenTimeService.authorizationStatus == .approved else {
            // Authorization not granted, can't block
            return
        }
        
        // Use saved selection if available
        if let selection = screenTimeService.selection {
            screenTimeService.startBlocking(selection: selection)
        }
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
