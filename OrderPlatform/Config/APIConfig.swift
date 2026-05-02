import Foundation

enum APIConfig {
    static var baseURLString: String {
        (Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String)
            ?? "https://order-platform-backend.onrender.com/api/"
    }

    static var originString: String {
        (Bundle.main.object(forInfoDictionaryKey: "APIOrigin") as? String)
            ?? "https://order-platform-backend.onrender.com"
    }

    static var baseURL: URL {
        URL(string: baseURLString)!
    }

    static var originURL: URL {
        URL(string: originString)!
    }
}
