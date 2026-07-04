import Foundation

@Observable
@MainActor
final class EditProfileViewModel {

    var name: String
    var email: String

    private let store: UserProfileStore

    init(store: UserProfileStore? = nil) {
        self.store = store ?? .shared
        self.name = self.store.name
        self.email = self.store.email
    }

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#)
        return predicate.evaluate(with: trimmed)
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isEmailValid
    }

    func save() {
        guard canSave else { return }
        store.save(name: name, email: email)
    }
}
