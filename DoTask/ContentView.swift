import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                if appState.isLoggedIn {
                    HomeView()
                } else {
                    if appState.showLogin {
                        LoginView()
                    } else {
                        RegisterView()
                    }
                }

                if !appState.isLoggedIn {
                    Button(appState.showLogin ? "No account? Register" : "Have an account? Login") {
                        appState.showLogin.toggle()
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("DoTask")
        }
    }
}
