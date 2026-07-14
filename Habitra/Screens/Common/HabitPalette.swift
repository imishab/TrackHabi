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
}
