import Foundation

@MainActor
protocol HabitCategoryRepository {
    func fetchAll() throws -> [HabitCategory]
    func add(_ category: HabitCategory) throws
    func update(_ category: HabitCategory) throws
    func delete(id: UUID) throws
}
