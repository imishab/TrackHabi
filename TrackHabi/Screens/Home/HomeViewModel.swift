import Foundation

@Observable
@MainActor
final class HomeViewModel {

    private(set) var categories: [HabitCategory] = []
    private(set) var habits: [Habit] = []
    var error: Error?

    private let categoryRepository: HabitCategoryRepository
    private let habitRepository: HabitRepository

    init(categoryRepository: HabitCategoryRepository? = nil, habitRepository: HabitRepository? = nil) {
        self.categoryRepository = categoryRepository ?? HabitCategoryRepositoryImpl()
        self.habitRepository = habitRepository ?? HabitRepositoryImpl()
    }

    var cards: [CategoryCard] {
        var result = categories.compactMap { category -> CategoryCard? in
            let count = habits.filter { !$0.isArchived && $0.categoryID == category.id }.count
            guard count > 0 else { return nil }
            return .category(category, count: count)
        }

        let uncategorizedCount = habits.filter { !$0.isArchived && $0.categoryID == nil }.count
        if uncategorizedCount > 0 {
            result.append(.uncategorized(count: uncategorizedCount))
        }

        return result
    }

    func load() {
        do {
            categories = try categoryRepository.fetchAll()
            habits = try habitRepository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func habits(for card: CategoryCard) -> [Habit] {
        habits
            .filter { !$0.isArchived && $0.categoryID == card.categoryID }
            .sorted { $0.createdAt < $1.createdAt }
    }
}
