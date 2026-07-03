import SwiftUI
import UserNotifications

@main
struct TrackHabiApp: App {

    @State private var showSplash = true
    @State private var settings = AppSettingsStore.shared

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
            .task {
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
            .task {
                guard settings.notificationsEnabled else { return }
                let habits = (try? HabitRepositoryImpl().fetchAll()) ?? []
                NotificationScheduler.shared.rescheduleAll(habits: habits, username: UserProfileStore.shared.name)
            }
        }
    }
}
