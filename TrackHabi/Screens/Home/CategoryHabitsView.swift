import SwiftUI

struct CategoryHabitsView: View {

    @State private var viewModel: CategoryHabitsViewModel

    init(card: CategoryCard) {
        _viewModel = State(initialValue: CategoryHabitsViewModel(card: card))
    }

    var body: some View {
        VStack(spacing: 0) {
            DateStrip(
                dates: viewModel.visibleDates,
                selectedDate: viewModel.selectedDate,
                calendar: viewModel.calendar
            ) { date in
                viewModel.selectedDate = date
            }

            Divider()

            if viewModel.habitsForSelectedDate.isEmpty {
                ContentUnavailableView(
                    "No Habits",
                    systemImage: viewModel.card.icon,
                    description: Text("Nothing scheduled for this day.")
                )
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.habitsForSelectedDate) { habit in
                        HabitRow(
                            habit: habit,
                            isCompleted: viewModel.isCompleted(habit),
                            onToggle: { viewModel.toggle(habit) }
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
