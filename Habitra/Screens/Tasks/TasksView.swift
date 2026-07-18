import SwiftUI

private enum TaskTab: String, CaseIterable, Identifiable {
    case todo = "Todo"
    case completed = "Completed"

    var id: String { rawValue }
}

struct TasksView: View {

    @State private var viewModel = TasksViewModel()
    @State private var selectedTab: TaskTab = .todo
    @State private var showingAddTask = false
    @State private var editingTask: TaskItem?
    @State private var router = NotificationRouter.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Tab", selection: $selectedTab) {
                    ForEach(TaskTab.allCases) { tab in
                        Text(tabLabel(tab)).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                content
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView { _ in
                    NotificationCenter.default.post(name: .taskDataDidChange, object: nil)
                }
            }
            .sheet(item: $editingTask) { task in
                AddTaskView(task: task) { _ in
                    NotificationCenter.default.post(name: .taskDataDidChange, object: nil)
                }
            }
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .taskDataDidChange)) { _ in
                viewModel.load()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                viewModel.load()
            }
            .onChange(of: router.pendingTaskID) { _, taskID in
                guard taskID != nil else { return }
                viewModel.load()
                router.pendingTaskID = nil
            }
        }
    }

    private var content: some View {
        TabView(selection: $selectedTab) {
            todoList
                .tag(TaskTab.todo)

            completedList
                .tag(TaskTab.completed)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    @ViewBuilder
    private var todoList: some View {
        if viewModel.todoSections.isEmpty {
            ContentUnavailableView(
                "No Tasks",
                systemImage: "checklist",
                description: Text("Tap + to add your first task.")
            )
        } else {
            List {
                ForEach(viewModel.todoSections) { section in
                    Section {
                        ForEach(section.tasks) { task in
                            taskRow(task)
                        }
                    } header: {
                        HStack {
                            Text(section.title)
                            Spacer()
                            Text("\(section.tasks.count)")
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var completedList: some View {
        if viewModel.completedTasks.isEmpty {
            ContentUnavailableView(
                "No Completed Tasks",
                systemImage: "checkmark.circle",
                description: Text("Tasks you finish will show up here.")
            )
        } else {
            List {
                ForEach(viewModel.completedTasks) { task in
                    taskRow(task)
                }
            }
        }
    }

    private func taskRow(_ task: TaskItem) -> some View {
        TaskRow(task: task, onToggle: { viewModel.toggle(task) })
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    editingTask = task
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.delete(task)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }

    private func tabLabel(_ tab: TaskTab) -> String {
        switch tab {
        case .todo:      viewModel.activeCount > 0 ? "\(tab.rawValue) (\(viewModel.activeCount))" : tab.rawValue
        case .completed: viewModel.completedCount > 0 ? "\(tab.rawValue) (\(viewModel.completedCount))" : tab.rawValue
        }
    }
}

extension Notification.Name {
    static let taskDataDidChange = Notification.Name("taskDataDidChange")
}

#Preview {
    TasksView()
}
