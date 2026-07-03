import Foundation

@Observable
@MainActor
final class DaysViewModel {

    private(set) var habits: [Habit] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    var selectedDate: Date = Date() {
        didSet { loadCompletions() }
    }
    var error: Error?

    private let repository: HabitRepository
    let calendar = Calendar.current

    init(repository: HabitRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
    }

    var visibleDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<14).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    var habitsForSelectedDate: [Habit] {
        habits
            .filter { !$0.isArchived && $0.isScheduled(on: selectedDate, calendar: calendar) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func load() {
        do {
            habits = try repository.fetchAll()
            loadCompletions()
        } catch {
            self.error = error
        }
    }

    func isCompleted(_ habit: Habit) -> Bool {
        completedHabitIDs.contains(habit.id)
    }

    func toggle(_ habit: Habit) {
        do {
            let isNowCompleted = try repository.toggleCompletion(habitID: habit.id, on: selectedDate)
            if isNowCompleted {
                completedHabitIDs.insert(habit.id)
            } else {
                completedHabitIDs.remove(habit.id)
            }
        } catch {
            self.error = error
        }
    }

    private func loadCompletions() {
        do {
            let completions = try repository.completions(on: selectedDate)
            completedHabitIDs = Set(completions.map(\.habitID))
        } catch {
            self.error = error
        }
    }
}
