import Foundation

struct HabitStats {
    let currentStreak: Int
    let bestStreak: Int
    let totalCompletions: Int

    static func calculate(habit: Habit, completionDates: [Date], calendar: Calendar = .current, today: Date = Date()) -> HabitStats {
        let days = Set(completionDates.map { calendar.startOfDay(for: $0) })

        func scheduledDaysBack(from date: Date, limit: Int) -> [Date] {
            var results: [Date] = []
            var cursor = date
            while results.count < limit {
                if habit.isScheduled(on: cursor, calendar: calendar) {
                    results.append(cursor)
                }
                guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = previous
            }
            return results
        }

        var current = 0
        var cursor = calendar.startOfDay(for: today)
        if !days.contains(cursor), habit.isScheduled(on: cursor, calendar: calendar) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return HabitStats(currentStreak: 0, bestStreak: 0, totalCompletions: days.count)
            }
            cursor = yesterday
        }
        while true {
            if habit.isScheduled(on: cursor, calendar: calendar) {
                if days.contains(cursor) {
                    current += 1
                } else {
                    break
                }
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        var best = 0
        var running = 0
        let sortedDays = days.sorted()
        var previousScheduledDay: Date?
        for day in sortedDays {
            if let previousScheduledDay,
               let expectedPrevious = calendar.date(byAdding: .day, value: -1, to: day),
               previousScheduledDay == expectedPrevious {
                running += 1
            } else {
                running = 1
            }
            best = max(best, running)
            previousScheduledDay = day
        }

        return HabitStats(currentStreak: current, bestStreak: best, totalCompletions: days.count)
    }
}
