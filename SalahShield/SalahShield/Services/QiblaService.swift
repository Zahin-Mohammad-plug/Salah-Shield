//
//  QiblaService.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

/// Service for calculating Qibla direction
class QiblaService: ObservableObject {
    @Published var qiblaDirection: Double? // Direction in degrees (0 = North, 90 = East, etc.)
    @Published var heading: Double? // Device heading from compass
    @Published var qiblaAngle: Double? // Angle to rotate arrow (0 = North, positive = clockwise)
    
    private let kaabaLocation = CLLocation(latitude: 21.4225, longitude: 39.8262) // Kaaba coordinates
    
    /// Calculate Qibla direction from a location
    func calculateQibla(from location: CLLocation) {
        // Calculate bearing from location to Kaaba
        let bearing = calculateBearing(from: location, to: kaabaLocation)
        self.qiblaDirection = bearing
        
        // Calculate angle for arrow (North = 0, East = 90, South = 180, West = 270)
        self.qiblaAngle = bearing
    }
    
    /// Update with device heading for live compass
    func updateHeading(_ heading: Double) {
        self.heading = heading
        
        if let qibla = qiblaDirection {
            // Calculate relative angle: qibla - heading
            // This gives us the angle to rotate the arrow relative to device's current orientation
            // When device points North (heading = 0), arrow should point at qibla direction
            // As device rotates, arrow rotates in opposite direction to maintain correct bearing
            var relativeAngle = qibla - heading
            
            // Normalize to 0-360 range
            if relativeAngle < 0 {
                relativeAngle += 360
            } else if relativeAngle >= 360 {
                relativeAngle -= 360
            }
            
            self.qiblaAngle = relativeAngle
        } else {
            // If qibla not calculated yet, just show heading as angle
            self.qiblaAngle = heading
        }
    }
    
    /// Calculate bearing between two locations
    private func calculateBearing(from start: CLLocation, to end: CLLocation) -> Double {
        let lat1 = start.coordinate.latitude * .pi / 180
        let lat2 = end.coordinate.latitude * .pi / 180
        let lon1 = start.coordinate.longitude * .pi / 180
        let lon2 = end.coordinate.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    var formattedDirection: String {
        guard let direction = qiblaDirection else { return "Calculating..." }
        return formatBearing(direction)
    }
    
    private func formatBearing(_ bearing: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                         "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((bearing + 11.25) / 22.5) % 16
        return directions[index]
    }
}

