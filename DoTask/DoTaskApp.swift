import SwiftUI
import Firebase

@main
struct DoTaskApp: App {
    @StateObject var appState = AppState()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
