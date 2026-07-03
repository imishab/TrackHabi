import Foundation

@Observable
@MainActor
final class UserProfileStore {

    static let shared = UserProfileStore()

    private let defaults: UserDefaults
    private let nameKey = "userProfile.name"
    private let emailKey = "userProfile.email"

    private(set) var name: String
    private(set) var email: String

    var hasCompletedOnboarding: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.name = defaults.string(forKey: nameKey) ?? ""
        self.email = defaults.string(forKey: emailKey) ?? ""
    }

    func save(name: String, email: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = trimmedName
        self.email = trimmedEmail
        defaults.set(trimmedName, forKey: nameKey)
        defaults.set(trimmedEmail, forKey: emailKey)
    }
}
