import SwiftUI

enum TaskPriority: String, CaseIterable, Identifiable, Hashable, Comparable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low:    "Low"
        case .medium: "Medium"
        case .high:   "High"
        }
    }

    var color: Color {
        switch self {
        case .low:    .blue
        case .medium: .orange
        case .high:   .red
        }
    }

    private var sortWeight: Int {
        switch self {
        case .high:   0
        case .medium: 1
        case .low:    2
        }
    }

    static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.sortWeight < rhs.sortWeight
    }
}
