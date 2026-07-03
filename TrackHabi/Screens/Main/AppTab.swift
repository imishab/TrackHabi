import Foundation

enum AppTab: Int, Hashable, Identifiable, CaseIterable {

    case habits
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .habits:   "Habits"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .habits:   "checklist"
        case .settings: "gearshape"
        }
    }
}
