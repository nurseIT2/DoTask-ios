import SwiftUI

struct RegisterView: View {
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

            TextField("Username", text: $vm.username)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if vm.isLoading {
                ProgressView()
            } else {
                Button("Register") {
                    vm.register { success in
                        if success {
                            // Регистрациядан кейін автоматты түрде логин экранына ауысу
                            appState.showLogin = true
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
