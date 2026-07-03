import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID
    var title: String
    var icon: String
    var colorName: String
    var scheduledDays: Set<Weekday>
    var createdAt: Date
    var isArchived: Bool
    var categoryID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        icon: String = "checkmark.circle",
        colorName: String = "mint",
        scheduledDays: Set<Weekday> = Set(Weekday.allCases),
        createdAt: Date = Date(),
        isArchived: Bool = false,
        categoryID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorName = colorName
        self.scheduledDays = scheduledDays
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.categoryID = categoryID
    }

    var isDaily: Bool { scheduledDays.count == Weekday.allCases.count }

    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        scheduledDays.contains(Weekday.from(date: date, calendar: calendar))
    }
}
