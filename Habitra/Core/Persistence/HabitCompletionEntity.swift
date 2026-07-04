import CoreData

@objc(HabitCompletionEntity)
final class HabitCompletionEntity: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var habitID: String
    @NSManaged var date: Date
    @NSManaged var completedAt: Date

    static func fetchRequest() -> NSFetchRequest<HabitCompletionEntity> {
        NSFetchRequest<HabitCompletionEntity>(entityName: "HabitCompletionEntity")
    }

    static func makeEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "HabitCompletionEntity"
        entity.managedObjectClassName = NSStringFromClass(HabitCompletionEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .stringAttributeType
        id.isOptional = false

        let habitID = NSAttributeDescription()
        habitID.name = "habitID"
        habitID.attributeType = .stringAttributeType
        habitID.isOptional = false

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false

        let completedAt = NSAttributeDescription()
        completedAt.name = "completedAt"
        completedAt.attributeType = .dateAttributeType
        completedAt.isOptional = false

        entity.properties = [id, habitID, date, completedAt]
        entity.uniquenessConstraints = [["habitID", "date"]]
        return entity
    }
}

extension HabitCompletionEntity {

    func toDomain() -> HabitCompletion {
        HabitCompletion(
            id: UUID(uuidString: id) ?? UUID(),
            habitID: UUID(uuidString: habitID) ?? UUID(),
            date: date,
            completedAt: completedAt
        )
    }
}
