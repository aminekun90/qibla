//
//  AppTab.swift
//  qibla
//
//  Created by amine on 21/03/2026.
//

enum AppTab: String, CaseIterable {
    case qibla = "location.viewfinder"
    case adhan = "clock.fill"
    case quran = "book.fill"
    case calendar = "calendar"
    
    var title: String {
        switch self {
        case .qibla: return "Qibla"
        case .adhan: return "Adhan"
        case .quran: return "Coran"
        case .calendar: return "Calendrier"
        }
    }
}
