import Foundation
import UserNotifications

@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()

    private override init() {}

    /// Show the banner + sound even while the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Route to the tapped habit.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let habitIDString = response.notification.request.content.userInfo[NotificationScheduler.habitIDKey] as? String
        Task { @MainActor in
            if let habitIDString, let habitID = UUID(uuidString: habitIDString) {
                NotificationRouter.shared.pendingHabitID = habitID
            }
            completionHandler()
        }
    }
}
