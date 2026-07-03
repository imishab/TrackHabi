import Foundation

@Observable
@MainActor
final class AddCategoryViewModel {

    var name: String = ""
    var icon: String = "folder.fill"
    var colorName: String = HabitPalette.colorNames[0]
    var error: Error?

    private let repository: HabitCategoryRepository

    init(repository: HabitCategoryRepository? = nil) {
        self.repository = repository ?? HabitCategoryRepositoryImpl()
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() -> HabitCategory? {
        guard canSave else { return nil }
        let category = HabitCategory(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            colorName: colorName
        )
        do {
            try repository.add(category)
            return category
        } catch {
            self.error = error
            return nil
        }
    }
}
