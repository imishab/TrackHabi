import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var icon: String
    var colorName: String
    var scheduledDays: Set<Weekday>
    var reminderTime: Date?
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date
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
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date = Date(),
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
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.categoryID = categoryID
    }

    var isDaily: Bool { scheduledDays.count == Weekday.allCases.count }

    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        guard scheduledDays.contains(Weekday.from(date: date, calendar: calendar)) else { return false }
        let day = calendar.startOfDay(for: date)
        if let startDate, day < calendar.startOfDay(for: startDate) { return false }
        if let endDate, day > calendar.startOfDay(for: endDate) { return false }
        return true
    }
}
