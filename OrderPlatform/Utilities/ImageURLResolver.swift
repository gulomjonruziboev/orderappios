import Foundation

enum ImageURLResolver {
    static func url(path: String?, origin: String = APIConfig.originString) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        let base = origin.hasSuffix("/") ? String(origin.dropLast()) : origin
        let p = path.hasPrefix("/") ? path : "/" + path
        return URL(string: base + p)
    }
}
