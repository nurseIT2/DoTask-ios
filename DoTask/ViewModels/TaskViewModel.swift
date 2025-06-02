import Foundation
import FirebaseDatabase

class TaskViewModel: ObservableObject {
    @Published var tasks = [Task]()
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var userId: String
    private var databaseRef: DatabaseReference

    init(userId: String) {
        self.userId = userId
        self.databaseRef = Database.database().reference().child("tasks").child(userId)
        loadTasks()
    }

    func loadTasks() {
            isLoading = true // Начинаем загрузку
            databaseRef.observe(.value) { snapshot in
                var tempTasks = [Task]()
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any],
                       let task = Task(snapshot: dict, id: snap.key) {
                        tempTasks.append(task)
                    }
                }
                DispatchQueue.main.async {
                    self.tasks = tempTasks
                    self.isLoading = false // Загрузка завершена
                }
            }
        }

    func addTask(title: String, details: String) {
        let newTask = Task(title: title, details: details)
        let taskRef = databaseRef.child(newTask.id)
        taskRef.setValue(newTask.toDictionary()) { error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasks[index]
            databaseRef.child(task.id).removeValue { error, _ in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func toggleTask(_ task: Task) {
        let updatedTask = Task(id: task.id, title: task.title, details: task.details, completed: !task.completed)
        databaseRef.child(task.id).setValue(updatedTask.toDictionary()) { error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func updateTask(task: Task, newTitle: String, newDetails: String) {
        let updatedTask = Task(id: task.id, title: newTitle, details: newDetails, completed: task.completed)
        databaseRef.child(task.id).setValue(updatedTask.toDictionary()) { error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
