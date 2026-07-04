import SwiftUI

struct HabitDetailView: View {

    @State private var viewModel: HabitDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    @State private var showingEditHabit = false
    let onChange: () -> Void

    init(habit: Habit, onChange: @escaping () -> Void) {
        _viewModel = State(initialValue: HabitDetailViewModel(habit: habit))
        self.onChange = onChange
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                statsRow
                calendarGrid
            }
            .padding()
        }
        .navigationTitle(viewModel.habit.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditHabit = true
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
        .sheet(isPresented: $showingEditHabit) {
            AddHabitView(habit: viewModel.habit) { updated in
                viewModel.habitUpdated(updated)
                onChange()
            }
        }
        .confirmationDialog(
            "Delete \(viewModel.habit.title)?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                try? viewModel.delete()
                onChange()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            viewModel.load()
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(title: "Current Streak", value: "\(viewModel.stats.currentStreak)", icon: "flame.fill")
            statTile(title: "Best Streak", value: "\(viewModel.stats.bestStreak)", icon: "trophy.fill")
            statTile(title: "Total", value: "\(viewModel.stats.totalCompletions)", icon: "checkmark.seal.fill")
        }
    }

    private func statTile(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(HabitPalette.color(named: viewModel.habit.colorName))
            Text(value)
                .font(.title2.weight(.semibold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var calendarGrid: some View {
        let days = currentMonthDays()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

        return VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(days, id: \.self) { day in
                    let completed = viewModel.isCompleted(on: day)
                    let scheduled = viewModel.habit.isScheduled(on: day)
                    let isFuture = isFutureDay(day)
                    let isTappable = scheduled && !isFuture
                    Text(dayNumber(day))
                        .font(.caption2)
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    completed
                                        ? HabitPalette.color(named: viewModel.habit.colorName)
                                        : Color.secondary.opacity(scheduled ? 0.15 : 0.05)
                                )
                        )
                        .foregroundStyle(completed ? .white : .primary)
                        .opacity(isFuture ? 0.4 : 1)
                        .onTapGesture {
                            guard isTappable else { return }
                            let wasCompleted = completed
                            viewModel.toggle(day)
                            if !wasCompleted, viewModel.isCompleted(on: day) {
                                CompletionFeedback.playComplete()
                            } else if wasCompleted, !viewModel.isCompleted(on: day) {
                                CompletionFeedback.playRemove()
                            }
                        }
                }
            }
        }
    }

    private func currentMonthDays() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: today),
            let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count
        else {
            return [calendar.startOfDay(for: today)]
        }
        let firstOfMonth = monthInterval.start
        return (0..<daysInMonth).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstOfMonth)
        }
    }

    private func isFutureDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }

    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
