import Foundation

enum ReminderTone: String, CaseIterable, Identifiable, Hashable {
    case system
    case tone1
    case tone2
    case tone3
    case tone4

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "Default"
        case .tone1: return "Tone 1"
        case .tone2: return "Tone 2"
        case .tone3: return "Tone 3"
        case .tone4: return "Tone 4"
        }
    }

    /// Name of the bundled `.caf` file for this tone, or `nil` for the system default sound.
    var soundFileName: String? {
        self == .system ? nil : "\(rawValue).caf"
    }
}
