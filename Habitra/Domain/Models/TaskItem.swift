import Foundation

struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var priority: TaskPriority
    var dueDate: Date?
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var sortIndex: Int

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        sortIndex: Int = Int(Date().timeIntervalSince1970)
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.sortIndex = sortIndex
    }

    var isOverdue: Bool {
        guard !isCompleted, let dueDate else { return false }
        return Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    static func displayOrder(_ lhs: TaskItem, _ rhs: TaskItem) -> Bool {
        if lhs.sortIndex != rhs.sortIndex {
            return lhs.sortIndex < rhs.sortIndex
        }
        return lhs.createdAt < rhs.createdAt
    }
}
