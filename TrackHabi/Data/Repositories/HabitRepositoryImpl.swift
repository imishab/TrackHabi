import CoreData
import Foundation

@MainActor
final class HabitRepositoryImpl: HabitRepository {

    private let context: NSManagedObjectContext
    private let calendar: Calendar

    init(controller: PersistenceController = .shared, calendar: Calendar = .current) {
        self.context = controller.container.viewContext
        self.calendar = calendar
    }

    func fetchAll() throws -> [Habit] {
        let request = HabitEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return try context.fetch(request).map { $0.toDomain() }
    }

    func add(_ habit: Habit) throws {
        let entity = HabitEntity(context: context)
        entity.apply(habit)
        try saveIfNeeded()
    }

    func update(_ habit: Habit) throws {
        guard let entity = try fetchHabitEntity(id: habit.id) else { return }
        entity.apply(habit)
        try saveIfNeeded()
    }

    func delete(id: UUID) throws {
        guard let entity = try fetchHabitEntity(id: id) else { return }
        context.delete(entity)

        let request = HabitCompletionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitID == %@", id.uuidString)
        for completion in try context.fetch(request) {
            context.delete(completion)
        }

        try saveIfNeeded()
    }

    func completions(forHabit habitID: UUID) throws -> [HabitCompletion] {
        let request = HabitCompletionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitID == %@", habitID.uuidString)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(request).map { $0.toDomain() }
    }

    func completions(on date: Date) throws -> [HabitCompletion] {
        let day = calendar.startOfDay(for: date)
        let request = HabitCompletionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", day as NSDate)
        return try context.fetch(request).map { $0.toDomain() }
    }

    @discardableResult
    func toggleCompletion(habitID: UUID, on date: Date) throws -> Bool {
        let day = calendar.startOfDay(for: date)
        let request = HabitCompletionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitID == %@ AND date == %@", habitID.uuidString, day as NSDate)

        if let existing = try context.fetch(request).first {
            context.delete(existing)
            try saveIfNeeded()
            return false
        }

        let entity = HabitCompletionEntity(context: context)
        entity.id = UUID().uuidString
        entity.habitID = habitID.uuidString
        entity.date = day
        entity.completedAt = Date()
        try saveIfNeeded()
        return true
    }

    private func fetchHabitEntity(id: UUID) throws -> HabitEntity? {
        let request = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func saveIfNeeded() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
