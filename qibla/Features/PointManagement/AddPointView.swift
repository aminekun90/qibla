//
//  AddPointView.swift
//  qibla
//
//  Created by amine on 26/12/2025.
//


import SwiftUI
import SwiftData
import CoreLocation
struct AddPointView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // The POI to edit (nil if creating a new one)
    var poiToEdit: PointOfInterest?
    
    @StateObject private var locationManager = CompassManager()
    
    @State private var name = ""
    @State private var lat = ""
    @State private var lon = ""
    @State private var selectedColor = Color.blue
    @State private var selectedIcon = "🕋"
    
    let icons = ["🕋", "📍", "🏠", "🏢", "🌳", "⭐", "❤️", "mappin.and.ellipse"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Location Details") {
                    TextField("Point Name", text: $name)
                    HStack {
                        VStack {
                            TextField("Latitude", text: $lat)
                            TextField("Longitude", text: $lon)
                        }
                        .keyboardType(.decimalPad)
                        
                        Button {
                            if let loc = locationManager.lastLocation {
                                lat = String(format: "%.6f", loc.coordinate.latitude)
                                lon = String(format: "%.6f", loc.coordinate.longitude)
                            }
                        } label: {
                            Image(systemName: "location.circle.fill").font(.title)
                        }
                    }
                }
                
                Section("Personalize Arrow") {
                    ColorPicker("Arrow Color", selection: $selectedColor)
                    Picker("Icon", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            if icon.count == 1 { Text(icon).tag(icon) }
                            else { Image(systemName: icon).tag(icon) }
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(poiToEdit == nil ? "Add Point" : "Edit Point")
            .onAppear {
                // Pre-fill data if editing
                if let poi = poiToEdit {
                    name = poi.name
                    lat = String(poi.latitude)
                    lon = String(poi.longitude)
                    selectedColor = poi.uiColor
                    selectedIcon = poi.icon
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePoint()
                        dismiss()
                    }
                    .disabled(name.isEmpty || lat.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func savePoint() {
        let hex = selectedColor.toHex() ?? "#007AFF"
        
        if let poi = poiToEdit {
            // Update existing
            poi.name = name
            poi.latitude = Double(lat) ?? 0
            poi.longitude = Double(lon) ?? 0
            poi.colorHex = hex
            poi.icon = selectedIcon
            poi.isQibla = selectedIcon == "🕋"
        } else {
            // Create new
            let newPoint = PointOfInterest(
                name: name,
                latitude: Double(lat) ?? 0,
                longitude: Double(lon) ?? 0,
                colorHex: hex,
                icon: selectedIcon,
                isQibla: selectedIcon == "🕋"
            )
            modelContext.insert(newPoint)
        }
    }
}
