

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Database.database().reference()
    
    // MARK: - Auth
    
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
    
    // MARK: - Tasks CRUD
    
    private func tasksRef(for userId: String) -> DatabaseReference {
        db.child("tasks").child(userId)
    }
    
    func addTask(_ task: Task, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        tasksRef(for: userId).child(task.id).setValue(task.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchTasks(for userId: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        tasksRef(for: userId).observeSingleEvent(of: .value) { snapshot in
            var tasks: [Task] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let title = dict["title"] as? String,
                   let details = dict["details"] as? String,
                   let completed = dict["completed"] as? Bool,
                   let id = dict["id"] as? String {
                    let task = Task(id: id, title: title, details: details, completed: completed)
                    tasks.append(task)
                }
            }
            completion(.success(tasks))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    func updateTask(_ task: Task, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        tasksRef(for: userId).child(task.id).updateChildValues(task.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteTask(id: String, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        tasksRef(for: userId).child(id).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
