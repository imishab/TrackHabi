import Foundation

enum Weekday: Int, CaseIterable, Codable, Hashable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .sunday:    "Sun"
        case .monday:    "Mon"
        case .tuesday:   "Tue"
        case .wednesday: "Wed"
        case .thursday:  "Thu"
        case .friday:    "Fri"
        case .saturday:  "Sat"
        }
    }

    static func from(date: Date, calendar: Calendar = .current) -> Weekday {
        Weekday(rawValue: calendar.component(.weekday, from: date)) ?? .sunday
    }

    static func mask(from days: Set<Weekday>) -> Int16 {
        days.reduce(Int16(0)) { $0 | (1 << Int16($1.rawValue - 1)) }
    }

    static func set(fromMask mask: Int16) -> Set<Weekday> {
        Set(Weekday.allCases.filter { mask & (1 << Int16($0.rawValue - 1)) != 0 })
    }
}
