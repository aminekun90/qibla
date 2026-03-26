//
//  CompassStyle.swift
//  qibla
//
//  Created by amine on 29/12/2025.
//


enum CompassStyle: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case minimal = "Minimal"
    case tactical = "Tactical"
    case glass = "Glass"
    
    var id: String { self.rawValue }
}
