import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @Namespace private var transitionNamespace

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryPicker(
                    categories: MovieCategory.allCases,
                    selected: viewModel.selectedCategory,
                    onSelect: { viewModel.selectCategory($0) }
                )
                .padding(.top, 4)
                .padding(.bottom, 8)

                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("M4Movies")
                        .font(.title2.bold())
                }
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailsView(movie: movie)
                    .navigationTransition(.zoom(sourceID: movie.id, in: transitionNamespace))
            }
        }
        .task(id: viewModel.selectedCategory) {
            await viewModel.loadMovies()
        }
        .alert(
            "Couldn't Refresh",
            isPresented: refreshErrorPresented,
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.refreshError ?? "") }
        )
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.movies.isEmpty {
            MovieGridSkeleton(columns: columns)
        } else if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
            ErrorView(message: error) {
                Task { await viewModel.retry() }
            }
        } else {
            grid
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(value: movie) {
                        MovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: movie.id, in: transitionNamespace)
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded(currentItem: movie) }
                    }
                }

                if viewModel.isLoadingMore {
                    ForEach(0..<4, id: \.self) { _ in
                        MovieCardSkeleton()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoadingMore)

            LoadMoreFooter(
                errorMessage: viewModel.loadMoreError,
                hasMorePages: viewModel.hasMorePages,
                onRetry: { Task { await viewModel.retryLoadMore() } }
            )
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var refreshErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.refreshError != nil },
            set: { if !$0 { viewModel.refreshError = nil } }
        )
    }
}

// MARK: - Category Picker

private struct CategoryPicker: View {

    let categories: [MovieCategory]
    let selected: MovieCategory
    let onSelect: (MovieCategory) -> Void

    @Namespace private var underline

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    CategoryChip(
                        title: category.title,
                        isSelected: category == selected,
                        namespace: underline,
                        action: { onSelect(category) }
                    )
                }
            }
            .padding(.horizontal)
        }
        .scrollClipDisabled()
    }
}

private struct CategoryChip: View {

    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentColor)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    } else {
                        Capsule()
                            .fill(Color(.tertiarySystemBackground))
                            .overlay(
                                Capsule()
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Error View

private struct ErrorView: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
}
