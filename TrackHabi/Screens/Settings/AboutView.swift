import SwiftUI

struct AboutView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("TrackHabi")
                    .font(.title2.weight(.bold))

                Text("Version \(appVersion)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("TrackHabi helps you build lasting routines by making it simple to plan, track, and reflect on your daily habits — with streaks, categories, and clear progress at a glance.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        let dict = Bundle.main.infoDictionary
        let version = dict?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = dict?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
