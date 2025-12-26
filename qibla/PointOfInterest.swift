import Foundation
import SwiftData
import CoreLocation
import SwiftUI

@Model
final class PointOfInterest {
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var colorHex: String
    var icon: String
    var isQibla: Bool
    
    init(name: String, latitude: Double, longitude: Double, colorHex: String = "#FFD700", icon: String = "location.fill", isQibla: Bool = false) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.colorHex = colorHex
        self.icon = icon
        self.isQibla = isQibla
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var uiColor: Color {
        Color(hex: colorHex) ?? .blue
    }
    func distance(from userLocation: CLLocation) -> String {
        let dest = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = userLocation.distance(from: dest)
        
        if distanceInMeters > 1000 {
            return String(format: "%.1f km", distanceInMeters / 1000)
        } else {
            return "\(Int(distanceInMeters)) m"
        }
    }
}
extension PointOfInterest {
    static var qiblaDefault: PointOfInterest {
        PointOfInterest(
            name: "Qibla",
            latitude: 21.42248,
            longitude: 39.82621,
            colorHex: "#FFD700", // Gold
            icon: "🕋",
            isQibla: true
        )
    }
}
