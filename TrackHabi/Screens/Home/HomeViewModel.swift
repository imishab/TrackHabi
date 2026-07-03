import Foundation

struct TrackingDay: Identifiable {
    enum Status {
        case completed, missed, empty
    }

    let date: Date
    let status: Status

    var id: Date { date }
}

@Observable
@MainActor
final class HomeViewModel {

    private(set) var categories: [HabitCategory] = []
    private(set) var habits: [Habit] = []
    private(set) var completionDatesByHabit: [UUID: Set<Date>] = [:]
    private(set) var completedTodayIDs: Set<UUID> = []
    var error: Error?

    private let categoryRepository: HabitCategoryRepository
    private let habitRepository: HabitRepository
    private let calendar = Calendar.current

    init(categoryRepository: HabitCategoryRepository? = nil, habitRepository: HabitRepository? = nil) {
        self.categoryRepository = categoryRepository ?? HabitCategoryRepositoryImpl()
        self.habitRepository = habitRepository ?? HabitRepositoryImpl()
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    var cards: [CategoryCard] {
        var result = categories.compactMap { category -> CategoryCard? in
            let count = activeHabits.filter { $0.categoryID == category.id }.count
            guard count > 0 else { return nil }
            return .category(category, count: count)
        }

        let uncategorizedCount = activeHabits.filter { $0.categoryID == nil }.count
        if uncategorizedCount > 0 {
            result.append(.uncategorized(count: uncategorizedCount))
        }

        return result
    }

    var topStreak: (habit: Habit, streak: Int)? {
        activeHabits
            .compactMap { habit -> (Habit, Int)? in
                let dates = completionDatesByHabit[habit.id] ?? []
                let stats = HabitStats.calculate(habit: habit, completionDates: Array(dates), calendar: calendar)
                guard stats.currentStreak > 0 else { return nil }
                return (habit, stats.currentStreak)
            }
            .max { $0.1 < $1.1 }
    }

    var todayScheduledCount: Int {
        let today = Date()
        return activeHabits.filter { $0.isScheduled(on: today, calendar: calendar) }.count
    }

    var todayCompletedCount: Int {
        let today = Date()
        return activeHabits.filter { $0.isScheduled(on: today, calendar: calendar) && completedTodayIDs.contains($0.id) }.count
    }

    var todayCompletionRatio: Double {
        guard todayScheduledCount > 0 else { return 0 }
        return Double(todayCompletedCount) / Double(todayScheduledCount)
    }

    var recentHabits: [Habit] {
        Array(activeHabits.sorted { $0.createdAt > $1.createdAt }.prefix(5))
    }

    var trackingDays: [TrackingDay] {
        let today = calendar.startOfDay(for: Date())
        let days = (0..<42).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
        return days.map { day in
            let scheduled = activeHabits.filter { $0.isScheduled(on: day, calendar: calendar) }
            guard !scheduled.isEmpty else {
                return TrackingDay(date: day, status: .empty)
            }
            let allCompleted = scheduled.allSatisfy { habit in
                (completionDatesByHabit[habit.id] ?? []).contains(day)
            }
            return TrackingDay(date: day, status: allCompleted ? .completed : .missed)
        }
    }

    func load() {
        do {
            categories = try categoryRepository.fetchAll()
            habits = try habitRepository.fetchAll()

            var map: [UUID: Set<Date>] = [:]
            for habit in habits {
                let completions = try habitRepository.completions(forHabit: habit.id)
                map[habit.id] = Set(completions.map { calendar.startOfDay(for: $0.date) })
            }
            completionDatesByHabit = map

            let todayCompletions = try habitRepository.completions(on: Date())
            completedTodayIDs = Set(todayCompletions.map(\.habitID))
        } catch {
            self.error = error
        }
    }

    func habits(for card: CategoryCard) -> [Habit] {
        habits
            .filter { !$0.isArchived && $0.categoryID == card.categoryID }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func isCompletedToday(_ habit: Habit) -> Bool {
        completedTodayIDs.contains(habit.id)
    }

    func toggleToday(_ habit: Habit) {
        do {
            let today = Date()
            let isNowCompleted = try habitRepository.toggleCompletion(habitID: habit.id, on: today)
            let day = calendar.startOfDay(for: today)
            if isNowCompleted {
                completedTodayIDs.insert(habit.id)
                completionDatesByHabit[habit.id, default: []].insert(day)
            } else {
                completedTodayIDs.remove(habit.id)
                completionDatesByHabit[habit.id]?.remove(day)
            }
        } catch {
            self.error = error
        }
    }
}
