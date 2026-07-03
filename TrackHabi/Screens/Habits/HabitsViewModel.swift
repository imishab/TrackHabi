import Foundation

@Observable
@MainActor
final class HabitsViewModel {

    private(set) var habits: [Habit] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    var error: Error?

    private let repository: HabitRepository
    private let calendar = Calendar.current
    let today = Date()

    init(repository: HabitRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
    }

    var todaysHabits: [Habit] {
        habits
            .filter { !$0.isArchived && $0.isScheduled(on: today, calendar: calendar) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func load() {
        do {
            habits = try repository.fetchAll()
            let completions = try repository.completions(on: today)
            completedHabitIDs = Set(completions.map(\.habitID))
        } catch {
            self.error = error
        }
    }

    func isCompletedToday(_ habit: Habit) -> Bool {
        completedHabitIDs.contains(habit.id)
    }

    func toggleToday(_ habit: Habit) {
        do {
            let isNowCompleted = try repository.toggleCompletion(habitID: habit.id, on: today)
            if isNowCompleted {
                completedHabitIDs.insert(habit.id)
            } else {
                completedHabitIDs.remove(habit.id)
            }
        } catch {
            self.error = error
        }
    }

    func delete(_ habit: Habit) {
        do {
            try repository.delete(id: habit.id)
            load()
        } catch {
            self.error = error
        }
    }
}
