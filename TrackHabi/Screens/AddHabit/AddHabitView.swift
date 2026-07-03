import SwiftUI

struct AddHabitView: View {

    @State private var viewModel = AddHabitViewModel()
    @State private var showingAddCategory = false
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Drink Water", text: $viewModel.title)
                }

                Section("Description") {
                    TextField("Add a short note (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Icon") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(HabitPalette.icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle().fill(
                                        icon == viewModel.icon
                                            ? HabitPalette.color(named: viewModel.colorName).opacity(0.3)
                                            : Color.clear
                                    )
                                )
                                .onTapGesture { viewModel.icon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(HabitPalette.colorNames, id: \.self) { name in
                            Circle()
                                .fill(HabitPalette.color(named: name))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if name == viewModel.colorName {
                                        Circle().stroke(.white, lineWidth: 2)
                                    }
                                }
                                .onTapGesture { viewModel.colorName = name }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Category") {
                    Menu {
                        ForEach(viewModel.categories) { category in
                            Button {
                                viewModel.selectedCategoryID = category.id
                            } label: {
                                Label(category.name, systemImage: category.icon)
                            }
                        }

                        if !viewModel.categories.isEmpty {
                            Divider()
                        }

                        Button {
                            showingAddCategory = true
                        } label: {
                            Label("New Category", systemImage: "plus")
                        }
                    } label: {
                        HStack {
                            if let category = viewModel.selectedCategory {
                                Image(systemName: category.icon)
                                    .foregroundStyle(HabitPalette.color(named: category.colorName))
                                Text(category.name)
                                    .foregroundStyle(.primary)
                            } else {
                                Text("Select Category")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Repeat") {
                    HStack {
                        ForEach(Weekday.allCases) { day in
                            let isOn = viewModel.scheduledDays.contains(day)
                            Text(day.shortLabel.prefix(1))
                                .font(.caption.weight(.semibold))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(isOn ? HabitPalette.color(named: viewModel.colorName) : Color.secondary.opacity(0.15)))
                                .foregroundStyle(isOn ? .white : .primary)
                                .onTapGesture { viewModel.toggleDay(day) }
                        }
                    }
                }

                Section("Reminder") {
                    Toggle("Remind Me", isOn: $viewModel.isReminderEnabled.animation())
                    if viewModel.isReminderEnabled {
                        DatePicker("Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Start Date") {
                    Toggle("Set Start Date", isOn: $viewModel.isStartDateEnabled.animation())
                    if viewModel.isStartDateEnabled {
                        DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                    }
                }

                Section("End Date") {
                    Toggle("Set End Date", isOn: $viewModel.isEndDateEnabled.animation())
                    if viewModel.isEndDateEnabled {
                        DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() {
                            onSave()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView { category in
                    viewModel.categoryCreated(category)
                }
            }
            .task {
                viewModel.loadCategories()
            }
        }
    }
}

#Preview {
    AddHabitView(onSave: {})
}
