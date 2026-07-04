import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .home
    @State private var showingAddHabit = false
    @State private var showingOnboarding = !UserProfileStore.shared.hasCompletedOnboarding
    @State private var router = NotificationRouter.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.home.title,
                image: AppTab.home.customImageName ?? AppTab.home.systemImage,
                value: .home) {
                HomeView()
            }

            Tab(AppTab.habit.title,
                image: AppTab.habit.customImageName ?? AppTab.habit.systemImage,
                value: .habit) {
                HabitOverviewView()
            }

            Tab(AppTab.add.title,
                systemImage: AppTab.add.systemImage,
                value: .add) {
                Color.clear
            }

            Tab(AppTab.analytics.title,
                image: AppTab.analytics.customImageName ?? AppTab.analytics.systemImage,
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
            AddHabitView { _ in NotificationCenter.default.post(name: .habitDataDidChange, object: nil) }
        }
        .onChange(of: router.pendingHabitID) { _, habitID in
            guard habitID != nil else { return }
            selectedTab = .habit
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView {
                showingOnboarding = false
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
        }
    }
}

extension Notification.Name {
    static let habitDataDidChange = Notification.Name("habitDataDidChange")
}

#Preview {
    MainTabView()
}
