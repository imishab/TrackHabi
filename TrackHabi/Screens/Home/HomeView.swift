import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var showingAddHabit = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.cards.isEmpty {
                    ContentUnavailableView(
                        "No Habits Yet",
                        systemImage: "square.grid.2x2",
                        description: Text("Tap + to add your first habit.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.cards) { card in
                                NavigationLink(value: card) {
                                    CategoryCardView(card: card)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: CategoryCard.self) { card in
                CategoryHabitsView(card: card)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView { NotificationCenter.default.post(name: .habitDataDidChange, object: nil) }
            }
            .task {
                viewModel.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitDataDidChange)) { _ in
                viewModel.load()
            }
        }
    }
}

private struct CategoryCardView: View {
    let card: CategoryCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(HabitPalette.color(named: card.colorName).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: card.icon)
                    .foregroundStyle(HabitPalette.color(named: card.colorName))
            }

            Text(card.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("\(card.habitCount) habit\(card.habitCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
