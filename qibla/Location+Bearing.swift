import Foundation
import CoreLocation

// MARK: - Bearing between coordinates
public extension CLLocationCoordinate2D {
    /// Returns the initial bearing in degrees from this coordinate to the target coordinate.
    /// Range: 0°..<(360°), where 0° is North, 90° is East, etc.
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.radians
        let lon1 = self.longitude.radians
        let lat2 = destination.latitude.radians
        let lon2 = destination.longitude.radians

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearingRad = atan2(y, x)

        // Convert to degrees and normalize to 0..360
        var bearingDeg = bearingRad.degrees
        if bearingDeg < 0 { bearingDeg += 360 }
        return bearingDeg
    }
}

// MARK: - Convenience helpers
private extension Double {
    var radians: Double { self * .pi / 180 }
    var degrees: Double { self * 180 / .pi }
}

public extension CLLocationCoordinate2D {
    /// Returns the distance in meters to another coordinate using CoreLocation's Haversine implementation.
    func distance(to destination: CLLocationCoordinate2D) -> CLLocationDistance {
        let start = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let end = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return start.distance(from: end)
    }
}

public extension CLLocation {
    /// Convenience to get bearing from this location to another coordinate.
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        coordinate.bearing(to: destination)
    }
}
