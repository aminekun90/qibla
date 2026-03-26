//
//  Moonsighting.swift
//  qibla
//
//  Created by amine on 22/03/2026.
//


import Foundation

struct Moonsighting {
    static func fajrMinutes(date: Date, lat: Double) -> Double {
        let dyy = getDYY(date: date, lat: lat)
        let absLat = abs(lat)
        let a = 75 + 28.65 / 55 * absLat
        let b = 75 + 19.44 / 55 * absLat
        let c = 75 + 32.74 / 55 * absLat
        let d = 75 + 48.1 / 55 * absLat
        return interpolate(dyy: dyy, a: a, b: b, c: c, d: d)
    }
    
    static func ishaMinutes(date: Date, lat: Double) -> Double {
        let dyy = getDYY(date: date, lat: lat)
        let absLat = abs(lat)
        // Mode "General" de ton Python
        let a = 75 + 25.6 / 55.0 * absLat
        let b = 75 + 2.05 / 55.0 * absLat
        let c = 75 - 9.21 / 55.0 * absLat
        let d = 75 + 6.14 / 55.0 * absLat
        return interpolate(dyy: dyy, a: a, b: b, c: c, d: d)
    }

    private static func getDYY(date: Date, lat: Double) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = lat >= 0 ? 12 : 6
        let day = 21
        let dyyZero = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let diff = calendar.dateComponents([.day], from: dyyZero, to: date).day ?? 0
        return diff >= 0 ? diff : 365 + diff
    }

    private static func interpolate(dyy: Int, a: Double, b: Double, c: Double, d: Double) -> Double {
        let dy = Double(dyy)
        if dy < 91 { return a + (b - a) / 91 * dy }
        if dy < 137 { return b + (c - b) / 46 * (dy - 91) }
        if dy < 183 { return c + (d - c) / 46 * (dy - 137) }
        if dy < 229 { return d + (c - d) / 46 * (dy - 183) }
        if dy < 275 { return c + (b - c) / 46 * (dy - 229) }
        return b + (a - b) / 91 * (dy - 275)
    }
}
