import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .habits

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.habits.title,
                systemImage: AppTab.habits.systemImage,
                value: .habits) {
                HabitsListView()
            }

            Tab(AppTab.settings.title,
                systemImage: AppTab.settings.systemImage,
                value: .settings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
