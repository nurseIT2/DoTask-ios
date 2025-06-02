import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var showLogin = true
}
