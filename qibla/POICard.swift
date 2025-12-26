import SwiftUI;
import CoreLocation;

struct POICard: View {
    let poi: PointOfInterest
    let userLocation: CLLocation?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Check if icon is an emoji (usually 1 character) or an SF Symbol
            if poi.icon.count == 1 {
                Text(poi.icon)
                    .font(.title2)
            } else {
                Image(systemName: poi.icon)
                    .foregroundColor(poi.uiColor)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(poi.name)
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let userLoc = userLocation {
                    Text(poi.distance(from: userLoc))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(width: 130, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(poi.uiColor.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}
