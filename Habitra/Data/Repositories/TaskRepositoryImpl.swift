import CoreData
import Foundation

@MainActor
final class TaskRepositoryImpl: TaskRepository {

    private let context: NSManagedObjectContext

    init(controller: PersistenceController = .shared) {
        self.context = controller.container.viewContext
    }

    func fetchAll() throws -> [TaskItem] {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "sortIndex", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        return try context.fetch(request).map { $0.toDomain() }
    }

    func add(_ task: TaskItem) throws {
        let entity = TaskEntity(context: context)
        entity.apply(task)
        try saveIfNeeded()
    }

    func update(_ task: TaskItem) throws {
        guard let entity = try fetchTaskEntity(id: task.id) else { return }
        entity.apply(task)
        try saveIfNeeded()
    }

    func delete(id: UUID) throws {
        guard let entity = try fetchTaskEntity(id: id) else { return }
        context.delete(entity)
        try saveIfNeeded()
    }

    @discardableResult
    func toggleCompletion(id: UUID) throws -> Bool {
        guard let entity = try fetchTaskEntity(id: id) else { return false }
        let isNowCompleted = !entity.isCompleted
        entity.isCompleted = isNowCompleted
        entity.completedAt = isNowCompleted ? Date() : nil
        try saveIfNeeded()
        return isNowCompleted
    }

    private func fetchTaskEntity(id: UUID) throws -> TaskEntity? {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func saveIfNeeded() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
