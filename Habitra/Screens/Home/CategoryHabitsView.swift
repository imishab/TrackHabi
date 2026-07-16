import SwiftUI

struct CategoryHabitsView: View {

    @State private var viewModel: CategoryHabitsViewModel
    @State private var showingEditCategory = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

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
                            isEnabled: viewModel.isEnabled(habit),
                            date: viewModel.selectedDate,
                            count: viewModel.count(for: habit),
                            onToggle: { viewModel.toggle(habit) },
                            onIncrement: { viewModel.increment(habit) },
                            onDecrement: { viewModel.decrement(habit) }
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
        .toolbar {
            if viewModel.underlyingCategory != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditCategory = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditCategory) {
            AddCategoryView(category: viewModel.underlyingCategory) { updated in
                viewModel.categoryUpdated(updated)
                NotificationCenter.default.post(name: .habitDataDidChange, object: nil)
            }
        }
        .confirmationDialog(
            "Delete \(viewModel.card.name)?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                try? viewModel.deleteCategory()
                NotificationCenter.default.post(name: .habitDataDidChange, object: nil)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Habits in this category will become uncategorized.")
        }
        .task {
            viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
            viewModel.load()
        }
    }
}
