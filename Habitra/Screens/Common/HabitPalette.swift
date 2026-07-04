import SwiftUI

enum HabitPalette {

    static let colorNames = ["mint", "orange", "pink", "purple", "blue", "yellow", "red", "teal"]

    static let icons = [
        "checkmark.circle", "drop.fill", "figure.run", "book.fill",
        "bed.double.fill", "leaf.fill", "dumbbell.fill", "cup.and.saucer.fill",
        "pencil", "heart.fill", "moon.stars.fill", "flame.fill"
    ]

    static func color(named name: String) -> Color {
        switch name {
        case "mint":   .mint
        case "orange": .orange
        case "pink":   .pink
        case "purple": .purple
        case "blue":   .blue
        case "yellow": .yellow
        case "red":    .red
        case "teal":   .teal
        default:       .mint
        }
    }
}
