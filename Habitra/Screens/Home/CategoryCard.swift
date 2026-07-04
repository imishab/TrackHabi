import Foundation

enum CategoryCard: Identifiable, Hashable {
    case category(HabitCategory, count: Int)
    case uncategorized(count: Int)

    var id: String {
        switch self {
        case .category(let category, _): category.id.uuidString
        case .uncategorized: "uncategorized"
        }
    }

    var name: String {
        switch self {
        case .category(let category, _): category.name
        case .uncategorized: "Uncategorized"
        }
    }

    var icon: String {
        switch self {
        case .category(let category, _): category.icon
        case .uncategorized: "tray.full.fill"
        }
    }

    var colorName: String {
        switch self {
        case .category(let category, _): category.colorName
        case .uncategorized: "blue"
        }
    }

    var habitCount: Int {
        switch self {
        case .category(_, let count): count
        case .uncategorized(let count): count
        }
    }

    var categoryID: UUID? {
        switch self {
        case .category(let category, _): category.id
        case .uncategorized: nil
        }
    }
}
