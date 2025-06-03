import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var taskVM: TaskViewModel

    @State private var newTaskTitle = ""
    @State private var newTaskDetails = ""

    // For editing existing task
    @State private var editingTask: Task?

    init(userId: String) {
        _taskVM = StateObject(wrappedValue: TaskViewModel(userId: userId))
    }

    var body: some View {
        VStack {
            Text("Қош келдіңіз, \(authVM.currentUser?.username ?? "User")!")
                .font(.title)
                .padding()

            TextField("Тапсырма атауы", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Тапсырма сипаттамасы", text: $newTaskDetails)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(editingTask == nil ? "Қосу" : "Сақтау") {
                if let task = editingTask {
                    taskVM.updateTask(task: task, newTitle: newTaskTitle, newDetails: newTaskDetails)
                    editingTask = nil
                } else {
                    taskVM.addTask(title: newTaskTitle, details: newTaskDetails)
                }
                newTaskTitle = ""
                newTaskDetails = ""
            }
            .padding()

            if editingTask != nil {
                Button("Болдырмау") {
                    editingTask = nil
                    newTaskTitle = ""
                    newTaskDetails = ""
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }

            List {
                ForEach(taskVM.tasks) { task in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(task.title)
                                .strikethrough(task.completed)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                taskVM.toggleTask(task)
                            }) {
                                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                            }
                        }

                        Text(task.details)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            Button("Өңдеу") {
                                editingTask = task
                                newTaskTitle = task.title
                                newTaskDetails = task.details
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: taskVM.deleteTask)  // Enable swipe to delete
            }

            if let error = taskVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Шығу") {
                authVM.signOut()
            }
            .padding()
        }
        .onAppear {
            taskVM.loadTasks()
        }
    }
}
