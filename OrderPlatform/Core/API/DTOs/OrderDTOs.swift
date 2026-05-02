import Foundation

struct OrderItemRequestDTO: Codable, Sendable {
    let foodId: String
    let quantity: Int
    let price: Double
}

struct CreateOrderRequestDTO: Codable, Sendable {
    let items: [OrderItemRequestDTO]
    let totalPrice: Double
    let deliveryAddress: String?
    let customerName: String?
    let customerPhone: String
}

struct CreateOrderResponseDTO: Codable, Sendable {
    let mongoId: String?
    let id: String?
    let orderNumber: String?

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case id, orderNumber
    }

    func resolvedId() -> String {
        if let orderNumber, !orderNumber.isEmpty { return orderNumber }
        if let id, !id.isEmpty { return id }
        return mongoId ?? ""
    }
}

struct OrderSummaryDTO: Codable, Equatable, Sendable {
    let mongoId: String?
    let id: String?
    let orderNumber: String?
    let status: String?
    let total: Double?
    let totalPrice: Double?
    let createdAt: String?
    let items: [OrderLineDTO]?

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case id, orderNumber, status, total, totalPrice, createdAt, items
    }

    func resolvedId() -> String {
        if let id, !id.isEmpty { return id }
        return mongoId ?? ""
    }

    /// Mirrors OrderSummaryDto.resolvedTotal()
    func resolvedTotal() -> Double {
        if let totalPrice { return totalPrice }
        if let total { return total }
        return 0
    }

    var identity: String { resolvedId() }
}

struct OrderLineDTO: Codable, Equatable, Sendable {
    let foodId: String?
    let food: FoodDTO?
    let quantity: Int?
    let price: Double?
}
