import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var vm: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Тіркелу")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $vm.email)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Құпиясөз", text: $vm.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Пайдаланушы аты", text: $vm.username)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if vm.isLoading {
                ProgressView()
            } else {
                Button("Тіркелу") {
                    vm.register { success in
                        if success {
                            appState.showLogin = true
                        }
                    }
                }
                .padding()
            }

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
        }
        .padding()
    }
}
