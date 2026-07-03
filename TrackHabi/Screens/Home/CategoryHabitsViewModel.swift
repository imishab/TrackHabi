import Foundation

@Observable
@MainActor
final class CategoryHabitsViewModel {

    private(set) var habits: [Habit] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    var error: Error?

    let card: CategoryCard
    private let repository: HabitRepository
    private let today = Date()

    init(card: CategoryCard, repository: HabitRepository? = nil) {
        self.card = card
        self.repository = repository ?? HabitRepositoryImpl()
    }

    func load() {
        do {
            let all = try repository.fetchAll()
            habits = all
                .filter { !$0.isArchived && $0.categoryID == card.categoryID }
                .sorted { $0.createdAt < $1.createdAt }
            let completions = try repository.completions(on: today)
            completedHabitIDs = Set(completions.map(\.habitID))
        } catch {
            self.error = error
        }
    }

    func isCompletedToday(_ habit: Habit) -> Bool {
        completedHabitIDs.contains(habit.id)
    }

    func toggleToday(_ habit: Habit) {
        do {
            let isNowCompleted = try repository.toggleCompletion(habitID: habit.id, on: today)
            if isNowCompleted {
                completedHabitIDs.insert(habit.id)
            } else {
                completedHabitIDs.remove(habit.id)
            }
        } catch {
            self.error = error
        }
    }
}
