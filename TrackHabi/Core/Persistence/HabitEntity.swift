import CoreData

@objc(HabitEntity)
final class HabitEntity: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var icon: String
    @NSManaged var colorName: String
    @NSManaged var scheduledDaysMask: Int16
    @NSManaged var createdAt: Date
    @NSManaged var isArchived: Bool

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

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let isArchived = NSAttributeDescription()
        isArchived.name = "isArchived"
        isArchived.attributeType = .booleanAttributeType
        isArchived.isOptional = false

        entity.properties = [id, title, icon, colorName, scheduledDaysMask, createdAt, isArchived]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }
}

extension HabitEntity {

    func toDomain() -> Habit {
        Habit(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            icon: icon,
            colorName: colorName,
            scheduledDays: Weekday.set(fromMask: scheduledDaysMask),
            createdAt: createdAt,
            isArchived: isArchived
        )
    }

    func apply(_ habit: Habit) {
        id = habit.id.uuidString
        title = habit.title
        icon = habit.icon
        colorName = habit.colorName
        scheduledDaysMask = Weekday.mask(from: habit.scheduledDays)
        createdAt = habit.createdAt
        isArchived = habit.isArchived
    }
}
