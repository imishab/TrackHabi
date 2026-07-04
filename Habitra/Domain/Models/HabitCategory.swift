import Foundation

struct HabitCategory: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var colorName: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder.fill",
        colorName: String = "mint",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.createdAt = createdAt
    }
}
