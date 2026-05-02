import Foundation

/// `category` may be a string or populated object — see CategoryIdJsonAdapter.kt
struct FoodDTO: Codable, Equatable, Sendable {
    let mongoId: String?
    let id: String?
    let name: LocalizedText?
    let description: LocalizedText?
    let category: String?
    let ingredients: [String]?
    let price: Double?
    let image: String?
    let images: [String]?
    let isPopular: Bool?

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case id, name, description, category, ingredients, price, image, images, isPopular
    }

    init(
        mongoId: String?,
        id: String?,
        name: LocalizedText?,
        description: LocalizedText?,
        category: String?,
        ingredients: [String]?,
        price: Double?,
        image: String?,
        images: [String]?,
        isPopular: Bool?
    ) {
        self.mongoId = mongoId
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.ingredients = ingredients
        self.price = price
        self.image = image
        self.images = images
        self.isPopular = isPopular
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        mongoId = try c.decodeIfPresent(String.self, forKey: .mongoId)
        id = try c.decodeIfPresent(String.self, forKey: .id)
        name = try c.decodeIfPresent(LocalizedText.self, forKey: .name)
        description = try c.decodeIfPresent(LocalizedText.self, forKey: .description)
        ingredients = try c.decodeIfPresent([String].self, forKey: .ingredients)
        price = try c.decodeIfPresent(Double.self, forKey: .price)
        image = try c.decodeIfPresent(String.self, forKey: .image)
        images = try c.decodeIfPresent([String].self, forKey: .images)
        isPopular = try c.decodeIfPresent(Bool.self, forKey: .isPopular)

        if let s = try? c.decode(String.self, forKey: .category) {
            category = s
        } else if let nested = try? c.decode(CategoryIdObject.self, forKey: .category) {
            category = nested.id ?? nested.mongoId
        } else {
            category = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(mongoId, forKey: .mongoId)
        try c.encodeIfPresent(id, forKey: .id)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encodeIfPresent(category, forKey: .category)
        try c.encodeIfPresent(ingredients, forKey: .ingredients)
        try c.encodeIfPresent(price, forKey: .price)
        try c.encodeIfPresent(image, forKey: .image)
        try c.encodeIfPresent(images, forKey: .images)
        try c.encodeIfPresent(isPopular, forKey: .isPopular)
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

private struct CategoryIdObject: Codable {
    let mongoId: String?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case id
    }
}
