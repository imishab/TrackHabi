import SwiftUI

struct SearchView: View {

    @State private var viewModel = SearchViewModel()
    @State private var query = ""
    @Namespace private var transitionNamespace

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search")
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailsView(movie: movie)
                        .navigationTransition(.zoom(sourceID: movie.id, in: transitionNamespace))
                }
        }
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search movies"
        )
        .onChange(of: query) { _, newValue in
            viewModel.onQueryChange(newValue)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle:
            EmptyState()
        case .loading:
            MovieGridSkeleton(columns: columns)
        case .results:
            resultsGrid
        case .noResults:
            ContentUnavailableView.search(text: query)
        case .error(let message):
            ErrorState(message: message) {
                Task { await viewModel.retry() }
            }
        }
    }

    private var resultsGrid: some View {
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
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Empty State

private struct EmptyState: View {

    var body: some View {
        ContentUnavailableView(
            "Search Movies",
            systemImage: "magnifyingglass",
            description: Text("Find movies by title, character, or keyword.")
        )
    }
}

// MARK: - Error State

private struct ErrorState: View {

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

            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchView()
}
