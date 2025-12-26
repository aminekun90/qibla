import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var compass = CompassManager()
    @Environment(\.modelContext) private var modelContext
    
    // Fetches saved points, excluding the permanent Qibla to avoid duplicates
    @Query(sort: \PointOfInterest.name) private var points: [PointOfInterest]
    
    // State for Sheets and UI toggles
    @State private var showingAddSheet = false
    @State private var showingDesignSheet = false
    @State private var poiToEdit: PointOfInterest?

    // Permanent Qibla Reference
    private let permanentQibla = PointOfInterest.qiblaDefault;

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Dark Premium Background
                LinearGradient(colors: [Color(white: 0.15), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    statusHeader
                    
                    Spacer()
                    
                    // 2. The Main Compass Area
                    ZStack {
                        CompassDialView()
                            .rotationEffect(.degrees(-compass.heading))
                            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: compass.heading)
                        
                        // A. Permanent Qibla Needle
                        if let userLoc = compass.lastLocation {
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
                    
                    // 3. Bottom Horizontal List
                    bottomPOIBar
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("QIBLA & POI").foregroundColor(.white).tracking(2).bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingDesignSheet.toggle() } label: {
                        Image(systemName: "paintpalette.fill").foregroundColor(.white).font(.subheadline)
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
    }
    
    // MARK: - Subviews
    
    private var centerDisplay: some View {
        VStack(spacing: 0) {
            Text("\(Int(compass.heading))°")
                .font(.system(size: 54, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
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
            
            Text(compass.lastLocation == nil ? "SEARCHING GPS..." : "GPS ACTIVE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05))
        .clipShape(Capsule())
        .padding(.top, 10)
    }

    private var bottomPOIBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Add New Button
                Button { showingAddSheet.toggle() } label: {
                    AddButton()
                }
                
                // PERMANENT QIBLA CARD (No context menu = No delete/edit)
                POICard(poi: permanentQibla, userLocation: compass.lastLocation)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                    )
                
                // Saved User POI Cards
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
