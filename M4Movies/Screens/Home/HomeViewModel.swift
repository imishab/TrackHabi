import Foundation

@MainActor
@Observable
final class HomeViewModel {

    var selectedCategory: MovieCategory = .popular
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

    func selectCategory(_ category: MovieCategory) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        resetForReload()
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

    private func resetForReload() {
        movies = []
        currentPage = 0
        totalPages = 1
        prefetchTriggerID = nil
        errorMessage = nil
        refreshError = nil
        loadMoreError = nil
        isLoading = true
    }

    private func fetchInitialPage(isRefresh: Bool) async {
        let category = selectedCategory
        do {
            let result = try await repository.fetchMovies(category: category, page: 1)
            guard category == selectedCategory else { return }

            movies = result.movies
            currentPage = result.page
            totalPages = result.totalPages
            errorMessage = nil
            refreshError = nil
            loadMoreError = nil
            updatePrefetchTrigger()
        } catch {
            guard category == selectedCategory else { return }
            if Task.isCancelled { return }
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

        let category = selectedCategory
        do {
            let result = try await repository.fetchMovies(category: category, page: currentPage + 1)
            guard category == selectedCategory else { return }

            movies.append(contentsOf: result.movies)
            currentPage = result.page
            totalPages = result.totalPages
            loadMoreError = nil
            updatePrefetchTrigger()
        } catch {
            guard category == selectedCategory else { return }
            if Task.isCancelled { return }
            loadMoreError = "Couldn't load more. Tap to retry."
        }
    }

    private func updatePrefetchTrigger() {
        let triggerIndex = max(0, movies.count - prefetchOffset)
        prefetchTriggerID = movies.indices.contains(triggerIndex) ? movies[triggerIndex].id : nil
    }
}
