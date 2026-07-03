import Foundation

@Observable
@MainActor
final class HabitOverviewViewModel {

    private(set) var habits: [Habit] = []
    private(set) var categories: [HabitCategory] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    var selectedDate: Date = Date() {
        didSet { loadCompletions() }
    }
    var error: Error?

    private let repository: HabitRepository
    private let categoryRepository: HabitCategoryRepository
    let calendar = Calendar.current

    init(repository: HabitRepository? = nil, categoryRepository: HabitCategoryRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
        self.categoryRepository = categoryRepository ?? HabitCategoryRepositoryImpl()
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
        habits
            .filter { !$0.isArchived && $0.isWithinActiveRange(on: selectedDate, calendar: calendar) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func isEnabled(_ habit: Habit) -> Bool {
        habit.isScheduled(on: selectedDate, calendar: calendar)
    }

    var groupedHabits: [HabitCategoryGroup] {
        let dayHabits = habitsForSelectedDate
        var byCategory: [UUID: [Habit]] = [:]
        var uncategorized: [Habit] = []

        for habit in dayHabits {
            if let categoryID = habit.categoryID {
                byCategory[categoryID, default: []].append(habit)
            } else {
                uncategorized.append(habit)
            }
        }

        var groups: [HabitCategoryGroup] = categories.compactMap { category in
            guard let habits = byCategory[category.id], !habits.isEmpty else { return nil }
            return HabitCategoryGroup(card: .category(category, count: habits.count), habits: habits)
        }

        if !uncategorized.isEmpty {
            groups.append(HabitCategoryGroup(card: .uncategorized(count: uncategorized.count), habits: uncategorized))
        }

        return groups
    }

    func load() {
        do {
            habits = try repository.fetchAll()
            categories = try categoryRepository.fetchAll()
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

    func delete(_ habit: Habit) {
        do {
            try repository.delete(id: habit.id)
            load()
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
