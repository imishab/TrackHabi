import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var icon: String
    var colorName: String
    var scheduledDays: Set<Weekday>
    var reminderTime: Date?
    var reminderTone: ReminderTone
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date
    var sortIndex: Int
    var isArchived: Bool
    var categoryID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        icon: String = "checkmark.circle",
        colorName: String = "mint",
        scheduledDays: Set<Weekday> = Set(Weekday.allCases),
        reminderTime: Date? = nil,
        reminderTone: ReminderTone = .system,
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date = Date(),
        sortIndex: Int = Int(Date().timeIntervalSince1970),
        isArchived: Bool = false,
        categoryID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.icon = icon
        self.colorName = colorName
        self.scheduledDays = scheduledDays
        self.reminderTime = reminderTime
        self.reminderTone = reminderTone
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.sortIndex = sortIndex
        self.isArchived = isArchived
        self.categoryID = categoryID
    }

    var isDaily: Bool { scheduledDays.count == Weekday.allCases.count }

    static func displayOrder(_ lhs: Habit, _ rhs: Habit) -> Bool {
        if lhs.sortIndex != rhs.sortIndex {
            return lhs.sortIndex < rhs.sortIndex
        }
        return lhs.createdAt < rhs.createdAt
    }

    /// Whether `date` falls within the habit's active start/end date bounds, ignoring the weekly schedule.
    func isWithinActiveRange(on date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        if let startDate, day < calendar.startOfDay(for: startDate) { return false }
        if let endDate, day > calendar.startOfDay(for: endDate) { return false }
        return true
    }

    /// Whether `date` is an actual scheduled (completable) day: matches the weekly schedule and is within range.
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        guard scheduledDays.contains(Weekday.from(date: date, calendar: calendar)) else { return false }
        return isWithinActiveRange(on: date, calendar: calendar)
    }
}
