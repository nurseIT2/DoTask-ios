import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            TextField("Email", text: $authVM.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $authVM.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if authVM.isLoading {
                ProgressView()
            }

            if let error = authVM.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button("Login") {
                authVM.login { success in
                    if success {
                        // Навигация в ContentView произойдет автоматически,
                        // потому что AppState обновился
                    }
                }
            }
            .padding()
        }
    }
}
