import Foundation

@MainActor
@Observable
final class HomeViewModel {

    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?
    var refreshError: String?

    private let repository: MovieRepository
    private var currentPage = 1

    init(repository: MovieRepository = MovieRepositoryImpl()) {
        self.repository = repository
    }

    func loadMovies() async {
        guard movies.isEmpty else { return }
        isLoading = true
        await fetchFirstPage(isRefresh: false)
        isLoading = false
    }

    func refresh() async {
        await fetchFirstPage(isRefresh: true)
    }

    func retry() async {
        errorMessage = nil
        isLoading = true
        await fetchFirstPage(isRefresh: false)
        isLoading = false
    }

    private func fetchFirstPage(isRefresh: Bool) async {
        currentPage = 1
        do {
            movies = try await repository.fetchPopularMovies(page: currentPage)
            errorMessage = nil
            refreshError = nil
        } catch {
            if isRefresh && !movies.isEmpty {
                refreshError = "Couldn't refresh movies. Please try again."
            } else {
                errorMessage = "Failed to load movies. Please try again."
            }
        }
    }
}
