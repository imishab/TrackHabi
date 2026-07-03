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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.visibleDates, id: \.self) { date in
                        DayChip(
                            date: date,
                            isSelected: viewModel.calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedDate = date
                            }
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .onAppear {
                proxy.scrollTo(viewModel.visibleDates.last, anchor: .trailing)
            }
        }
    }
}

private struct DayChip: View {

    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .secondary)
                Text(date.formatted(.dateTime.day()))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(width: 44, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
            )
            .overlay {
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.accentColor, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HabitOverviewView()
}
