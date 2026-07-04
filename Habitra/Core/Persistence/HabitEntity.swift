import CoreData

@objc(HabitEntity)
final class HabitEntity: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var notes: String?
    @NSManaged var icon: String
    @NSManaged var colorName: String
    @NSManaged var scheduledDaysMask: Int16
    @NSManaged var reminderTime: Date?
    @NSManaged var startDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var createdAt: Date
    @NSManaged var isArchived: Bool
    @NSManaged var categoryID: String?

    static func fetchRequest() -> NSFetchRequest<HabitEntity> {
        NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }

    static func makeEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "HabitEntity"
        entity.managedObjectClassName = NSStringFromClass(HabitEntity.self)

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

        let icon = NSAttributeDescription()
        icon.name = "icon"
        icon.attributeType = .stringAttributeType
        icon.isOptional = false

        let colorName = NSAttributeDescription()
        colorName.name = "colorName"
        colorName.attributeType = .stringAttributeType
        colorName.isOptional = false

        let scheduledDaysMask = NSAttributeDescription()
        scheduledDaysMask.name = "scheduledDaysMask"
        scheduledDaysMask.attributeType = .integer16AttributeType
        scheduledDaysMask.isOptional = false

        let reminderTime = NSAttributeDescription()
        reminderTime.name = "reminderTime"
        reminderTime.attributeType = .dateAttributeType
        reminderTime.isOptional = true

        let startDate = NSAttributeDescription()
        startDate.name = "startDate"
        startDate.attributeType = .dateAttributeType
        startDate.isOptional = true

        let endDate = NSAttributeDescription()
        endDate.name = "endDate"
        endDate.attributeType = .dateAttributeType
        endDate.isOptional = true

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let isArchived = NSAttributeDescription()
        isArchived.name = "isArchived"
        isArchived.attributeType = .booleanAttributeType
        isArchived.isOptional = false

        let categoryID = NSAttributeDescription()
        categoryID.name = "categoryID"
        categoryID.attributeType = .stringAttributeType
        categoryID.isOptional = true

        entity.properties = [
            id, title, notes, icon, colorName, scheduledDaysMask,
            reminderTime, startDate, endDate, createdAt, isArchived, categoryID
        ]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }
}

extension HabitEntity {

    func toDomain() -> Habit {
        Habit(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            notes: notes ?? "",
            icon: icon,
            colorName: colorName,
            scheduledDays: Weekday.set(fromMask: scheduledDaysMask),
            reminderTime: reminderTime,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            isArchived: isArchived,
            categoryID: categoryID.flatMap { UUID(uuidString: $0) }
        )
    }

    func apply(_ habit: Habit) {
        id = habit.id.uuidString
        title = habit.title
        notes = habit.notes.isEmpty ? nil : habit.notes
        icon = habit.icon
        colorName = habit.colorName
        scheduledDaysMask = Weekday.mask(from: habit.scheduledDays)
        reminderTime = habit.reminderTime
        startDate = habit.startDate
        endDate = habit.endDate
        createdAt = habit.createdAt
        isArchived = habit.isArchived
        categoryID = habit.categoryID?.uuidString
    }
}
