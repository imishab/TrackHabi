import Foundation

@Observable
@MainActor
final class AddCategoryViewModel {

    var name: String
    var icon: String
    var colorName: String
    var error: Error?

    private let repository: HabitCategoryRepository
    private let editingID: UUID?
    private let createdAt: Date

    init(category: HabitCategory? = nil, repository: HabitCategoryRepository? = nil) {
        self.repository = repository ?? HabitCategoryRepositoryImpl()
        self.editingID = category?.id
        self.createdAt = category?.createdAt ?? Date()
        self.name = category?.name ?? ""
        self.icon = category?.icon ?? "folder.fill"
        self.colorName = category?.colorName ?? HabitPalette.colorNames[0]
    }

    var isEditing: Bool { editingID != nil }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() -> HabitCategory? {
        guard canSave else { return nil }
        let category = HabitCategory(
            id: editingID ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            colorName: colorName,
            createdAt: createdAt
        )
        do {
            if isEditing {
                try repository.update(category)
            } else {
                try repository.add(category)
            }
            return category
        } catch {
            self.error = error
            return nil
        }
    }
}
