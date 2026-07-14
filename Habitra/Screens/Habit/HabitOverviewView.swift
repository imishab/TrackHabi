import SwiftUI

struct HabitOverviewView: View {

    @State private var viewModel = HabitOverviewViewModel()
    @State private var router = NotificationRouter.shared
    @State private var path = NavigationPath()
    @State private var collapsedGroupIDs: Set<String> = []

    var body: some View {
        NavigationStack(path: $path) {
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
                                if !isCollapsed(group) {
                                    ForEach(group.habits) { habit in
                                        HabitRow(
                                            habit: habit,
                                            isCompleted: viewModel.isCompleted(habit),
                                            isEnabled: viewModel.isEnabled(habit),
                                            date: viewModel.selectedDate,
                                            onToggle: { viewModel.toggle(habit) }
                                        )
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button {
                                                path.append(habit)
                                            } label: {
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
                                    .onMove { source, destination in
                                        viewModel.moveHabit(in: group, from: source, to: destination)
                                    }
                                }
                            } header: {
                                groupHeader(group)
                            }
                        }
                    }
                }
            }
            .navigationTitle(dateTitle)
            .toolbar {
                if !viewModel.groupedHabits.isEmpty {
                    EditButton()
                }
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit, onChange: viewModel.load)
            }
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
                viewModel.load()
            }
            .onChange(of: router.pendingHabitID) { _, habitID in
                guard let habitID, let habit = viewModel.habits.first(where: { $0.id == habitID }) else { return }
                path.append(habit)
                router.pendingHabitID = nil
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

    private func isCollapsed(_ group: HabitCategoryGroup) -> Bool {
        collapsedGroupIDs.contains(group.id)
    }

    private func toggleGroup(_ group: HabitCategoryGroup) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if collapsedGroupIDs.contains(group.id) {
                collapsedGroupIDs.remove(group.id)
            } else {
                collapsedGroupIDs.insert(group.id)
            }
        }
    }

    private func groupHeader(_ group: HabitCategoryGroup) -> some View {
        Button {
            toggleGroup(group)
        } label: {
            HStack {
                Label(group.card.name, systemImage: group.card.icon)
                    .foregroundStyle(HabitPalette.color(named: group.card.colorName))

                Spacer()

                Text("\(group.habits.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isCollapsed(group) ? -90 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HabitOverviewView()
}
