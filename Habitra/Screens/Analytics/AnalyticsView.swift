import Charts
import SwiftUI

struct AnalyticsView: View {

    @State private var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habitAnalytics.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.bar",
                        description: Text("Add and complete habits to see your analytics.")
                    )
                } else {
                    List {
                        Section {
                            summaryGrid
                        }

                        Section("Last 7 Days") {
                            weeklyChart
                                .frame(height: 160)
                                .padding(.vertical, 8)
                        }

                        Section("Streaks") {
                            ForEach(viewModel.habitAnalytics) { entry in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(HabitPalette.color(named: entry.habit.colorName).opacity(0.2))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: entry.habit.icon)
                                            .font(.caption)
                                            .foregroundStyle(HabitPalette.color(named: entry.habit.colorName))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.habit.title)
                                            .font(.body.weight(.medium))
                                        Text("\(entry.stats.totalCompletions) total completions")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Label("\(entry.stats.currentStreak)", systemImage: "flame.fill")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.orange)
                                        Text("best \(entry.stats.bestStreak)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analytics")
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
                viewModel.load()
            }
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTile(title: "Today", value: "\(Int(viewModel.todayCompletionRate * 100))%", systemImage: "checkmark.circle.fill", tint: .mint)
            StatTile(title: "Best Streak", value: "\(viewModel.bestCurrentStreak)", systemImage: "flame.fill", tint: .orange)
            StatTile(title: "Active Habits", value: "\(viewModel.activeHabits.count)", systemImage: "checklist", tint: .blue)
            StatTile(title: "Total Done", value: "\(viewModel.totalCompletions)", systemImage: "star.fill", tint: .purple)
        }
        .padding(.vertical, 4)
    }

    private var weeklyChart: some View {
        Chart(viewModel.weeklyCompletionCounts, id: \.date) { entry in
            BarMark(
                x: .value("Day", entry.date, unit: .day),
                y: .value("Completed", entry.count)
            )
            .foregroundStyle(Color.accentColor.gradient)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.12)))
    }
}

#Preview {
    AnalyticsView()
}
