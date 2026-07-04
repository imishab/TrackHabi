import Foundation

struct HabitCompletion: Identifiable, Hashable {
    let id: UUID
    let habitID: UUID
    let date: Date
    let completedAt: Date

    init(id: UUID = UUID(), habitID: UUID, date: Date, completedAt: Date = Date()) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.completedAt = completedAt
    }
}
