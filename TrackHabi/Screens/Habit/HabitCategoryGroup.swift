import Foundation

struct HabitCategoryGroup: Identifiable {
    let card: CategoryCard
    let habits: [Habit]

    var id: String { card.id }
}
