import SwiftUI
import SwiftData

@main
struct qiblaApp: App {
    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase // Détecte la mise en veille
    
    // On utilise "MainActor" pour garantir que le container est géré sur le thread principal
    @MainActor
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([PointOfInterest.self])
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
                        .transition(.opacity.combined(with: .scale(scale: 1.1)))
                        .zIndex(1)
                } else {
                    ContentView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        // Gérer le cycle de vie pour éviter les sauvegardes forcées instables
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // Ici, SwiftData sauvegarde automatiquement de manière sécurisée.
                // Ne force jamais de save() manuel ici avec "try!"
            }
        }
    }
}
