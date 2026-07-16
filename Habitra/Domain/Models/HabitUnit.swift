import Foundation

/// Preset units offered when a counter habit tracks something other than plain repetitions,
/// e.g. "Drink 2 L of water" or "Walk 5 km".
enum HabitUnit: String, CaseIterable, Identifiable {
    case times = ""
    case steps = "steps"
    case reps = "reps"
    case rounds = "rounds"
    case glasses = "glasses"
    case cups = "cups"
    case liters = "L"
    case milliliters = "ml"
    case kilometers = "km"
    case miles = "mi"
    case minutes = "min"
    case pages = "pages"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .times: "Times"
        case .steps: "Steps"
        case .reps: "Reps"
        case .rounds: "Rounds"
        case .glasses: "Glasses"
        case .cups: "Cups"
        case .liters: "Liters (L)"
        case .milliliters: "Milliliters (ml)"
        case .kilometers: "Kilometers (km)"
        case .miles: "Miles (mi)"
        case .minutes: "Minutes"
        case .pages: "Pages"
        }
    }
}
