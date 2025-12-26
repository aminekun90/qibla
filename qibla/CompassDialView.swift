//
//  CompassDialView.swift
//  qibla
//
//  Created by amine on 26/12/2025.
//

import SwiftUI
import UIKit



struct CompassDialView: View {
    // This allows the view to react to the selected style saved in AppStorage
    @AppStorage("selectedCompassStyle") private var selectedStyle: CompassStyle = .classic
    
    var body: some View {
        ZStack {
            switch selectedStyle {
            case .classic:
                classicDesign
            case .minimal:
                minimalDesign
            case .tactical:
                tacticalDesign
            case .glass:
                glassDesign
            }
        }
        .frame(width: 300, height: 300)
    }
    
    // MARK: - Design: Classic
    private var classicDesign: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                .frame(width: 280, height: 280)
            
            ForEach(0..<72, id: \.self) { i in
                let isMajor = i % 9 == 0
                Rectangle()
                    .fill(isMajor ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 15 : 7)
                    .offset(y: -130)
                    .rotationEffect(.degrees(Double(i) * 5))
            }
            
            cardinalLetters(offset: -110)
        }
    }
    
    // MARK: - Design: Minimal
    private var minimalDesign: some View {
        ZStack {
            // Clean outer ring
            Circle()
                .stroke(
                    AngularGradient(colors: [.red, .white.opacity(0.1), .white.opacity(0.1), .red], center: .center),
                    lineWidth: 1
                )
            
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(i == 0 ? Color.red : Color.white)
                    .frame(width: 2, height: 20)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            
            cardinalLetters(offset: -105, font: .system(size: 24, weight: .black, design: .monospaced))
        }
    }
    
    // MARK: - Design: Tactical
    private var tacticalDesign: some View {
        ZStack {
            Circle().stroke(Color.green.opacity(0.3), lineWidth: 1)
            
            // Subtle Grid
            Circle().stroke(Color.green.opacity(0.1), lineWidth: 1).frame(width: 200)
            
            ForEach(0..<120, id: \.self) { i in
                let isTen = i % 10 == 0
                Rectangle()
                    .fill(Color.green.opacity(isTen ? 0.8 : 0.3))
                    .frame(width: 1, height: isTen ? 12 : 5)
                    .offset(y: -138)
                    .rotationEffect(.degrees(Double(i) * 3))
            }
            
            cardinalLetters(offset: -115, color: .green)
        }
    }
    
    // MARK: - Design: Glass
    private var glassDesign: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
            
            classicDesign.opacity(0.6)
        }
    }
    
    // MARK: - Reusable Cardinal Directions
    private func cardinalLetters(offset: CGFloat, font: Font = .system(size: 16, weight: .bold, design: .rounded), color: Color? = nil) -> some View {
        Group {
            Text("N").modifier(CardinalStyle(at: 0, offset: offset, color: color ?? .red, font: font))
            Text("E").modifier(CardinalStyle(at: 90, offset: offset, color: color ?? .white, font: font))
            Text("S").modifier(CardinalStyle(at: 180, offset: offset, color: color ?? .white, font: font))
            Text("W").modifier(CardinalStyle(at: 270, offset: offset, color: color ?? .white, font: font))
        }
    }
}

// MARK: - Helper Components

struct CardinalStyle: ViewModifier {
    let at: Double
    let offset: CGFloat
    var color: Color
    var font: Font
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .offset(y: offset)
            .rotationEffect(.degrees(at))
    }
}

struct AddButton: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
            Text("Add Point")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 120, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }
}

// MARK: - Color Extensions

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "%02X%02X%02X",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }
    
    static let gold = Color(hex: "#FFD700")!
}
