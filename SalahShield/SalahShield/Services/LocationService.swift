//
//  LocationService.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import Foundation
import CoreLocation
import Combine
import UIKit

/// Service for managing location permissions and coordinates
class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var locationError: String?
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // Only update if moved 1km
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Request location permission
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Direct user to settings
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    /// Start getting location updates
    private func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// Stop location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Get city name from coordinates
    private func geocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.locationError = "Failed to get city name: \(error.localizedDescription)"
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self?.locationError = "No city information found"
                    return
                }
                
                // Build city name from available information
                var cityComponents: [String] = []
                
                if let city = placemark.locality {
                    cityComponents.append(city)
                }
                
                if let country = placemark.country {
                    cityComponents.append(country)
                }
                
                self?.currentCity = cityComponents.joined(separator: ", ")
                self?.locationError = nil
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationUpdates()
            case .denied, .restricted:
                self.locationError = "Location access denied. Please enable in Settings."
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.locationError = nil
        }
        
        // Get city name for this location
        geocodeLocation(location)
        
        // Stop after getting first location to preserve battery
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Location error: \(error.localizedDescription)"
        }
    }
}
