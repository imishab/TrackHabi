import SwiftUI

struct PrivacyPolicyView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy & Policy")
                    .font(.title3.weight(.bold))

                Text("Your data stays on your device.")
                    .font(.subheadline.weight(.semibold))

                Text("Habitra stores your habits, categories, completions, and profile information (name and email) locally on your device. This data is not uploaded to any server and is not shared with third parties.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Notifications")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 8)

                Text("If enabled, reminder notifications are scheduled locally on your device using Apple's notification framework and are never sent to an external service.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Deleting Your Data")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 8)

                Text("You can delete all habit data at any time from Settings. Uninstalling the app removes all locally stored data.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Privacy & Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
