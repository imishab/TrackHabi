import Foundation

enum Endpoint {

    case popularMovies(page: Int)
    case search(query: String, page: Int)
    case details(id: Int)
}

extension Endpoint {

    var url: URL? {

        switch self {

        case .popularMovies(let page):

            return URL(
                string:
                "\(Config.baseURL)/movie/popular?api_key=\(Config.apiKey)&page=\(page)"
            )

        case .search(let query, let page):

            let encoded =
            query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? ""

            return URL(
                string:
                "\(Config.baseURL)/search/movie?api_key=\(Config.apiKey)&query=\(encoded)&page=\(page)&include_adult=false"
            )

        case .details(let id):

            return URL(
                string:
                "\(Config.baseURL)/movie/\(id)?api_key=\(Config.apiKey)"
            )
        }
    }
}
