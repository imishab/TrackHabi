import SwiftUI

struct HabitRow: View {

    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(HabitPalette.color(named: habit.colorName).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: habit.icon)
                    .foregroundStyle(HabitPalette.color(named: habit.colorName))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.body.weight(.medium))
                Text(habit.isDaily ? "Every day" : scheduleSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? HabitPalette.color(named: habit.colorName) : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .sensoryFeedback(.impact(weight: .medium), trigger: isCompleted)
        .onChange(of: isCompleted) { _, newValue in
            if newValue {
                CompletionFeedback.playComplete()
            } else {
                CompletionFeedback.playRemove()
            }
        }
    }

    private var scheduleSummary: String {
        Weekday.allCases
            .filter { habit.scheduledDays.contains($0) }
            .map(\.shortLabel)
            .joined(separator: ", ")
    }
}
