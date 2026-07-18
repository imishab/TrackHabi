import Foundation

@Observable
@MainActor
final class AddTaskViewModel {

    var title: String
    var notes: String
    var priority: TaskPriority
    var isDueDateEnabled: Bool
    var dueDate: Date
    var error: Error?

    private let repository: TaskRepository
    private let editingID: UUID?
    private let createdAt: Date
    private let sortIndex: Int

    init(task: TaskItem? = nil, repository: TaskRepository? = nil) {
        self.repository = repository ?? TaskRepositoryImpl()
        self.editingID = task?.id
        self.createdAt = task?.createdAt ?? Date()
        self.sortIndex = task?.sortIndex ?? Int(Date().timeIntervalSince1970)
        self.title = task?.title ?? ""
        self.notes = task?.notes ?? ""
        self.priority = task?.priority ?? .medium
        self.isDueDateEnabled = task?.dueDate != nil
        self.dueDate = task?.dueDate ?? Date()
    }

    var isEditing: Bool { editingID != nil }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() -> TaskItem? {
        guard canSave else { return nil }
        let task = TaskItem(
            id: editingID ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            dueDate: isDueDateEnabled ? dueDate : nil,
            createdAt: createdAt,
            sortIndex: sortIndex
        )
        do {
            if isEditing {
                try repository.update(task)
            } else {
                try repository.add(task)
            }
            return task
        } catch {
            self.error = error
            return nil
        }
    }
}
