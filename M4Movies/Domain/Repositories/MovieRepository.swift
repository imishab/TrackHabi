import Foundation

protocol MovieRepository {

    func fetchPopularMovies(page: Int) async throws -> PagedMovies
    func searchMovies(query: String) async throws -> [Movie]
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
}
