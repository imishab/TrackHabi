import SwiftUI

struct CategoryHabitsView: View {

    @State private var viewModel: CategoryHabitsViewModel

    init(card: CategoryCard) {
        _viewModel = State(initialValue: CategoryHabitsViewModel(card: card))
    }

    var body: some View {
        Group {
            if viewModel.habits.isEmpty {
                ContentUnavailableView(
                    "No Habits",
                    systemImage: viewModel.card.icon,
                    description: Text("No habits in this category yet.")
                )
            } else {
                List {
                    ForEach(viewModel.habits) { habit in
                        HabitRow(
                            habit: habit,
                            isCompleted: viewModel.isCompletedToday(habit),
                            onToggle: { viewModel.toggleToday(habit) }
                        )
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            NavigationLink(value: habit) {
                                Label("Details", systemImage: "info.circle")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.card.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Habit.self) { habit in
            HabitDetailView(habit: habit, onChange: viewModel.load)
        }
        .task {
            viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
            viewModel.load()
        }
    }
}
