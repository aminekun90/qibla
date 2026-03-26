//
//  PrayerRow.swift
//  qibla
//
//  Created by amine on 22/03/2026.
//

import SwiftUI
struct PrayerRow: View {
    let name: String
    let time: Date
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.appGold)
                .frame(width: 30)
            Text(name)
                .font(.system(.headline, design: .serif))
                .foregroundColor(.white)
            Spacer()
            Text(time.formatted(date: .omitted, time: .shortened))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
    }
}
