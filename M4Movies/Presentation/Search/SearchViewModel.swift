import Foundation

@MainActor
@Observable
final class SearchViewModel {

    enum Phase: Equatable {
        case idle
        case loading
        case results
        case noResults
        case error(String)
    }

    var phase: Phase = .idle
    var movies: [Movie] = []
    var isLoadingMore = false
    var loadMoreError: String?

    private let repository: MovieRepository
    private var searchTask: Task<Void, Never>?
    private var activeQuery = ""
    private var currentPage = 0
    private var totalPages = 1
    private var prefetchTriggerID: Movie.ID?

    private let debounce: Duration = .milliseconds(350)
    private let prefetchOffset = 5

    init(repository: MovieRepository = MovieRepositoryImpl()) {
        self.repository = repository
    }

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func onQueryChange(_ rawQuery: String) {
        searchTask?.cancel()

        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            reset()
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await runSearch(query: query, page: 1, isInitial: true)
        }
    }

    func loadMoreIfNeeded(currentItem: Movie) async {
        guard currentItem.id == prefetchTriggerID,
              !isLoadingMore,
              hasMorePages,
              loadMoreError == nil,
              !activeQuery.isEmpty
        else { return }
        await runSearch(query: activeQuery, page: currentPage + 1, isInitial: false)
    }

    func retryLoadMore() async {
        loadMoreError = nil
        await runSearch(query: activeQuery, page: currentPage + 1, isInitial: false)
    }

    func retry() async {
        guard !activeQuery.isEmpty else { return }
        await runSearch(query: activeQuery, page: 1, isInitial: true)
    }

    private func reset() {
        searchTask?.cancel()
        activeQuery = ""
        movies = []
        currentPage = 0
        totalPages = 1
        prefetchTriggerID = nil
        loadMoreError = nil
        phase = .idle
    }

    private func runSearch(query: String, page: Int, isInitial: Bool) async {
        if isInitial {
            activeQuery = query
            phase = .loading
        } else {
            isLoadingMore = true
        }
        defer { if !isInitial { isLoadingMore = false } }

        do {
            let result = try await repository.searchMovies(query: query, page: page)

            guard query == activeQuery else { return }

            if isInitial {
                movies = result.movies
            } else {
                movies.append(contentsOf: result.movies)
            }
            currentPage = result.page
            totalPages = result.totalPages
            updatePrefetchTrigger()

            phase = movies.isEmpty ? .noResults : .results
        } catch {
            guard query == activeQuery else { return }

            if isInitial {
                phase = .error("Couldn't perform search. Please try again.")
            } else {
                loadMoreError = "Couldn't load more. Tap to retry."
            }
        }
    }

    private func updatePrefetchTrigger() {
        let triggerIndex = max(0, movies.count - prefetchOffset)
        prefetchTriggerID = movies.indices.contains(triggerIndex) ? movies[triggerIndex].id : nil
    }
}
