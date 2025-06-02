import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: TaskViewModel
    @State private var title = ""
    @State private var details = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Task title", text: $title)
                }
                Section("Details") {
                    TextField("Details", text: $details)
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.addTask(title: title, details: details)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
