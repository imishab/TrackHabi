import Foundation

@Observable
@MainActor
final class HabitDetailViewModel {

    private(set) var habit: Habit
    private(set) var completedDates: Set<Date> = []
    private(set) var stats = HabitStats(currentStreak: 0, bestStreak: 0, totalCompletions: 0)
    var error: Error?

    private let repository: HabitRepository
    private let calendar = Calendar.current

    init(habit: Habit, repository: HabitRepository? = nil) {
        self.habit = habit
        self.repository = repository ?? HabitRepositoryImpl()
    }

    func load() {
        do {
            let completions = try repository.completions(forHabit: habit.id)
            let dates = completions.map { calendar.startOfDay(for: $0.date) }
            completedDates = Set(dates)
            stats = HabitStats.calculate(habit: habit, completionDates: dates, calendar: calendar)
        } catch {
            self.error = error
        }
    }

    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(calendar.startOfDay(for: date))
    }

    func toggle(_ date: Date) {
        do {
            let isNowCompleted = try repository.toggleCompletion(habitID: habit.id, on: date)
            let day = calendar.startOfDay(for: date)
            if isNowCompleted {
                completedDates.insert(day)
            } else {
                completedDates.remove(day)
            }
            stats = HabitStats.calculate(habit: habit, completionDates: Array(completedDates), calendar: calendar)
        } catch {
            self.error = error
        }
    }

    func delete() throws {
        try repository.delete(id: habit.id)
        NotificationScheduler.shared.cancel(for: habit.id)
    }

    func habitUpdated(_ habit: Habit) {
        self.habit = habit
        stats = HabitStats.calculate(habit: habit, completionDates: Array(completedDates), calendar: calendar)
    }
}
