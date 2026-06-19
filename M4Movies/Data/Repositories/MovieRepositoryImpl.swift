import Foundation

final class MovieRepositoryImpl: MovieRepository {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        let response: MovieListResponseDTO = try await apiClient.request(
            endpoint: .popularMovies(page: page)
        )
        return response.results.map { $0.toDomain() }
    }

    func searchMovies(query: String) async throws -> [Movie] {
        let response: MovieListResponseDTO = try await apiClient.request(
            endpoint: .search(query: query)
        )
        return response.results.map { $0.toDomain() }
    }
}
