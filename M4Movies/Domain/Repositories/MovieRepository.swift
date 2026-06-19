import Foundation

protocol MovieRepository {

    func fetchPopularMovies(page: Int) async throws -> [Movie]
    func searchMovies(query: String) async throws -> [Movie]
}
