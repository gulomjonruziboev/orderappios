import Foundation

struct FoodsPageDTO: Codable, Sendable {
    let foods: [FoodDTO]
    let total: Int?
    let page: Int?
    let pages: Int?

    enum CodingKeys: String, CodingKey {
        case foods, total, page, pages
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        foods = try c.decodeIfPresent([FoodDTO].self, forKey: .foods) ?? []
        total = try c.decodeIfPresent(Int.self, forKey: .total)
        page = try c.decodeIfPresent(Int.self, forKey: .page)
        pages = try c.decodeIfPresent(Int.self, forKey: .pages)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(foods, forKey: .foods)
        try c.encodeIfPresent(total, forKey: .total)
        try c.encodeIfPresent(page, forKey: .page)
        try c.encodeIfPresent(pages, forKey: .pages)
    }
}

struct NewsPageDTO: Codable, Sendable {
    let news: [NewsDTO]
    let total: Int?
    let page: Int?
    let pages: Int?

    enum CodingKeys: String, CodingKey {
        case news, total, page, pages
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        news = try c.decodeIfPresent([NewsDTO].self, forKey: .news) ?? []
        total = try c.decodeIfPresent(Int.self, forKey: .total)
        page = try c.decodeIfPresent(Int.self, forKey: .page)
        pages = try c.decodeIfPresent(Int.self, forKey: .pages)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(news, forKey: .news)
        try c.encodeIfPresent(total, forKey: .total)
        try c.encodeIfPresent(page, forKey: .page)
        try c.encodeIfPresent(pages, forKey: .pages)
    }
}

struct OrdersPageDTO: Codable, Sendable {
    let orders: [OrderSummaryDTO]
    let total: Int?
    let page: Int?
    let pages: Int?

    enum CodingKeys: String, CodingKey {
        case orders, total, page, pages
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        orders = try c.decodeIfPresent([OrderSummaryDTO].self, forKey: .orders) ?? []
        total = try c.decodeIfPresent(Int.self, forKey: .total)
        page = try c.decodeIfPresent(Int.self, forKey: .page)
        pages = try c.decodeIfPresent(Int.self, forKey: .pages)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(orders, forKey: .orders)
        try c.encodeIfPresent(total, forKey: .total)
        try c.encodeIfPresent(page, forKey: .page)
        try c.encodeIfPresent(pages, forKey: .pages)
    }
}
