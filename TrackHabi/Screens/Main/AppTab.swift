import Foundation

enum AppTab: Int, Hashable, Identifiable, CaseIterable {

    case habits
    case days
    case add
    case analytics
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .habits:    "Habits"
        case .days:      "Days"
        case .add:       "Add"
        case .analytics: "Analytics"
        case .settings:  "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .habits:    "checklist"
        case .days:      "calendar"
        case .add:       "plus.circle.fill"
        case .analytics: "chart.bar.fill"
        case .settings:  "gearshape"
        }
    }
}
