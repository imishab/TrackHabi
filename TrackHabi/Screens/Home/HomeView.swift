import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var showingAddCategory = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habits.isEmpty {
                    ContentUnavailableView(
                        "No Habits Yet",
                        systemImage: "square.grid.2x2",
                        description: Text("Tap + to add your first habit.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            topStreakCard
                            todayCompletionCard
                            categorySlider
                            HStack(alignment: .top, spacing: 14) {
                                recentHabitsCard
                                habitTrackingCard
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(greetingTitle)
            .navigationDestination(for: CategoryCard.self) { card in
                CategoryHabitsView(card: card)
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView { _ in viewModel.load() }
            }
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
                viewModel.load()
            }
        }
    }

    private var greetingTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let period: String
        switch hour {
        case 0..<12:  period = "Good Morning"
        case 12..<17: period = "Good Afternoon"
        default:      period = "Good Evening"
        }

        let name = UserProfileStore.shared.name
        return name.isEmpty ? period : "\(period), \(name)"
    }

    // MARK: - Top Streak

    private var topStreakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("TOP STREAK")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text("\(viewModel.topStreak?.streak ?? 0)")
                        .font(.system(size: 34, weight: .bold))

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption.weight(.bold))
                        Text("days")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange))
                }

                if let habit = viewModel.topStreak?.habit {
                    Text(habit.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Complete a habit to start a streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: viewModel.topStreak?.habit.icon ?? "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(HabitPalette.color(named: viewModel.topStreak?.habit.colorName ?? "orange"))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Today Completion

    private var todayCompletionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S COMPLETION")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(viewModel.todayCompletedCount)")
                    .font(.system(size: 30, weight: .bold))
                Text("/ \(viewModel.todayScheduledCount) habits")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                let barCount = 36
                let filledCount = Int((viewModel.todayCompletionRatio * Double(barCount)).rounded())
                HStack(spacing: 3) {
                    ForEach(0..<barCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(index < filledCount ? Color.mint : Color.secondary.opacity(0.2))
                            .frame(width: max((geo.size.width - CGFloat(barCount - 1) * 3) / CGFloat(barCount), 1))
                    }
                }
            }
            .frame(height: 28)

            Divider()

            HStack {
                statColumn(title: "COMPLETED", value: "\(viewModel.todayCompletedCount)")
                Spacer()
                statColumn(title: "REMAINING", value: "\(max(viewModel.todayScheduledCount - viewModel.todayCompletedCount, 0))")
                Spacer()
                statColumn(title: "TOTAL", value: "\(viewModel.todayScheduledCount)")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }

    // MARK: - Category Slider

    private var categorySlider: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORIES")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 2)

            if viewModel.cards.isEmpty {
                Button {
                    showingAddCategory = true
                } label: {
                    Label("Add Category", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.cards) { card in
                            NavigationLink(value: card) {
                                CategorySliderCard(card: card)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            showingAddCategory = true
                        } label: {
                            AddCategorySliderCard()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Recent Habits

    private var recentHabitsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT HABITS")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.recentHabits) { habit in
                    let completed = viewModel.isCompletedToday(habit)
                    HStack(spacing: 8) {
                        Image(systemName: completed ? "checkmark.square.fill" : "square")
                            .foregroundStyle(completed ? HabitPalette.color(named: habit.colorName) : .secondary)
                        Text(habit.title)
                            .font(.footnote)
                            .strikethrough(completed)
                            .foregroundStyle(completed ? .secondary : .primary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Habit Tracking Grid

    private var habitTrackingCard: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
        let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

        return VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("HABIT TRACKING")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(viewModel.monthTitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(viewModel.trackingDays) { day in
                    Circle()
                        .fill(color(for: day.status))
                        .frame(width: 10, height: 10)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func color(for status: TrackingDay.Status?) -> Color {
        switch status {
        case .completed: .green
        case .missed:     .red
        case .inactive:   Color.secondary.opacity(0.18)
        case nil:         .clear
        }
    }
}

private struct CategorySliderCard: View {
    let card: CategoryCard

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(HabitPalette.color(named: card.colorName).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: card.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(HabitPalette.color(named: card.colorName))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(card.habitCount) habit\(card.habitCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(width: 150, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

private struct AddCategorySliderCard: View {
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Text("Add Category")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(width: 150, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        )
    }
}

#Preview {
    HomeView()
}
