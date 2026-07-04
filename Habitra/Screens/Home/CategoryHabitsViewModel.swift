import Foundation

@Observable
@MainActor
final class CategoryHabitsViewModel {

    private(set) var habits: [Habit] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    private(set) var card: CategoryCard
    var selectedDate: Date = Date() {
        didSet { loadCompletions() }
    }
    var error: Error?

    private let repository: HabitRepository
    private let categoryRepository: HabitCategoryRepository
    let calendar = Calendar.current

    init(card: CategoryCard, repository: HabitRepository? = nil, categoryRepository: HabitCategoryRepository? = nil) {
        self.card = card
        self.repository = repository ?? HabitRepositoryImpl()
        self.categoryRepository = categoryRepository ?? HabitCategoryRepositoryImpl()
    }

    var underlyingCategory: HabitCategory? {
        if case .category(let category, _) = card {
            return category
        }
        return nil
    }

    var visibleDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: today),
            let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count
        else {
            return [today]
        }
        let firstOfMonth = monthInterval.start
        return (0..<daysInMonth).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstOfMonth)
        }
    }

    var habitsForSelectedDate: [Habit] {
        habits.filter { $0.isWithinActiveRange(on: selectedDate, calendar: calendar) }
    }

    func isEnabled(_ habit: Habit) -> Bool {
        guard calendar.startOfDay(for: selectedDate) <= calendar.startOfDay(for: Date()) else { return false }
        return habit.isScheduled(on: selectedDate, calendar: calendar)
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
        guard isEnabled(habit) else { return }
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

    func categoryUpdated(_ category: HabitCategory) {
        card = .category(category, count: habits.count)
    }

    func deleteCategory() throws {
        guard let category = underlyingCategory else { return }
        let all = try repository.fetchAll()
        for var habit in all where habit.categoryID == category.id {
            habit.categoryID = nil
            try repository.update(habit)
        }
        try categoryRepository.delete(id: category.id)
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
