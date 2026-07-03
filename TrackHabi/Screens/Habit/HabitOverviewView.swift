import SwiftUI

struct HabitOverviewView: View {

    @State private var viewModel = HabitOverviewViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                dateStrip

                Divider()

                if viewModel.groupedHabits.isEmpty {
                    ContentUnavailableView(
                        "No Habits",
                        systemImage: "checklist",
                        description: Text("Nothing scheduled for this day.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.groupedHabits) { group in
                            Section {
                                ForEach(group.habits) { habit in
                                    HabitRow(
                                        habit: habit,
                                        isCompleted: viewModel.isCompleted(habit),
                                        isEnabled: viewModel.isEnabled(habit),
                                        onToggle: { viewModel.toggle(habit) }
                                    )
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        NavigationLink(value: habit) {
                                            Label("Details", systemImage: "info.circle")
                                        }
                                        .tint(.blue)
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        viewModel.delete(group.habits[index])
                                    }
                                }
                            } header: {
                                Label(group.card.name, systemImage: group.card.icon)
                                    .foregroundStyle(HabitPalette.color(named: group.card.colorName))
                            }
                        }
                    }
                }
            }
            .navigationTitle(dateTitle)
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

    private var dateTitle: String {
        if viewModel.calendar.isDateInToday(viewModel.selectedDate) {
            return "Today"
        }
        return viewModel.selectedDate.formatted(.dateTime.month(.abbreviated).day().year())
    }

    private var dateStrip: some View {
        DateStrip(
            dates: viewModel.visibleDates,
            selectedDate: viewModel.selectedDate,
            calendar: viewModel.calendar
        ) { date in
            viewModel.selectedDate = date
        }
    }
}

#Preview {
    HabitOverviewView()
}
