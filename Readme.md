# 🧭 Qibla & POI Compass

A professional-grade, high-precision compass application for iOS. Built using **SwiftUI**, **SwiftData**, and **CoreLocation**, this app allows users to find the Qibla (Kaaba) direction and manage custom Points of Interest (POI) with a premium, customizable interface.

## ✨ Key Features

* **Fixed Qibla Reference:** A hardcoded, non-deletable indicator for the Kaaba ($21.42248^\circ$ N, $39.82621^\circ$ E) that remains active regardless of user data.
* **Dynamic POI Management:** Full CRUD (Create, Read, Update, Delete) capabilities for custom locations using **SwiftData**.
* **Theme Engine:** Four distinct compass dial designs (Classic, Minimal, Tactical, and Glass) switchable via a native half-sheet picker.
* **Hybrid Icon Support:** Use professional **SF Symbols** or any **Emoji** to represent your saved locations.
* **Real-Time Math:** Precise bearing calculations using spherical trigonometry to account for the Earth's curvature.
* **True North Calibration:** Automatically switches between Magnetic and True North for higher accuracy.

## 🛠 Technical Architecture

### 1. Navigation & Bearing Logic

The app uses the **Haversine formula** to determine the exact angle (bearing) from the user's current GPS coordinates to a target POI.

```swift
// Formula used for bearing calculation
let y = sin(dLon) * cos(lat2)
let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
let bearing = atan2(y, x)
```

### 2. Data Persistence

Leverages SwiftData for lightweight, high-performance local storage. Custom POIs are synced with the UI automatically using the @Query macro.

### 3. Sensor Management

A CompassManager class (ObservableObject) bridges CoreLocation with SwiftUI, handling:

Location Authorization requests.

GPS coordinate updates.

Hardware Magnetometer heading (CLHeading).

### 🎨 UI & Design

Glassmorphism: Suble blurs and thin strokes provide a modern Apple-style aesthetic.

Interactive Spring Animations: Needles and dials use interactiveSpring to mimic the physical weight of a real compass needle.

Context Menus: Long-press any POI card to edit or delete it instantly.

### 🚀 Getting Started

Prerequisites

* iOS 17.0+
* Xcode 15.0+
* Physical iPhone: A real device is required to use the Magnetometer (the compass will not rotate in the Simulator).
* Permissions
* Ensure your Info.plist includes the following key:

```txt
NSLocationWhenInUseUsageDescription: "This app requires your location to calculate the direction and distance to the Qibla and your saved points."
```

### 📂 Project Structure

qiblaApp.swift: App entry point & SwiftData container setup.

ContentView.swift: Main UI assembly and needle logic.

CompassManager.swift: Hardware sensor and location delegate.

PointOfInterest.swift: SwiftData Model and coordinate extensions.

CompassDialView.swift: Modular dial designs and theme styles.

DesignPickerView.swift: Theme selection interface.

### 📜 License

This project is available under the MIT License.
