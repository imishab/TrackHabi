import Foundation

protocol MovieRepository {

    func fetchPopularMovies(page: Int) async throws -> PagedMovies
    func searchMovies(query: String, page: Int) async throws -> PagedMovies
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
}
