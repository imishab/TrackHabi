import Foundation

@Observable
@MainActor
final class AddHabitViewModel {

    var title: String = ""
    var icon: String = HabitPalette.icons[0]
    var colorName: String = HabitPalette.colorNames[0]
    var scheduledDays: Set<Weekday> = Set(Weekday.allCases)
    var error: Error?

    private let repository: HabitRepository

    init(repository: HabitRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !scheduledDays.isEmpty
    }

    func toggleDay(_ day: Weekday) {
        if scheduledDays.contains(day) {
            scheduledDays.remove(day)
        } else {
            scheduledDays.insert(day)
        }
    }

    func save() -> Bool {
        guard canSave else { return false }
        let habit = Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            colorName: colorName,
            scheduledDays: scheduledDays
        )
        do {
            try repository.add(habit)
            return true
        } catch {
            self.error = error
            return false
        }
    }
}
