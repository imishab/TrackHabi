import CoreData

@objc(TaskEntity)
final class TaskEntity: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var notes: String?
    @NSManaged var priorityRaw: String
    @NSManaged var dueDate: Date?
    @NSManaged var isCompleted: Bool
    @NSManaged var createdAt: Date
    @NSManaged var completedAt: Date?
    @NSManaged var sortIndex: Int64

    static func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    static func makeEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "TaskEntity"
        entity.managedObjectClassName = NSStringFromClass(TaskEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .stringAttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let notes = NSAttributeDescription()
        notes.name = "notes"
        notes.attributeType = .stringAttributeType
        notes.isOptional = true

        let priorityRaw = NSAttributeDescription()
        priorityRaw.name = "priorityRaw"
        priorityRaw.attributeType = .stringAttributeType
        priorityRaw.isOptional = false
        priorityRaw.defaultValue = TaskPriority.medium.rawValue

        let dueDate = NSAttributeDescription()
        dueDate.name = "dueDate"
        dueDate.attributeType = .dateAttributeType
        dueDate.isOptional = true

        let isCompleted = NSAttributeDescription()
        isCompleted.name = "isCompleted"
        isCompleted.attributeType = .booleanAttributeType
        isCompleted.isOptional = false
        isCompleted.defaultValue = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let completedAt = NSAttributeDescription()
        completedAt.name = "completedAt"
        completedAt.attributeType = .dateAttributeType
        completedAt.isOptional = true

        let sortIndex = NSAttributeDescription()
        sortIndex.name = "sortIndex"
        sortIndex.attributeType = .integer64AttributeType
        sortIndex.isOptional = false
        sortIndex.defaultValue = 0

        entity.properties = [
            id, title, notes, priorityRaw, dueDate, isCompleted, createdAt, completedAt, sortIndex
        ]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }
}

extension TaskEntity {

    func toDomain() -> TaskItem {
        TaskItem(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            notes: notes ?? "",
            priority: TaskPriority(rawValue: priorityRaw) ?? .medium,
            dueDate: dueDate,
            isCompleted: isCompleted,
            createdAt: createdAt,
            completedAt: completedAt,
            sortIndex: Int(sortIndex)
        )
    }

    func apply(_ task: TaskItem) {
        id = task.id.uuidString
        title = task.title
        notes = task.notes.isEmpty ? nil : task.notes
        priorityRaw = task.priority.rawValue
        dueDate = task.dueDate
        isCompleted = task.isCompleted
        createdAt = task.createdAt
        completedAt = task.completedAt
        sortIndex = Int64(task.sortIndex)
    }
}
