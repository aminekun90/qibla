import SwiftUI

struct POINeedle: View {
    let poi: PointOfInterest
    let currentHeading: Double
    let bearing: Double
    var distanceText: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                // Distance Label
                if let dist = distanceText {
                    Text(dist)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(poi.uiColor.opacity(0.8))
                        .clipShape(Capsule())
                }
                
                // Icon Logic: Emoji vs SF Symbol
                if poi.icon.count == 1 {
                    Text(poi.icon)
                        .font(.system(size: 30))
                        .shadow(radius: 3)
                } else {
                    Image(systemName: poi.isQibla ? "arrow.up.circle.fill" : poi.icon)
                        .font(.system(size: poi.isQibla ? 32 : 24))
                        .foregroundColor(poi.uiColor)
                        .shadow(color: poi.uiColor.opacity(0.6), radius: 8)
                }
                
                // Small indicator tip
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 10, height: 8)
                    .foregroundColor(poi.uiColor)
                    .rotationEffect(.degrees(180))
            }
            .offset(y: -20)
            
            Spacer()
            
            Circle()
                .fill(poi.uiColor.opacity(0.3))
                .frame(width: 4, height: 4)
        }
        .frame(width: 300, height: 280)
        .rotationEffect(.degrees(bearing - currentHeading))
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7), value: currentHeading)
    }
}
