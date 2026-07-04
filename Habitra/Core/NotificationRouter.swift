import Foundation

/// Holds the habit a reminder notification was tapped for, so the UI can navigate to it.
@Observable
@MainActor
final class NotificationRouter {

    static let shared = NotificationRouter()

    var pendingHabitID: UUID?

    private init() {}
}
