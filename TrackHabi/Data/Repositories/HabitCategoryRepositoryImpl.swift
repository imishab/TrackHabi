import CoreData
import Foundation

@MainActor
final class HabitCategoryRepositoryImpl: HabitCategoryRepository {

    private let context: NSManagedObjectContext

    init(controller: PersistenceController = .shared) {
        self.context = controller.container.viewContext
    }

    func fetchAll() throws -> [HabitCategory] {
        let request = HabitCategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return try context.fetch(request).map { $0.toDomain() }
    }

    func add(_ category: HabitCategory) throws {
        let entity = HabitCategoryEntity(context: context)
        entity.apply(category)
        try saveIfNeeded()
    }

    func delete(id: UUID) throws {
        let request = HabitCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else { return }
        context.delete(entity)
        try saveIfNeeded()
    }

    private func saveIfNeeded() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
