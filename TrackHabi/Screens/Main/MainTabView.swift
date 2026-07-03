import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .habits
    @State private var showingAddHabit = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.habits.title,
                systemImage: AppTab.habits.systemImage,
                value: .habits) {
                HabitsListView()
            }

            Tab(AppTab.days.title,
                systemImage: AppTab.days.systemImage,
                value: .days) {
                DaysView()
            }

            Tab(AppTab.add.title,
                systemImage: AppTab.add.systemImage,
                value: .add) {
                Color.clear
            }

            Tab(AppTab.analytics.title,
                systemImage: AppTab.analytics.systemImage,
                value: .analytics) {
                AnalyticsView()
            }

            Tab(AppTab.settings.title,
                systemImage: AppTab.settings.systemImage,
                value: .settings) {
                SettingsView()
            }
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
        .onChange(of: selectedTab) { previousTab, newTab in
            guard newTab == .add else { return }
            selectedTab = previousTab
            showingAddHabit = true
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView { NotificationCenter.default.post(name: .habitDataDidChange, object: nil) }
        }
    }
}

extension Notification.Name {
    static let habitDataDidChange = Notification.Name("habitDataDidChange")
}

#Preview {
    MainTabView()
}
