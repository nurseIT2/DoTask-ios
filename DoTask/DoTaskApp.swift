import SwiftUI
import Firebase

@main
struct DoTaskApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authVM: AuthViewModel

    init() {
        FirebaseApp.configure()
        let appStateInstance = AppState()
        _appState = StateObject(wrappedValue: appStateInstance)
        _authVM = StateObject(wrappedValue: AuthViewModel(appState: appStateInstance)) // ✅ дәл осы жол
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authVM)
        }
    }
}
