import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    private var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func login(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email мен құпиясөзді енгізіңіз"
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        FirebaseService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.appState.isLoggedIn = true
                    self.appState.currentUserId = user.uid
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func register(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Барлық өрістерді толтырыңыз"
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        FirebaseService.shared.register(email: email, password: password, username: username) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.appState.isLoggedIn = true
                    self.appState.currentUserId = user.uid
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            appState.isLoggedIn = false
            appState.currentUserId = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
