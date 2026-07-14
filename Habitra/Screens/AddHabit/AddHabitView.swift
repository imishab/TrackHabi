import SwiftUI
import UIKit

struct AddHabitView: View {

    @State private var viewModel: AddHabitViewModel
    @State private var showingAddCategory = false
    @Environment(\.dismiss) private var dismiss
    let onSave: (Habit) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 6)
    private let iconsPerPage = 12

    private var iconPages: [[String]] {
        stride(from: 0, to: HabitPalette.icons.count, by: iconsPerPage).map {
            Array(HabitPalette.icons[$0..<min($0 + iconsPerPage, HabitPalette.icons.count)])
        }
    }

    private var customColorBinding: Binding<Color> {
        Binding(
            get: { HabitPalette.color(named: viewModel.colorName) },
            set: { viewModel.colorName = HabitPalette.hex(from: $0) }
        )
    }

    init(habit: Habit? = nil, onSave: @escaping (Habit) -> Void) {
        _viewModel = State(initialValue: AddHabitViewModel(habit: habit))
        self.onSave = onSave
    }

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
                    TabView {
                        ForEach(Array(iconPages.enumerated()), id: \.offset) { _, page in
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(page, id: \.self) { icon in
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
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: iconPages.count > 1 ? .always : .never))
                    .frame(height: 140)
                    .listRowInsets(EdgeInsets())
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

                        ColorPicker("", selection: customColorBinding, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 32, height: 32)
                            .overlay {
                                if HabitPalette.isCustomColor(viewModel.colorName) {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                        .allowsHitTesting(false)
                                }
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
                                .background(Circle().fill(isOn ? HabitPalette.color(named: HabitPalette.colorNames[0]) : Color.secondary.opacity(0.15)))
                                .foregroundStyle(isOn ? .white : .primary)
                                .onTapGesture { viewModel.toggleDay(day) }
                        }
                    }
                }

                Section("Reminder") {
                    Toggle("Remind Me", isOn: $viewModel.isReminderEnabled.animation())
                        .onChange(of: viewModel.isReminderEnabled) { _, enabled in
                            viewModel.reminderToggled(enabled)
                        }
                    if viewModel.isReminderEnabled {
                        DatePicker("Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                        Picker("Sound", selection: $viewModel.reminderTone) {
                            ForEach(ReminderTone.allCases) { tone in
                                Text(tone.displayName).tag(tone)
                            }
                        }
                        .onChange(of: viewModel.reminderTone) { _, tone in
                            TonePlayer.shared.preview(tone)
                        }
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
            .navigationTitle(viewModel.isEditing ? "Edit Habit" : "New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let habit = viewModel.save() {
                            onSave(habit)
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
            .alert("Notifications Disabled", isPresented: $viewModel.showNotificationPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To get reminders, allow notifications for Habitra in Settings.")
            }
        }
    }
}

#Preview {
    AddHabitView(onSave: { _ in })
}
