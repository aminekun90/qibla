//
//  MainTabView.swift
//  qibla
//
//  Created by amine on 21/03/2026.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: AppTab = .adhan
    @Environment(\.colorScheme) var colorScheme // Détecte le thème global (Light/Dark)
    
    var body: some View {
        ZStack {
            // --- FOND CENTRALISÉ ---
            // Ce fond est rendu une seule fois et s'applique sous la TabView
            Group {
                if colorScheme == .dark {
                    LinearGradient(colors: [Color(white: 0.15), .black], startPoint: .top, endPoint: .bottom)
                } else {
                    LinearGradient(colors: [Color(white: 0.98), Color(white: 0.90)], startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()

            // --- NAVIGATION PRINCIPALE ---
            TabView(selection: $selectedTab) {
                
                // 1. Onglet Qibla
                NavigationStack {
                    CompassView()
                }
                .tabItem {
                    Label(AppTab.qibla.title, systemImage: AppTab.qibla.rawValue)
                }
                .tag(AppTab.qibla)
                
                // 2. Onglet Adhan
                NavigationStack {
                    AdhanView()
                }
                .tabItem {
                    Label(AppTab.adhan.title, systemImage: AppTab.adhan.rawValue)
                }
                .tag(AppTab.adhan)
                
                // 3. Onglet Calendrier
                NavigationStack {
                    VStack(spacing: 20) {
                        Image(systemName: AppTab.calendar.rawValue)
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("Calendrier Hijri à venir")
                            .font(.headline)
                    }
                    .navigationTitle(AppTab.calendar.title)
                }
                .tabItem {
                    Label(AppTab.calendar.title, systemImage: AppTab.calendar.rawValue)
                }
                .tag(AppTab.calendar)
            }
        }
        // Harmonisation de la couleur des icônes de la TabBar
        .tint(colorScheme == .dark ? .yellow : .orange)
        .onAppear {
            // Force la TabBar à être transparente pour voir notre dégradé derrière
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Previews
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PointOfInterest.self, configurations: config)
    
    return MainTabView()
        .modelContainer(container)
}
