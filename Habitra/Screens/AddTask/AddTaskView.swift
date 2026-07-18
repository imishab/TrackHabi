import SwiftUI

struct AddTaskView: View {

    @State private var viewModel: AddTaskViewModel
    @Environment(\.dismiss) private var dismiss
    let onSave: (TaskItem) -> Void

    init(task: TaskItem? = nil, onSave: @escaping (TaskItem) -> Void) {
        _viewModel = State(initialValue: AddTaskViewModel(task: task))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("e.g. Submit expense report", text: $viewModel.title)
                }

                Section("Notes") {
                    TextField("Add a short note (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Priority") {
                    Picker("Priority", selection: $viewModel.priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $viewModel.isDueDateEnabled.animation())
                    if viewModel.isDueDateEnabled {
                        DatePicker("Due Date", selection: $viewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Task" : "New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let task = viewModel.save() {
                            onSave(task)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

#Preview {
    AddTaskView(onSave: { _ in })
}
