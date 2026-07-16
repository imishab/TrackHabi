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

    /// Sets the completion count for a counter habit on a given date. A count of `0` removes the record.
    @discardableResult
    func setCompletionCount(habitID: UUID, on date: Date, count: Int) throws -> Int
}
