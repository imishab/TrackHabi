import SwiftUI

struct TaskRow: View {

    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: toggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? task.priority.color : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if task.dueDate != nil || !task.isCompleted {
                    HStack(spacing: 6) {
                        if let dueDate = task.dueDate {
                            Label(dueDateLabel(dueDate), systemImage: "calendar")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(task.isOverdue ? .red : .secondary)
                        }

                        if task.isOverdue {
                            Text("Due")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.red.opacity(0.15)))
                                .foregroundStyle(.red)
                        }

                        if !task.isCompleted {
                            Text(task.priority.displayName)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(task.priority.color.opacity(0.15)))
                                .foregroundStyle(task.priority.color)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: toggle)
    }

    private func toggle() {
        let willBeCompleted = !task.isCompleted
        onToggle()
        if willBeCompleted {
            CompletionFeedback.playComplete()
        } else {
            CompletionFeedback.playRemove()
        }
    }

    private func dueDateLabel(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today, \(date.formatted(.dateTime.hour().minute()))"
        }
        return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }
}
