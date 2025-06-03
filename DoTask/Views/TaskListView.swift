import SwiftUI

struct TaskListView: View {
    @StateObject private var vm: TaskViewModel
    @State private var showingAddTask = false

    init(userId: String) {
        _vm = StateObject(wrappedValue: TaskViewModel(userId: userId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(vm.tasks) { task in
                        HStack {
                            Text(task.title)
                            Spacer()
                            if task.completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.toggleTask(task)
                        }
                    }
                    .onDelete(perform: vm.deleteTask)
                }
                .navigationTitle("Tasks")
                .navigationBarItems(trailing:
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                    }
                )

                if vm.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }

                if let error = vm.errorMessage {
                    VStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        Spacer()
                    }
                    .background(Color.white.opacity(0.8))
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(vm: vm)
            }
            .onAppear {
                vm.loadTasks()
            }
        }
    }
}
