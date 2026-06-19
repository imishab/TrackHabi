import Foundation

@MainActor
@Observable
final class HomeViewModel {

    var movies: [Movie] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var refreshError: String?
    var loadMoreError: String?

    private let repository: MovieRepository
    private var currentPage = 0
    private var totalPages = 1
    private var prefetchTriggerID: Movie.ID?

    private let prefetchOffset = 5

    init(repository: MovieRepository = MovieRepositoryImpl()) {
        self.repository = repository
    }

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func loadMovies() async {
        guard movies.isEmpty else { return }
        isLoading = true
        await fetchInitialPage(isRefresh: false)
        isLoading = false
    }

    func refresh() async {
        await fetchInitialPage(isRefresh: true)
    }

    func retry() async {
        errorMessage = nil
        isLoading = true
        await fetchInitialPage(isRefresh: false)
        isLoading = false
    }

    func loadMoreIfNeeded(currentItem: Movie) async {
        guard currentItem.id == prefetchTriggerID,
              !isLoadingMore,
              !isLoading,
              hasMorePages,
              loadMoreError == nil
        else { return }
        await fetchNextPage()
    }

    func retryLoadMore() async {
        loadMoreError = nil
        await fetchNextPage()
    }

    private func fetchInitialPage(isRefresh: Bool) async {
        do {
            let result = try await repository.fetchPopularMovies(page: 1)
            movies = result.movies
            currentPage = result.page
            totalPages = result.totalPages
            errorMessage = nil
            refreshError = nil
            loadMoreError = nil
            updatePrefetchTrigger()
        } catch {
            if isRefresh && !movies.isEmpty {
                refreshError = "Couldn't refresh movies. Please try again."
            } else {
                errorMessage = "Failed to load movies. Please try again."
            }
        }
    }

    private func fetchNextPage() async {
        guard hasMorePages else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let result = try await repository.fetchPopularMovies(page: currentPage + 1)
            movies.append(contentsOf: result.movies)
            currentPage = result.page
            totalPages = result.totalPages
            loadMoreError = nil
            updatePrefetchTrigger()
        } catch {
            loadMoreError = "Couldn't load more. Tap to retry."
        }
    }

    private func updatePrefetchTrigger() {
        let triggerIndex = max(0, movies.count - prefetchOffset)
        prefetchTriggerID = movies.indices.contains(triggerIndex) ? movies[triggerIndex].id : nil
    }
}
