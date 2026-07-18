import SwiftUI

struct TasksView: View {

    @State private var viewModel = TasksViewModel()
    @State private var showingAddTask = false
    @State private var editingTask: TaskItem?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks Yet",
                        systemImage: "checklist",
                        description: Text("Tap + to add your first task.")
                    )
                } else {
                    List {
                        ForEach(viewModel.sections) { section in
                            Section {
                                ForEach(section.tasks) { task in
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
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if viewModel.activeCount > 0 {
                        Text("\(viewModel.activeCount) task\(viewModel.activeCount == 1 ? "" : "s") left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
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
        }
    }
}

extension Notification.Name {
    static let taskDataDidChange = Notification.Name("taskDataDidChange")
}

#Preview {
    TasksView()
}
