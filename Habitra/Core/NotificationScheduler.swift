import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler {

    static let shared = NotificationScheduler()

    static let habitIDKey = "habitID"
    static let taskIDKey = "taskID"

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "habit-reminder-"
    private let taskIdentifierPrefix = "task-due-"
    private let taskDueSoundFileName = "1.mp3"

    private init() {}

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    /// Cancels any existing reminders for the habit, then schedules new ones (one per scheduled weekday)
    /// if the habit has a reminder time set and is not archived. Fire-and-forget wrapper around the
    /// async implementation, kept sequential internally to avoid racing an add() with a stale cancel().
    func schedule(for habit: Habit, username: String) {
        Task { await scheduleAsync(for: habit, username: username) }
    }

    func cancel(for habitID: UUID) {
        Task { await cancelAsync(for: habitID) }
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    /// Cancels everything and reschedules from scratch for the given habits. Use when notifications
    /// are re-enabled globally, or as a startup safety-net resync.
    func rescheduleAll(habits: [Habit], username: String) {
        Task {
            cancelAll()
            for habit in habits {
                await scheduleAsync(for: habit, username: username)
            }
        }
    }

    private func scheduleAsync(for habit: Habit, username: String) async {
        await cancelAsync(for: habit.id)

        guard let reminderTime = habit.reminderTime, !habit.isArchived else { return }

        let time = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)

        let content = UNMutableNotificationContent()
        content.title = trimmedName.isEmpty ? "Habit Reminder" : "Hey \(trimmedName)"
        content.body = "It's time to complete \"\(habit.title)\""
        content.sound = sound(for: habit.reminderTone)
        content.userInfo = [Self.habitIDKey: habit.id.uuidString]

        for weekday in habit.scheduledDays {
            var components = DateComponents()
            components.hour = time.hour
            components.minute = time.minute
            components.weekday = weekday.rawValue

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: identifier(habitID: habit.id, weekday: weekday),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    /// Cancels any existing due reminder for the task, then schedules a one-time notification that fires
    /// at the task's due date, unless the task has no due date, is already completed, or the due date has passed.
    func scheduleDueReminder(for task: TaskItem, username: String) {
        Task { await scheduleTaskDueAsync(for: task, username: username) }
    }

    func cancelDueReminder(for taskID: UUID) {
        Task { await cancelTaskAsync(for: taskID) }
    }

    private func scheduleTaskDueAsync(for task: TaskItem, username: String) async {
        await cancelTaskAsync(for: task.id)

        guard let dueDate = task.dueDate, !task.isCompleted, dueDate > Date() else { return }

        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)

        let content = UNMutableNotificationContent()
        content.title = trimmedName.isEmpty ? "Task Due" : "Hey \(trimmedName)"
        content.body = "\"\(task.title)\" is due now"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(taskDueSoundFileName))
        content.userInfo = [Self.taskIDKey: task.id.uuidString]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: taskIdentifier(taskID: task.id),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    private func cancelTaskAsync(for taskID: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [taskIdentifier(taskID: taskID)])
    }

    private func taskIdentifier(taskID: UUID) -> String {
        "\(taskIdentifierPrefix)\(taskID.uuidString)"
    }

    private func cancelAsync(for habitID: UUID) async {
        let prefix = identifierPrefix + habitID.uuidString
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        guard !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func identifier(habitID: UUID, weekday: Weekday) -> String {
        "\(identifierPrefix)\(habitID.uuidString)-\(weekday.rawValue)"
    }

    private func sound(for tone: ReminderTone) -> UNNotificationSound {
        guard let fileName = tone.soundFileName else { return .default }
        return UNNotificationSound(named: UNNotificationSoundName(fileName))
    }
}
