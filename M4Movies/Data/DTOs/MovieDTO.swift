import Foundation

struct MovieDTO: Codable {

    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let release_date: String
    let vote_average: Double
}

extension MovieDTO {

    func toDomain() -> Movie {

        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: poster_path,
            releaseDate: release_date,
            voteAverage: vote_average
        )
    }
}