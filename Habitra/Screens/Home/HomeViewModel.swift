import Foundation

struct TrackingDay: Identifiable {
    enum Status: Equatable {
        case tracked(ratio: Double)
        case inactive
    }

    let id = UUID()
    /// `nil` for leading placeholder cells used to align day 1 under its weekday column.
    let date: Date?
    let status: Status?
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

    var monthTitle: String {
        Date().formatted(.dateTime.month(.wide).year())
    }

    var trackingDays: [TrackingDay] {
        let today = calendar.startOfDay(for: Date())
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: today),
            let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count
        else {
            return []
        }

        let firstOfMonth = monthInterval.start
        let leadingBlanks = calendar.component(.weekday, from: firstOfMonth) - 1

        var days: [TrackingDay] = Array(repeating: TrackingDay(date: nil, status: nil), count: leadingBlanks)

        for offset in 0..<daysInMonth {
            guard let date = calendar.date(byAdding: .day, value: offset, to: firstOfMonth) else { continue }
            let day = calendar.startOfDay(for: date)

            guard day <= today else {
                days.append(TrackingDay(date: day, status: .inactive))
                continue
            }

            let scheduled = activeHabits.filter { $0.isScheduled(on: day, calendar: calendar) }
            guard !scheduled.isEmpty else {
                days.append(TrackingDay(date: day, status: .inactive))
                continue
            }

            let completedCount = scheduled.filter { habit in
                (completionDatesByHabit[habit.id] ?? []).contains(day)
            }.count
            let ratio = Double(completedCount) / Double(scheduled.count)
            days.append(TrackingDay(date: day, status: .tracked(ratio: ratio)))
        }

        return days
    }

    func load() {
        do {
            categories = try categoryRepository.fetchAll()
            habits = try habitRepository.fetchAll()

            var map: [UUID: Set<Date>] = [:]
            for habit in habits {
                let completions = try habitRepository.completions(forHabit: habit.id)
                let metDates = completions
                    .filter { habit.type == .task || $0.count >= habit.targetCount }
                    .map { calendar.startOfDay(for: $0.date) }
                map[habit.id] = Set(metDates)
            }
            completionDatesByHabit = map

            let todayCompletions = try habitRepository.completions(on: Date())
            let habitsByID = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, $0) })
            completedTodayIDs = Set(todayCompletions.filter { completion in
                guard let habit = habitsByID[completion.habitID] else { return false }
                return habit.type == .task || completion.count >= habit.targetCount
            }.map(\.habitID))
        } catch {
            self.error = error
        }
    }

    func habits(for card: CategoryCard) -> [Habit] {
        habits
            .filter { !$0.isArchived && $0.categoryID == card.categoryID }
            .sorted(by: Habit.displayOrder)
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
