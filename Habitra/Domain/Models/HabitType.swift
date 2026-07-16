import Foundation

enum HabitType: String, Codable, CaseIterable, Identifiable {
    case task
    case counter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .task: "Tap to Complete"
        case .counter: "Counter"
        }
    }
}
