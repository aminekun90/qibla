import Foundation


struct PrayerTimesResult {
    let imsak: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let sunset: Date
    let maghrib: Date
    let isha: Date
    let midnight: Date
    let firstThird: Date
    let lastThird: Date
    let city: String
    let latitude: Double
    let longitude: Double
}

class AstroEngine {
    static let shared = AstroEngine()
    
    // Configuration des méthodes calquée sur Python
    enum PrayerMethod: String {
        case mwl, isna, egypt, makkah, france, moonsighting
        
        var config: (fajr: Double, isha: Double?, ishaMins: Double?) {
            switch self {
            case .mwl: return (18.0, 17.0, nil)
            case .isna: return (15.0, 15.0, nil)
            case .egypt: return (19.5, 17.5, nil)
            case .makkah: return (18.5, nil, 90.0)
            case .france: return (12.0, 12.0, nil)
            case .moonsighting: return (0, 0, nil) // Logique spéciale
            }
        }
    }

    var method: PrayerMethod = .france
    var madhabFactor: Double = 1.0 // 1.0 = Shafi, 2.0 = Hanafi

    // MARK: - Core Computation
    func calculate(date: Date, lat: Double, lon: Double, city: String) -> PrayerTimesResult? {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let y = components.year, let m = components.month, let d = components.day else { return nil }
        
        let latRad = lat * .pi / 180.0
        let jd0 = julianDay(y: y, m: m, d: d)
        
        // Position du soleil à midi (Equation of time & Declination)
        let (_, eqtMin) = sunPosition(jd: jd0)
        let noonUtc = 720.0 - (4.0 * lon) - eqtMin
        
        // 1. Sunrise / Sunset (Zenith 90.8333)
        let sunriseUtc = refineAngle(latRad: latRad, jd0: jd0, noonUtc: noonUtc, zenith: 90.8333, direction: -1) ?? (noonUtc - 360)
        let sunsetUtc = refineAngle(latRad: latRad, jd0: jd0, noonUtc: noonUtc, zenith: 90.8333, direction: 1) ?? (noonUtc + 360)
        
        // 2. Dhuhr & Asr
        let dhuhrUtc = noonUtc
        let asrUtc = computeAsr(latRad: latRad, jd0: jd0, noonUtc: noonUtc) ?? (noonUtc + 150)
        
        // 3. Fajr & Isha
        var fajrUtc: Double = 0
        var ishaUtc: Double = 0
        
        if method == .moonsighting {
            let msFajr = Moonsighting.fajrMinutes(date: date, lat: lat)
            let msIsha = Moonsighting.ishaMinutes(date: date, lat: lat)
            fajrUtc = sunriseUtc - msFajr
            ishaUtc = sunsetUtc + msIsha
        } else {
            let config = method.config
            fajrUtc = refineAngle(latRad: latRad, jd0: jd0, noonUtc: noonUtc, zenith: 90.0 + config.fajr, direction: -1) ?? (sunriseUtc - 60)
            
            if let ishaAngle = config.isha {
                ishaUtc = refineAngle(latRad: latRad, jd0: jd0, noonUtc: noonUtc, zenith: 90.0 + ishaAngle, direction: 1) ?? (sunsetUtc + 60)
            } else if let ishaMins = config.ishaMins {
                ishaUtc = sunsetUtc + ishaMins
            }
        }
        
        // 4. Offsets spécifiques (France: +15 min Fajr/Isha)
        if method == .france {
            fajrUtc += 15
            ishaUtc += 15
        }
        
        // Conversion en Dates
        let times = PrayerTimesResult(
            imsak: dateFromUtc(fajrUtc - 10, base: date),
            fajr: dateFromUtc(fajrUtc, base: date),
            sunrise: dateFromUtc(sunriseUtc, base: date),
            dhuhr: dateFromUtc(dhuhrUtc, base: date),
            asr: dateFromUtc(asrUtc, base: date),
            sunset: dateFromUtc(sunsetUtc, base: date),
            maghrib: dateFromUtc(sunsetUtc, base: date),
            isha: dateFromUtc(ishaUtc, base: date),
            midnight: dateFromUtc(sunsetUtc, base: date).addingTimeInterval(dateFromUtc(sunriseUtc, base: date.addingTimeInterval(86400)).timeIntervalSince(dateFromUtc(sunsetUtc, base: date)) / 2),
            firstThird: Date(), // Calculés ci-dessous pour plus de clarté
            lastThird: Date(),
            city: city, latitude: lat, longitude: lon
        )
        
        return finalizeExtras(times)
    }

    // MARK: - Helpers Mathématiques (Refined)
    private func julianDay(y: Int, m: Int, d: Int) -> Double {
        var yy = y, mm = m
        if mm <= 2 { yy -= 1; mm += 12 }
        let a = yy / 100
        let b = 2 - a + a / 4
        return floor(365.25 * Double(yy + 4716)) + floor(30.6001 * Double(mm + 1)) + Double(d) + Double(b) - 1524.5
    }
    
    private func sunPosition(jd: Double) -> (dec: Double, eqt: Double) {
        let d = jd - 2451545.0
        let g = (357.529 + 0.98560028 * d).truncatingRemainder(dividingBy: 360.0) * .pi / 180.0
        let q = (280.459 + 0.98564736 * d).truncatingRemainder(dividingBy: 360.0)
        let l = (q + 1.915 * sin(g) + 0.020 * sin(2.0 * g)).truncatingRemainder(dividingBy: 360.0) * .pi / 180.0
        let e = (23.439 - 0.00000036 * d) * .pi / 180.0
        var ra = atan2(cos(e) * sin(l), cos(l)) * 180.0 / .pi
        ra = (ra + 360.0).truncatingRemainder(dividingBy: 360.0)
        let dec = asin(sin(e) * sin(l))
        var eqt = q / 15.0 - ra / 15.0
        if eqt > 12 { eqt -= 24 }; if eqt < -12 { eqt += 24 }
        return (dec, eqt * 60.0)
    }

    private func refineAngle(latRad: Double, jd0: Double, noonUtc: Double, zenith: Double, direction: Double) -> Double? {
        let (dec0, _) = sunPosition(jd: jd0)
        let zRad = zenith * .pi / 180.0
        let cosH = (cos(zRad) - sin(latRad) * sin(dec0)) / (cos(latRad) * cos(dec0))
        if cosH < -1 || cosH > 1 { return nil }
        var t = noonUtc + (acos(cosH) * 180.0 / .pi) * 4.0 * direction
        
        // Iteration (jd_try dans ton code Python)
        let (decTry, _) = sunPosition(jd: jd0 + t/1440.0)
        let cosH2 = (cos(zRad) - sin(latRad) * sin(decTry)) / (cos(latRad) * cos(decTry))
        if cosH2 >= -1 && cosH2 <= 1 {
            t = noonUtc + (acos(cosH2) * 180.0 / .pi) * 4.0 * direction
        }
        return t
    }

    private func computeAsr(latRad: Double, jd0: Double, noonUtc: Double) -> Double? {
        let (dec, _) = sunPosition(jd: jd0 + noonUtc/1440.0)
        let alt = atan(1.0 / (madhabFactor + tan(abs(latRad - dec))))
        let cosH = (sin(alt) - sin(latRad) * sin(dec)) / (cos(latRad) * cos(dec))
        if cosH < -1 || cosH > 1 { return nil }
        return noonUtc + (acos(cosH) * 180.0 / .pi) * 4.0
    }

    private func dateFromUtc(_ minutes: Double, base: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: base)
        components.hour = 0; components.minute = 0; components.second = 0
        return calendar.date(from: components)!.addingTimeInterval(minutes * 60)
    }

    private func finalizeExtras(_ t: PrayerTimesResult) -> PrayerTimesResult {
        let nightDuration = t.fajr.timeIntervalSince(t.sunset)
        return PrayerTimesResult(
            imsak: t.imsak, fajr: t.fajr, sunrise: t.sunrise, dhuhr: t.dhuhr, asr: t.asr,
            sunset: t.sunset, maghrib: t.maghrib, isha: t.isha,
            midnight: t.sunset.addingTimeInterval(nightDuration / 2),
            firstThird: t.sunset.addingTimeInterval(nightDuration / 3),
            lastThird: t.sunset.addingTimeInterval(2 * nightDuration / 3),
            city: t.city, latitude: t.latitude, longitude: t.longitude
        )
    }
}
