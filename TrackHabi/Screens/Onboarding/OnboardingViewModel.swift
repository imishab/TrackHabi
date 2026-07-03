import Foundation

@Observable
@MainActor
final class OnboardingViewModel {

    var name: String = ""
    var email: String = ""

    private let store: UserProfileStore

    init(store: UserProfileStore? = nil) {
        self.store = store ?? .shared
    }

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#)
        return predicate.evaluate(with: trimmed)
    }

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isEmailValid
    }

    func submit() {
        guard canSubmit else { return }
        store.save(name: name, email: email)
    }
}
