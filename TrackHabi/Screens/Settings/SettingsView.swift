import SwiftUI
import UserNotifications

struct SettingsView: View {

    @State private var showingClearConfirmation = false
    @State private var profile = UserProfileStore.shared
    @State private var settings = AppSettingsStore.shared
    private let repository: HabitRepository = HabitRepositoryImpl()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        profileRow
                    }
                }

                Section("Appearance") {
                    Toggle(isOn: $settings.isDarkMode) {
                        Label("Dark Mode", systemImage: settings.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                }

                Section {
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        Label("Change Username", systemImage: "person.text.rectangle")
                    }

                    Toggle(isOn: $settings.notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("Delete All Habits", systemImage: "trash")
                    }
                }

                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About Us", systemImage: "info.circle")
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy & Policy", systemImage: "hand.raised.fill")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
        }
        .onChange(of: settings.notificationsEnabled) { _, isEnabled in
            guard isEnabled else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if !granted {
                    Task { @MainActor in
                        settings.notificationsEnabled = false
                    }
                }
            }
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

    private var profileRow: some View {
        HStack(spacing: 14) {
            Image("user")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name.isEmpty ? "Your Name" : profile.name)
                    .font(.headline)
                if !profile.email.isEmpty {
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
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
