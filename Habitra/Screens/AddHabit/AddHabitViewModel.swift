import Foundation

@Observable
@MainActor
final class AddHabitViewModel {

    var title: String
    var notes: String
    var icon: String
    var colorName: String
    var scheduledDays: Set<Weekday>
    var categories: [HabitCategory] = []
    var selectedCategoryID: UUID?

    var isReminderEnabled: Bool
    var reminderTime: Date

    var isStartDateEnabled: Bool
    var startDate: Date

    var isEndDateEnabled: Bool
    var endDate: Date

    var error: Error?

    private let repository: HabitRepository
    private let categoryRepository: HabitCategoryRepository
    private let editingHabit: Habit?

    init(habit: Habit? = nil, repository: HabitRepository? = nil, categoryRepository: HabitCategoryRepository? = nil) {
        self.repository = repository ?? HabitRepositoryImpl()
        self.categoryRepository = categoryRepository ?? HabitCategoryRepositoryImpl()
        self.editingHabit = habit

        self.title = habit?.title ?? ""
        self.notes = habit?.notes ?? ""
        self.icon = habit?.icon ?? HabitPalette.icons[0]
        self.colorName = habit?.colorName ?? HabitPalette.colorNames[0]
        self.scheduledDays = habit?.scheduledDays ?? Set(Weekday.allCases)
        self.selectedCategoryID = habit?.categoryID

        self.isReminderEnabled = habit?.reminderTime != nil
        self.reminderTime = habit?.reminderTime ?? AddHabitViewModel.defaultReminderTime

        self.isStartDateEnabled = habit?.startDate != nil
        self.startDate = habit?.startDate ?? Date()

        self.isEndDateEnabled = habit?.endDate != nil
        self.endDate = habit?.endDate ?? Date()
    }

    var isEditing: Bool { editingHabit != nil }

    static var defaultReminderTime: Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !scheduledDays.isEmpty
    }

    var selectedCategory: HabitCategory? {
        categories.first { $0.id == selectedCategoryID }
    }

    func loadCategories() {
        do {
            categories = try categoryRepository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func categoryCreated(_ category: HabitCategory) {
        categories.append(category)
        selectedCategoryID = category.id
    }

    func toggleDay(_ day: Weekday) {
        if scheduledDays.contains(day) {
            scheduledDays.remove(day)
        } else {
            scheduledDays.insert(day)
        }
    }

    func save() -> Habit? {
        guard canSave else { return nil }
        let habit = Habit(
            id: editingHabit?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            colorName: colorName,
            scheduledDays: scheduledDays,
            reminderTime: isReminderEnabled ? reminderTime : nil,
            startDate: isStartDateEnabled ? startDate : nil,
            endDate: isEndDateEnabled ? endDate : nil,
            createdAt: editingHabit?.createdAt ?? Date(),
            isArchived: editingHabit?.isArchived ?? false,
            categoryID: selectedCategoryID
        )
        do {
            if isEditing {
                try repository.update(habit)
            } else {
                try repository.add(habit)
            }
            if habit.reminderTime != nil {
                Task {
                    let granted = await NotificationScheduler.shared.requestAuthorizationIfNeeded()
                    guard granted else { return }
                    AppSettingsStore.shared.notificationsEnabled = true
                    NotificationScheduler.shared.schedule(for: habit, username: UserProfileStore.shared.name)
                }
            } else {
                NotificationScheduler.shared.cancel(for: habit.id)
            }
            return habit
        } catch {
            self.error = error
            return nil
        }
    }
}
