import SwiftUI
import UIKit

enum HabitPalette {

    static let colorNames = [
        "green", "mint", "orange", "pink", "purple", "blue",
        "yellow", "red", "teal", "indigo", "cyan", "brown"
    ]

    static let icons = [
        "checkmark.circle", "drop.fill", "figure.run", "book.fill",
        "bed.double.fill", "leaf.fill", "dumbbell.fill", "cup.and.saucer.fill",
        "pencil", "heart.fill", "moon.stars.fill", "flame.fill",
        "star.fill", "bicycle", "airplane", "gamecontroller.fill",
        "paintbrush.fill", "music.note", "camera.fill", "car.fill",
        "gift.fill", "briefcase.fill", "graduationcap.fill", "pawprint.fill",
        "fork.knife", "cart.fill", "bag.fill", "house.fill",
        "bolt.fill", "sun.max.fill", "cloud.fill", "snowflake",
        "tree.fill", "figure.walk", "figure.pool.swim", "sportscourt.fill",
        "basketball.fill", "soccerball", "guitars.fill", "headphones",
        "tv.fill", "film.fill", "newspaper.fill", "highlighter",
        "laptopcomputer", "desktopcomputer", "phone.fill", "message.fill",
        "envelope.fill", "person.2.fill", "hand.raised.fill", "brain.head.profile",
        "lungs.fill", "pills.fill", "stethoscope", "tooth.fill",
        "scissors", "wrench.and.screwdriver.fill", "paintpalette.fill", "ticket.fill",
        "map.fill", "globe", "sunrise.fill", "sunset.fill",
        "alarm.fill", "hourglass", "calendar", "checklist",
        "target", "trophy.fill", "medal.fill", "flag.fill",
        "banknote.fill", "chart.line.uptrend.xyaxis"
    ]

    /// Custom colors are stored as a hex string (e.g. "#FF3B30") instead of a palette name.
    static func isCustomColor(_ name: String) -> Bool {
        name.hasPrefix("#")
    }

    static func color(named name: String) -> Color {
        if isCustomColor(name) {
            return hexColor(name)
        }
        switch name {
        case "green":  return .green
        case "mint":   return .mint
        case "orange": return .orange
        case "pink":   return .pink
        case "purple": return .purple
        case "blue":   return .blue
        case "yellow": return .yellow
        case "red":    return .red
        case "teal":   return .teal
        case "indigo": return .indigo
        case "cyan":   return .cyan
        case "brown":  return .brown
        default:       return .mint
        }
    }

    static func hexColor(_ hex: String) -> Color {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString.removeAll { $0 == "#" }
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255
        return Color(red: r, green: g, blue: b)
    }

    static func hex(from color: Color) -> String {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /// Red -> orange -> yellow -> yellow-green -> green, interpolated by completion ratio (0...1).
    private static let completionStops: [(ratio: Double, r: Double, g: Double, b: Double)] = [
        (0.00, 1.000, 0.231, 0.188), // red          #FF3B30
        (0.25, 1.000, 0.584, 0.000), // orange       #FF9500
        (0.50, 1.000, 0.800, 0.000), // yellow       #FFCC00
        (0.75, 0.545, 0.765, 0.290), // yellow-green #8BC34A
        (1.00, 0.204, 0.780, 0.349)  // green        #34C759
    ]

    static func completionColor(for ratio: Double) -> Color {
        let clamped = min(max(ratio, 0), 1)
        guard let upperIndex = completionStops.firstIndex(where: { $0.ratio >= clamped }), upperIndex > 0 else {
            let stop = completionStops[0]
            return Color(red: stop.r, green: stop.g, blue: stop.b)
        }

        let lower = completionStops[upperIndex - 1]
        let upper = completionStops[upperIndex]
        let t = (clamped - lower.ratio) / (upper.ratio - lower.ratio)
        return Color(
            red: lower.r + (upper.r - lower.r) * t,
            green: lower.g + (upper.g - lower.g) * t,
            blue: lower.b + (upper.b - lower.b) * t
        )
    }

    /// GitHub-contribution-graph style: gray when nothing was done, increasingly saturated
    /// green as completion ratio (0...1) rises.
    static let heatmapLegendRatios: [Double] = [0, 0.25, 0.5, 0.75, 1.0]

    static func heatmapColor(for ratio: Double) -> Color {
        switch ratio {
        case ..<0.001:  Color.secondary.opacity(0.16)
        case ..<0.26:   Color.green.opacity(0.35)
        case ..<0.51:   Color.green.opacity(0.55)
        case ..<0.76:   Color.green.opacity(0.78)
        default:        Color.green
        }
    }
}
