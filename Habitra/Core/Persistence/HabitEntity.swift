import CoreData

@objc(HabitEntity)
final class HabitEntity: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var notes: String?
    @NSManaged var icon: String
    @NSManaged var colorName: String
    @NSManaged var typeRaw: String?
    @NSManaged var targetCount: Int16
    @NSManaged var unit: String?
    @NSManaged var scheduledDaysMask: Int16
    @NSManaged var reminderTime: Date?
    @NSManaged var reminderToneRaw: String?
    @NSManaged var startDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var createdAt: Date
    @NSManaged var sortIndex: Int64
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

        let typeRaw = NSAttributeDescription()
        typeRaw.name = "typeRaw"
        typeRaw.attributeType = .stringAttributeType
        typeRaw.isOptional = true

        let targetCount = NSAttributeDescription()
        targetCount.name = "targetCount"
        targetCount.attributeType = .integer16AttributeType
        targetCount.isOptional = false
        targetCount.defaultValue = 1

        let unit = NSAttributeDescription()
        unit.name = "unit"
        unit.attributeType = .stringAttributeType
        unit.isOptional = true

        let scheduledDaysMask = NSAttributeDescription()
        scheduledDaysMask.name = "scheduledDaysMask"
        scheduledDaysMask.attributeType = .integer16AttributeType
        scheduledDaysMask.isOptional = false

        let reminderTime = NSAttributeDescription()
        reminderTime.name = "reminderTime"
        reminderTime.attributeType = .dateAttributeType
        reminderTime.isOptional = true

        let reminderToneRaw = NSAttributeDescription()
        reminderToneRaw.name = "reminderToneRaw"
        reminderToneRaw.attributeType = .stringAttributeType
        reminderToneRaw.isOptional = true

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

        let sortIndex = NSAttributeDescription()
        sortIndex.name = "sortIndex"
        sortIndex.attributeType = .integer64AttributeType
        sortIndex.isOptional = false
        sortIndex.defaultValue = 0

        let isArchived = NSAttributeDescription()
        isArchived.name = "isArchived"
        isArchived.attributeType = .booleanAttributeType
        isArchived.isOptional = false

        let categoryID = NSAttributeDescription()
        categoryID.name = "categoryID"
        categoryID.attributeType = .stringAttributeType
        categoryID.isOptional = true

        entity.properties = [
            id, title, notes, icon, colorName, typeRaw, targetCount, unit, scheduledDaysMask,
            reminderTime, reminderToneRaw, startDate, endDate, createdAt, sortIndex, isArchived, categoryID
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
            type: typeRaw.flatMap(HabitType.init(rawValue:)) ?? .task,
            targetCount: max(1, Int(targetCount)),
            unit: unit ?? "",
            scheduledDays: Weekday.set(fromMask: scheduledDaysMask),
            reminderTime: reminderTime,
            reminderTone: reminderToneRaw.flatMap(ReminderTone.init(rawValue:)) ?? .system,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            sortIndex: Int(sortIndex),
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
        typeRaw = habit.type.rawValue
        targetCount = Int16(habit.targetCount)
        unit = habit.unit.isEmpty ? nil : habit.unit
        scheduledDaysMask = Weekday.mask(from: habit.scheduledDays)
        reminderTime = habit.reminderTime
        reminderToneRaw = habit.reminderTone.rawValue
        startDate = habit.startDate
        endDate = habit.endDate
        createdAt = habit.createdAt
        sortIndex = Int64(habit.sortIndex)
        isArchived = habit.isArchived
        categoryID = habit.categoryID?.uuidString
    }
}
