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
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    MovieGridSkeleton(columns: columns)
                } else if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.retry() }
                    }
                } else {
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
            }
            .navigationTitle("Popular Movies")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailsView(movie: movie)
                    .navigationTransition(.zoom(sourceID: movie.id, in: transitionNamespace))
            }
        }
        .task {
            await viewModel.loadMovies()
        }
        .alert(
            "Couldn't Refresh",
            isPresented: refreshErrorPresented,
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.refreshError ?? "") }
        )
    }

    private var refreshErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.refreshError != nil },
            set: { if !$0 { viewModel.refreshError = nil } }
        )
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
