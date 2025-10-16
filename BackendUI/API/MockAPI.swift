import Foundation

enum MockAPI {
    enum Endpoint {
        case swiftDataBlog
        case videoPage
        case interactiveForm
        
        var filename: String {
            switch self {
            case .swiftDataBlog:
                return "swiftdata_blog"
            case .videoPage:
                return "video_page"
            case .interactiveForm:
                return "interactive_form"
            }
        }
    }
    
    static func fetch(_ endpoint: Endpoint) throws -> Data {
        guard let url = Bundle.main.url(forResource: endpoint.filename, withExtension: "json") else {
            throw APIError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return data
    }

    static func fetchPageContent(_ endpoint: Endpoint) throws -> ScreenContent {
        let data = try fetch(endpoint)
        let decoder = JSONDecoder()
        return try decoder.decode(ScreenContent.self, from: data)
    }
}

enum APIError: Error {
    case fileNotFound
    case decodingError
}
