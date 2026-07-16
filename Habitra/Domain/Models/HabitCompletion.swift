import Foundation

struct HabitCompletion: Identifiable, Hashable {
    let id: UUID
    let habitID: UUID
    let date: Date
    let completedAt: Date
    let count: Int

    init(id: UUID = UUID(), habitID: UUID, date: Date, completedAt: Date = Date(), count: Int = 1) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.completedAt = completedAt
        self.count = count
    }
}
