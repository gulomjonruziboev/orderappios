import Foundation

struct NewsDTO: Codable, Equatable, Sendable {
    let mongoId: String?
    let id: String?
    let title: LocalizedText?
    let summary: LocalizedText?
    let content: LocalizedText?
    let image: String?
    let images: [String]?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case id, title, summary, content, image, images, createdAt
    }

    func resolvedId() -> String {
        if let id, !id.isEmpty { return id }
        return mongoId ?? ""
    }

    func primaryImagePath() -> String? {
        image ?? images?.first
    }

    var identity: String { resolvedId() }
}
