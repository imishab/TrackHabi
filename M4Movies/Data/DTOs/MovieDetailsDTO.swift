import Foundation

struct MovieDetailsDTO: Codable {

    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let genres: [GenreDTO]
    let status: String
    let originalLanguage: String
    let homepage: String?
    let budget: Int
    let revenue: Int

    enum CodingKeys: String, CodingKey {
        case id, title, overview, tagline, runtime, genres, status, homepage, budget, revenue
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
    }
}

struct GenreDTO: Codable {

    let id: Int
    let name: String
}

extension MovieDetailsDTO {

    func toDomain() -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            originalTitle: originalTitle,
            overview: overview,
            tagline: tagline,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            runtime: runtime,
            voteAverage: voteAverage,
            voteCount: voteCount,
            genres: genres.map { Genre(id: $0.id, name: $0.name) },
            status: status,
            originalLanguage: originalLanguage,
            homepage: homepage,
            budget: budget,
            revenue: revenue
        )
    }
}
