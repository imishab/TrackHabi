import Foundation

final class MovieRepositoryImpl: MovieRepository {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchPopularMovies(page: Int) async throws -> PagedMovies {
        let response: MovieListResponseDTO = try await apiClient.request(
            endpoint: .popularMovies(page: page)
        )
        return PagedMovies(
            movies: response.results.map { $0.toDomain() },
            page: response.page,
            totalPages: response.totalPages
        )
    }

    func searchMovies(query: String) async throws -> [Movie] {
        let response: MovieListResponseDTO = try await apiClient.request(
            endpoint: .search(query: query)
        )
        return response.results.map { $0.toDomain() }
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let response: MovieDetailsDTO = try await apiClient.request(
            endpoint: .details(id: id)
        )
        return response.toDomain()
    }
}
