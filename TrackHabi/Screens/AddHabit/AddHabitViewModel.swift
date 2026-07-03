import Foundation

@Observable
@MainActor
final class AddHabitViewModel {

    var title: String = ""
    var icon: String = HabitPalette.icons[0]
    var colorName: String = HabitPalette.colorNames[0]
    var scheduledDays: Set<Weekday> = Set(Weekday.allCases)
    var categories: [HabitCategory] = []
    var selectedCategoryID: UUID?
    var error: Error?

    private let repository: HabitRepository
    private let categoryRepository: HabitCategoryRepository

    init(repository: HabitRepository? = nil, categoryRepository: HabitCategoryRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
        self.categoryRepository = categoryRepository ?? HabitCategoryRepositoryImpl()
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !scheduledDays.isEmpty
    }

    var selectedCategory: HabitCategory? {
        categories.first { $0.id == selectedCategoryID }
    }

    func loadCategories() {
        do {
            categories = try categoryRepository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func categoryCreated(_ category: HabitCategory) {
        categories.append(category)
        selectedCategoryID = category.id
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
            scheduledDays: scheduledDays,
            categoryID: selectedCategoryID
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
