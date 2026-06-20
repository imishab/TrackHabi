import CoreData

final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "M4Movies",
            managedObjectModel: Self.makeModel()
        )

        if inMemory, let description = container.persistentStoreDescriptions.first {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load Core Data store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "RecentSearchEntity"
        entity.managedObjectClassName = NSStringFromClass(RecentSearchEntity.self)

        let keyword = NSAttributeDescription()
        keyword.name = "keyword"
        keyword.attributeType = .stringAttributeType
        keyword.isOptional = false

        let searchedAt = NSAttributeDescription()
        searchedAt.name = "searchedAt"
        searchedAt.attributeType = .dateAttributeType
        searchedAt.isOptional = false

        entity.properties = [keyword, searchedAt]

        model.entities = [entity]
        return model
    }
}

@objc(RecentSearchEntity)
final class RecentSearchEntity: NSManagedObject {

    @NSManaged var keyword: String
    @NSManaged var searchedAt: Date

    static func fetchRequest() -> NSFetchRequest<RecentSearchEntity> {
        NSFetchRequest<RecentSearchEntity>(entityName: "RecentSearchEntity")
    }
}
