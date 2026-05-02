import Foundation

struct CategoryDTO: Codable, Equatable, Sendable {
    let mongoId: String?
    let id: String?
    let name: LocalizedText?
    let image: String?
    let slug: String?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case id, name, image, slug, order
    }

    func resolvedId() -> String {
        if let id, !id.isEmpty { return id }
        return mongoId ?? ""
    }

    /// Stable `ForEach` id (avoids conflict with optional `id` field).
    var identity: String { resolvedId() }
}
