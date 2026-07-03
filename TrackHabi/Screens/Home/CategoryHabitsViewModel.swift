import Foundation

@Observable
@MainActor
final class CategoryHabitsViewModel {

    private(set) var habits: [Habit] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    var selectedDate: Date = Date() {
        didSet { loadCompletions() }
    }
    var error: Error?

    let card: CategoryCard
    private let repository: HabitRepository
    let calendar = Calendar.current

    init(card: CategoryCard, repository: HabitRepository? = nil) {
        self.card = card
        self.repository = repository ?? HabitRepositoryImpl()
    }

    var visibleDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<14).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    var habitsForSelectedDate: [Habit] {
        habits.filter { $0.isScheduled(on: selectedDate, calendar: calendar) }
    }

    func load() {
        do {
            let all = try repository.fetchAll()
            habits = all
                .filter { !$0.isArchived && $0.categoryID == card.categoryID }
                .sorted { $0.createdAt < $1.createdAt }
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
