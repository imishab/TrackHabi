import Foundation

struct HabitAnalytics: Identifiable {
    let habit: Habit
    let stats: HabitStats

    var id: UUID { habit.id }
}

@Observable
@MainActor
final class AnalyticsViewModel {

    private(set) var habitAnalytics: [HabitAnalytics] = []
    private(set) var weeklyCompletionCounts: [(date: Date, count: Int)] = []
    private(set) var completedTodayCount = 0
    var error: Error?

    private let repository: HabitRepository
    private let calendar = Calendar.current

    init(repository: HabitRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
    }

    var activeHabits: [HabitAnalytics] {
        habitAnalytics.filter { !$0.habit.isArchived }
    }

    var totalCompletions: Int {
        habitAnalytics.reduce(0) { $0 + $1.stats.totalCompletions }
    }

    var bestCurrentStreak: Int {
        habitAnalytics.map(\.stats.currentStreak).max() ?? 0
    }

    var scheduledTodayCount: Int {
        let today = Date()
        return activeHabits.filter { $0.habit.isScheduled(on: today, calendar: calendar) }.count
    }

    var todayCompletionRate: Double {
        guard scheduledTodayCount > 0 else { return 0 }
        return Double(completedTodayCount) / Double(scheduledTodayCount)
    }

    func load() {
        do {
            let habits = try repository.fetchAll()
            var analytics: [HabitAnalytics] = []
            var completionDayCounts: [Date: Int] = [:]
            var todayCount = 0
            let today = calendar.startOfDay(for: Date())

            for habit in habits {
                let completions = try repository.completions(forHabit: habit.id)
                let dates = completions.map { calendar.startOfDay(for: $0.date) }
                let stats = HabitStats.calculate(habit: habit, completionDates: dates, calendar: calendar)
                analytics.append(HabitAnalytics(habit: habit, stats: stats))

                for day in dates {
                    completionDayCounts[day, default: 0] += 1
                }
                if dates.contains(today) {
                    todayCount += 1
                }
            }

            habitAnalytics = analytics.sorted { $0.stats.currentStreak > $1.stats.currentStreak }
            completedTodayCount = todayCount

            weeklyCompletionCounts = (0..<7).reversed().map { offset in
                let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
                return (day, completionDayCounts[day, default: 0])
            }
        } catch {
            self.error = error
        }
    }
}
