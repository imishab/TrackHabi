import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .home
    @State private var showingAddChoice = false
    @State private var showingAddHabit = false
    @State private var showingAddTask = false
    @State private var pendingAddChoice: AddChoice?
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

            Tab(AppTab.tasks.title,
                image: AppTab.tasks.customImageName ?? AppTab.tasks.systemImage,
                value: .tasks) {
                TasksView()
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
            showingAddChoice = true
        }
        .sheet(isPresented: $showingAddChoice, onDismiss: presentPendingAddSheet) {
            AddChoiceSheet { choice in
                pendingAddChoice = choice
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView { _ in NotificationCenter.default.post(name: .habitDataDidChange, object: nil) }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView { _ in NotificationCenter.default.post(name: .taskDataDidChange, object: nil) }
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

    private func presentPendingAddSheet() {
        guard let choice = pendingAddChoice else { return }
        pendingAddChoice = nil
        switch choice {
        case .habit: showingAddHabit = true
        case .task:  showingAddTask = true
        }
    }
}

extension Notification.Name {
    static let habitDataDidChange = Notification.Name("habitDataDidChange")
}

#Preview {
    MainTabView()
}
