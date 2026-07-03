import SwiftUI

struct DaysView: View {

    @State private var viewModel = DaysViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                dateStrip

                Divider()

                if viewModel.habitsForSelectedDate.isEmpty {
                    ContentUnavailableView(
                        "No Habits",
                        systemImage: "calendar",
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
                        }
                    }
                }
            }
            .navigationTitle("Days")
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
                viewModel.load()
            }
        }
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
    DaysView()
}
