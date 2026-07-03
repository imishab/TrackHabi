import SwiftUI

struct HabitRow: View {

    let habit: Habit
    let isCompleted: Bool
    var isEnabled: Bool = true
    var date: Date = Date()
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
                Text(scheduleLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !isEnabled {
                    Text("Not today")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.orange)
                } else if isOverdue {
                    Text("Due")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isEnabled ? (isCompleted ? HabitPalette.color(named: habit.colorName) : .secondary) : Color.secondary.opacity(0.3))
        }
        .padding(.vertical, 4)
        .opacity(isEnabled ? 1 : 0.5)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            let willBeCompleted = !isCompleted
            onToggle()
            if willBeCompleted {
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

    private var scheduleLine: String {
        let days = habit.isDaily ? "Every day" : scheduleSummary
        guard let reminderTime = habit.reminderTime else { return days }
        return "\(days)  |  \(reminderTime.formatted(.dateTime.hour().minute()))"
    }

    private var isOverdue: Bool {
        guard isEnabled, !isCompleted, let reminderTime = habit.reminderTime else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let day = calendar.startOfDay(for: date)

        if day < today {
            return true
        }

        guard day == today else { return false }

        let reminderComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        guard let reminderToday = calendar.date(
            bySettingHour: reminderComponents.hour ?? 0,
            minute: reminderComponents.minute ?? 0,
            second: 0,
            of: today
        ) else {
            return false
        }
        return Date() > reminderToday
    }
}
