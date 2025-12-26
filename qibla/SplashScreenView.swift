//
//  SplashScreenView.swift
//  qibla
//
//  Created by amine on 29/12/2025.
//

import SwiftUI;

// MARK: - Splash Screen View
struct SplashScreenView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Match your app's background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // The Logo
                Image(systemName: "safari.fill") // You can use "location.north.circle.fill" too
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .scaleEffect(animate ? 1.0 : 0.8)
                
                Text("QIBLA & POI")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(8)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
