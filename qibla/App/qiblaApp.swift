import SwiftUI
import SwiftData

@main
struct qiblaApp: App {
    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase
    
    // Le ModelContainer est configuré pour PointOfInterest
    @MainActor
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([PointOfInterest.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Erreur lors de la création du ModelContainer : \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity.combined(with: .scale(scale: 1.1)))
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: showSplash)
            .onAppear {
                // Délai du Splash Screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    showSplash = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PointOfInterest.self, configurations: config)
    
    return Group {
        // On peut tester l'état "App" global ici
        SplashScreenView()
    }
    .modelContainer(container)
}
