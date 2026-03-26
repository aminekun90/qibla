//
//  SplashScreenView.swift
//  qibla
//
//  Created by amine on 29/12/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var animate = false
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            // Fond sombre avec un léger dégradé radial
            RadialGradient(colors: [Color(white: 0.15), .black], center: .center, startRadius: 2, endRadius: 500)
                .ignoresSafeArea()
            
            // Effet d'étoiles/particules en arrière-plan
            ForEach(0..<15) { i in
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...800)
                    )
                    .opacity(animate ? 0.8 : 0.2)
            }

            VStack(spacing: 30) {
                ZStack {
                    // Halo lumineux derrière l'emoji
                    Circle()
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: animate ? 30 : 20)
                        .scaleEffect(animate ? 1.2 : 0.8)
                    
                    // L'emoji Kaaba avec une ombre portée
                    Text("🕋")
                        .font(.system(size: 90))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                        .scaleEffect(animate ? 1.0 : 0.85)
                }
                
                VStack(spacing: 8) {
                    Text("QIBLA & ME")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .gray.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(10)
                    
                    // Petite barre de progression stylisée (juste visuelle)
                    Capsule()
                        .fill(LinearGradient(colors: [.clear, .yellow, .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(width: animate ? 150 : 0, height: 2)
                        .opacity(0.6)
                }
                .offset(y: animate ? 0 : 20)
                .opacity(animate ? 1.0 : 0.0)
            }
        }
        .onAppear {
            // Animation combinée : ressort pour l'entrée, respiration pour le loop
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                animate = true
            }
            
            // On peut aussi ajouter un battement continu très léger
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                // Si vous voulez que le halo pulse séparément
            }
        }
    }
}
