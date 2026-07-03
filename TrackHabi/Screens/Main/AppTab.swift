import Foundation

enum AppTab: Int, Hashable, Identifiable, CaseIterable {

    case home
    case habit
    case add
    case analytics
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:      "Home"
        case .habit:     "Habit"
        case .add:       "Add"
        case .analytics: "Analytic"
        case .settings:  "Setting"
        }
    }

    var systemImage: String {
        switch self {
        case .home:      "house.fill"
        case .habit:     "checklist"
        case .add:       "plus.circle.fill"
        case .analytics: "chart.bar.fill"
        case .settings:  "gearshape"
        }
    }

    /// Name of a custom vector asset in Assets.xcassets to use instead of `systemImage`, if any.
    var customImageName: String? {
        switch self {
        case .home:      "tab-home"
        case .habit:     "tab-habit"
        case .analytics: "tab-analytics"
        default:         nil
        }
    }
}
