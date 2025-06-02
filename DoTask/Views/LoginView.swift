import SwiftUI

struct LoginView: View {
    @StateObject private var vm = AuthViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $vm.email)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $vm.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if vm.isLoading {
                ProgressView()
            } else {
                Button("Login") {
                    vm.login { success in
                        if success {
                            // Логин сәтті өтіп, басты бетке өту
                            appState.isLoggedIn = true
                        }
                    }
                }
                .padding()
            }

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
