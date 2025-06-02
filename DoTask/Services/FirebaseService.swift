import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Database.database().reference()
    
    func register(email: String, password: String, username: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "", code: 999, userInfo: [NSLocalizedDescriptionKey: "No user"])))
                return
            }

            let userData = ["email": email, "username": username]
            self.db.child("users").child(user.uid).setValue(userData)
            
            let newUser = User(uid: user.uid, email: email, username: username)
            completion(.success(newUser))
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "", code: 999, userInfo: [NSLocalizedDescriptionKey: "No user"])))
                return
            }

            self.db.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot in
                guard let dict = snapshot.value as? [String: Any],
                      let username = dict["username"] as? String else {
                    completion(.failure(NSError(domain: "", code: 999, userInfo: [NSLocalizedDescriptionKey: "User data missing"])))
                    return
                }

                let loggedInUser = User(uid: user.uid, email: email, username: username)
                completion(.success(loggedInUser))
            }
        }
    }
}
