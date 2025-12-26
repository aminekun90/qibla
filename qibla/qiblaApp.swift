import SwiftUI
import SwiftData

@main
struct qiblaApp: App {
    // State to control which screen is visible
    @State private var showSplash = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PointOfInterest.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity) // Smooth fade out
                } else {
                    ContentView()
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                }
            }
            .onAppear {
                // Adjust delay to your preference (2.0 seconds is standard)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}


