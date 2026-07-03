import SwiftUI

struct SettingsView: View {

    @State private var showingClearConfirmation = false
    private let repository: HabitRepository = HabitRepositoryImpl()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("Delete All Habits", systemImage: "trash")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
        }
        .confirmationDialog(
            "Delete All Habits?",
            isPresented: $showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let habits = try? repository.fetchAll() {
                    for habit in habits {
                        try? repository.delete(id: habit.id)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all habits and their history. This cannot be undone.")
        }
    }

    private var appVersion: String {
        let dict = Bundle.main.infoDictionary
        let version = dict?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = dict?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
}
