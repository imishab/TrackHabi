import CoreData

@objc(HabitCategoryEntity)
final class HabitCategoryEntity: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var icon: String
    @NSManaged var colorName: String
    @NSManaged var createdAt: Date

    static func fetchRequest() -> NSFetchRequest<HabitCategoryEntity> {
        NSFetchRequest<HabitCategoryEntity>(entityName: "HabitCategoryEntity")
    }

    static func makeEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "HabitCategoryEntity"
        entity.managedObjectClassName = NSStringFromClass(HabitCategoryEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .stringAttributeType
        id.isOptional = false

        let name = NSAttributeDescription()
        name.name = "name"
        name.attributeType = .stringAttributeType
        name.isOptional = false

        let icon = NSAttributeDescription()
        icon.name = "icon"
        icon.attributeType = .stringAttributeType
        icon.isOptional = false

        let colorName = NSAttributeDescription()
        colorName.name = "colorName"
        colorName.attributeType = .stringAttributeType
        colorName.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        entity.properties = [id, name, icon, colorName, createdAt]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }
}

extension HabitCategoryEntity {

    func toDomain() -> HabitCategory {
        HabitCategory(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            icon: icon,
            colorName: colorName,
            createdAt: createdAt
        )
    }

    func apply(_ category: HabitCategory) {
        id = category.id.uuidString
        name = category.name
        icon = category.icon
        colorName = category.colorName
        createdAt = category.createdAt
    }
}
