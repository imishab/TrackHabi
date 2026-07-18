import Foundation
import SwiftUI

@Observable
@MainActor
final class HabitOverviewViewModel {

    private(set) var habits: [Habit] = []
    private(set) var categories: [HabitCategory] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    private(set) var completionCounts: [UUID: Int] = [:]
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
            .sorted(by: Habit.displayOrder)
    }

    func isEnabled(_ habit: Habit) -> Bool {
        guard calendar.startOfDay(for: selectedDate) <= calendar.startOfDay(for: Date()) else { return false }
        return habit.isScheduled(on: selectedDate, calendar: calendar)
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
        switch habit.type {
        case .task:
            return completedHabitIDs.contains(habit.id)
        case .counter:
            return count(for: habit) >= habit.targetCount
        }
    }

    func count(for habit: Habit) -> Int {
        completionCounts[habit.id] ?? 0
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

    func increment(_ habit: Habit) {
        guard isEnabled(habit), count(for: habit) < habit.targetCount else { return }
        do {
            let newCount = try repository.setCompletionCount(habitID: habit.id, on: selectedDate, count: count(for: habit) + 1)
            completionCounts[habit.id] = newCount
        } catch {
            self.error = error
        }
    }

    func decrement(_ habit: Habit) {
        guard isEnabled(habit), count(for: habit) > 0 else { return }
        do {
            let newCount = try repository.setCompletionCount(habitID: habit.id, on: selectedDate, count: count(for: habit) - 1)
            completionCounts[habit.id] = newCount
        } catch {
            self.error = error
        }
    }

    func delete(_ habit: Habit) {
        do {
            try repository.delete(id: habit.id)
            NotificationScheduler.shared.cancel(for: habit.id)
            load()
        } catch {
            self.error = error
        }
    }

    func moveHabit(in group: HabitCategoryGroup, from source: IndexSet, to destination: Int) {
        var reorderedHabits = group.habits
        reorderedHabits.move(fromOffsets: source, toOffset: destination)

        do {
            for (index, var habit) in reorderedHabits.enumerated() {
                habit.sortIndex = index
                try repository.update(habit)

                if let habitIndex = habits.firstIndex(where: { $0.id == habit.id }) {
                    habits[habitIndex] = habit
                }
            }
            NotificationCenter.default.post(name: .habitDataDidChange, object: nil)
        } catch {
            self.error = error
            load()
        }
    }

    private func loadCompletions() {
        do {
            let completions = try repository.completions(on: selectedDate)
            completedHabitIDs = Set(completions.map(\.habitID))
            completionCounts = Dictionary(uniqueKeysWithValues: completions.map { ($0.habitID, $0.count) })
        } catch {
            self.error = error
        }
    }
}
