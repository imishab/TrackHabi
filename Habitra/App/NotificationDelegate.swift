import Foundation
import UserNotifications

@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()

    private override init() {}

    /// Show the banner + sound even while the app is in the foreground, and nudge any visible
    /// task list to refresh so overdue styling picks up immediately rather than on next reload.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let isTaskNotification = notification.request.content.userInfo[NotificationScheduler.taskIDKey] != nil
        if isTaskNotification {
            Task { @MainActor in
                NotificationCenter.default.post(name: .taskDataDidChange, object: nil)
            }
        }
        completionHandler([.banner, .sound, .badge])
    }

    /// Route to the tapped habit or task.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let habitIDString = userInfo[NotificationScheduler.habitIDKey] as? String
        let taskIDString = userInfo[NotificationScheduler.taskIDKey] as? String
        Task { @MainActor in
            if let habitIDString, let habitID = UUID(uuidString: habitIDString) {
                NotificationRouter.shared.pendingHabitID = habitID
            }
            if let taskIDString, let taskID = UUID(uuidString: taskIDString) {
                NotificationRouter.shared.pendingTaskID = taskID
                NotificationCenter.default.post(name: .taskDataDidChange, object: nil)
            }
            completionHandler()
        }
    }
}
