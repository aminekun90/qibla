import SwiftUI
import SwiftData
import CoreLocation

struct CompassView: View {
    // MARK: - Properties
    @StateObject private var compass = CompassManager()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query(sort: \PointOfInterest.name) private var points: [PointOfInterest]
    
    @State private var showingAddSheet = false
    @State private var showingDesignSheet = false
    @State private var poiToEdit: PointOfInterest?

    private let permanentQibla = PointOfInterest.qiblaDefault

    var body: some View {
        ZStack {
           
            
            VStack {
                statusHeader
                
                Spacer()
                
                // MARK: - Main Compass Area
                ZStack {
                    CompassDialView()
                        .rotationEffect(.degrees(-compass.heading))
                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: compass.heading)
                    
                    if let userLoc = compass.lastLocation {
                        // A. Permanent Qibla Needle
                        let qiblaBearing = userLoc.coordinate.bearing(to: permanentQibla.coordinate)
                        POINeedle(
                            poi: permanentQibla,
                            currentHeading: compass.heading,
                            bearing: qiblaBearing,
                            distanceText: permanentQibla.name
                        )
                    }

                    // B. Dynamic User Needles
                    ForEach(points) { poi in
                        if let userLoc = compass.lastLocation {
                            let bearing = userLoc.coordinate.bearing(to: poi.coordinate)
                            POINeedle(
                                poi: poi,
                                currentHeading: compass.heading,
                                bearing: bearing,
                                distanceText: poi.name
                            )
                        }
                    }
                    
                    centerDisplay
                }
                .frame(width: 300, height: 300)
                
                Spacer()
                
                // MARK: - Bottom Bar
                bottomPOIBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("QIBLA & ME")
                    .font(.headline)
                    .tracking(2)
                    .foregroundColor(.primary) // S'adapte auto (Noir ou Blanc)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingDesignSheet.toggle() } label: {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showingDesignSheet) {
            DesignPickerView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingAddSheet) {
            AddPointView()
        }
        .sheet(item: $poiToEdit) { poi in
            AddPointView(poiToEdit: poi)
        }
    }
    
    // MARK: - Subviews
    
    private var centerDisplay: some View {
        VStack(spacing: 0) {
            Text("\(Int(compass.heading))°")
                .font(.system(size: 54, weight: .thin, design: .monospaced))
                .foregroundColor(.primary)
            Text("NORTH")
                .font(.system(size: 12, weight: .bold))
                .tracking(4)
                .foregroundColor(.red)
        }
    }

    private var statusHeader: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(compass.lastLocation == nil ? Color.red : Color.green)
                .frame(width: 8, height: 8)
            
            Text(compass.lastLocation == nil ? "SEARCHING GPS..." : "GPS ENABLED")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial) // Effet de flou premium qui s'adapte au fond
        .clipShape(Capsule())
        .padding(.top, 10)
    }

    private var bottomPOIBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Button { showingAddSheet.toggle() } label: {
                    AddButton()
                }
                
                POICard(poi: permanentQibla, userLocation: compass.lastLocation)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                    )
                
                ForEach(points) { poi in
                    POICard(poi: poi, userLocation: compass.lastLocation)
                        .contextMenu {
                            Button { poiToEdit = poi } label: {
                                Label("Edit Details", systemImage: "pencil")
                            }
                            Divider()
                            Button(role: .destructive) { modelContext.delete(poi) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PointOfInterest.self, configurations: config)
    return CompassView()
        .modelContainer(container)
}
