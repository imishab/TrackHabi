import SwiftUI

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
        "gift.fill", "briefcase.fill", "graduationcap.fill", "pawprint.fill"
    ]

    static func color(named name: String) -> Color {
        switch name {
        case "green":  .green
        case "mint":   .mint
        case "orange": .orange
        case "pink":   .pink
        case "purple": .purple
        case "blue":   .blue
        case "yellow": .yellow
        case "red":    .red
        case "teal":   .teal
        case "indigo": .indigo
        case "cyan":   .cyan
        case "brown":  .brown
        default:       .mint
        }
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
