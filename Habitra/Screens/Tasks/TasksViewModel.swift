import Foundation

struct TaskSection: Identifiable {
    let id: String
    let title: String
    let tasks: [TaskItem]
}

@Observable
@MainActor
final class TasksViewModel {

    private(set) var tasks: [TaskItem] = []
    var error: Error?

    private let repository: TaskRepository
    private let calendar = Calendar.current

    init(repository: TaskRepository? = nil) {
        self.repository = repository ?? TaskRepositoryImpl()
    }

    var activeCount: Int {
        tasks.count { !$0.isCompleted }
    }

    var completedCount: Int {
        tasks.count { $0.isCompleted }
    }

    var todoSections: [TaskSection] {
        let active = tasks.filter { !$0.isCompleted }.sorted(by: TaskItem.displayOrder)

        let overdue = active.filter(\.isOverdue)
        let today = active.filter { $0.isDueToday && !$0.isOverdue }
        let upcoming = active.filter { $0.dueDate != nil && !$0.isDueToday && !$0.isOverdue }
        let noDueDate = active.filter { $0.dueDate == nil }

        var result: [TaskSection] = []
        if !overdue.isEmpty { result.append(TaskSection(id: "overdue", title: "Overdue", tasks: overdue)) }
        if !today.isEmpty { result.append(TaskSection(id: "today", title: "Today", tasks: today)) }
        if !upcoming.isEmpty { result.append(TaskSection(id: "upcoming", title: "Upcoming", tasks: upcoming)) }
        if !noDueDate.isEmpty { result.append(TaskSection(id: "noDueDate", title: "No Due Date", tasks: noDueDate)) }
        return result
    }

    var completedTasks: [TaskItem] {
        tasks
            .filter(\.isCompleted)
            .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
    }

    func load() {
        do {
            tasks = try repository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func toggle(_ task: TaskItem) {
        do {
            let isNowCompleted = try repository.toggleCompletion(id: task.id)
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index].isCompleted = isNowCompleted
                tasks[index].completedAt = isNowCompleted ? Date() : nil

                if isNowCompleted {
                    NotificationScheduler.shared.cancelDueReminder(for: task.id)
                } else {
                    NotificationScheduler.shared.scheduleDueReminder(for: tasks[index], username: UserProfileStore.shared.name)
                }
            }
        } catch {
            self.error = error
        }
    }

    func delete(_ task: TaskItem) {
        do {
            try repository.delete(id: task.id)
            tasks.removeAll { $0.id == task.id }
            NotificationScheduler.shared.cancelDueReminder(for: task.id)
        } catch {
            self.error = error
        }
    }
}
