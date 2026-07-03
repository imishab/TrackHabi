import SwiftUI

struct HabitsListView: View {

    @State private var viewModel = HabitsViewModel()
    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.todaysHabits.isEmpty {
                    ContentUnavailableView(
                        "No Habits Yet",
                        systemImage: "checklist",
                        description: Text("Tap + to add your first habit.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(viewModel.todaysHabits) { habit in
                                NavigationLink(value: habit) {
                                    HabitRow(
                                        habit: habit,
                                        isCompleted: viewModel.isCompletedToday(habit),
                                        onToggle: { viewModel.toggleToday(habit) }
                                    )
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.delete(viewModel.todaysHabits[index])
                                }
                            }
                        } header: {
                            Text("Today")
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit, onChange: viewModel.load)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView { viewModel.load() }
            }
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
                viewModel.load()
            }
        }
    }
}

#Preview {
    HabitsListView()
}
