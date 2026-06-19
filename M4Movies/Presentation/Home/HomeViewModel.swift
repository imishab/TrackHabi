import Foundation

@MainActor
@Observable
final class HomeViewModel {

    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?

    private let repository: MovieRepository
    private var currentPage = 1

    init(repository: MovieRepository = MovieRepositoryImpl()) {
        self.repository = repository
    }

    func loadMovies() async {
        isLoading = true
        errorMessage = nil

        do {
            movies = try await repository.fetchPopularMovies(page: currentPage)
        } catch {
            errorMessage = "Failed to load movies. Please try again."
        }

        isLoading = false
    }

    func retry() async {
        await loadMovies()
    }
}
