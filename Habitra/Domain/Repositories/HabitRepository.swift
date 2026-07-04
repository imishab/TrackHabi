import Foundation

@MainActor
protocol HabitRepository {
    func fetchAll() throws -> [Habit]
    func add(_ habit: Habit) throws
    func update(_ habit: Habit) throws
    func delete(id: UUID) throws
    func completions(forHabit habitID: UUID) throws -> [HabitCompletion]
    func completions(on date: Date) throws -> [HabitCompletion]

    @discardableResult
    func toggleCompletion(habitID: UUID, on date: Date) throws -> Bool
}
