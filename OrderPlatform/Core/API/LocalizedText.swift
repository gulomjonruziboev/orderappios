import Foundation

/// Mirrors `LocalizedTextDto` + `pick()` in orderandroid LocalizedTextDto.kt
struct LocalizedText: Codable, Equatable, Sendable {
    let uz: String?
    let ru: String?
    let en: String?
}

extension LocalizedText? {
    func pick(languageCode: String) -> String {
        guard let self else { return "" }
        switch languageCode {
        case "ru":
            return (ru ?? en ?? uz).map { String($0) } ?? ""
        case "uz":
            return (uz ?? en ?? ru).map { String($0) } ?? ""
        default:
            return (en ?? uz ?? ru).map { String($0) } ?? ""
        }
    }
}

enum AppLocale {
    /// Matches Android LocalizedNames: first locale language tag, else default.
    static var languageCode: String {
        if let code = Locale.current.language.languageCode?.identifier {
            return code
        }
        return Locale.current.identifier.split(separator: "_").first.map(String.init) ?? "en"
    }
}
