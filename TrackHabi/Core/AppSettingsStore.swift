import Foundation

@Observable
@MainActor
final class AppSettingsStore {

    static let shared = AppSettingsStore()

    private let defaults: UserDefaults
    private let darkModeKey = "appSettings.isDarkMode"
    private let notificationsKey = "appSettings.notificationsEnabled"

    var isDarkMode: Bool {
        didSet { defaults.set(isDarkMode, forKey: darkModeKey) }
    }

    var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: notificationsKey) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isDarkMode = defaults.object(forKey: darkModeKey) as? Bool ?? true
        self.notificationsEnabled = defaults.object(forKey: notificationsKey) as? Bool ?? false
    }
}
