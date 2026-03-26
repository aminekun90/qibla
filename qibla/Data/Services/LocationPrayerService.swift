import Foundation
import CoreLocation

class LocationPrayerService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationPrayerService()
    private let manager = CLLocationManager()
    private var completion: ((PrayerTimesResult?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // Précision ville suffisante
    }

    func update(completion: @escaping (PrayerTimesResult?) -> Void) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        manager.stopUpdatingLocation()
        
        let geo = CLGeocoder()
        geo.reverseGeocodeLocation(loc) { placemarks, _ in
            // Snapping : on utilise placemark.location (centre ville) si dispo
            let stableLoc = placemarks?.first?.location ?? loc
            let city = placemarks?.first?.locality ?? "Ma Position"
            
            let result = AstroEngine.shared.calculate(
                date: Date(),
                lat: stableLoc.coordinate.latitude,
                lon: stableLoc.coordinate.longitude,
                city: city
            )
            DispatchQueue.main.async { self.completion?(result) }
        }
    }
}
