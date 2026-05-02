import Foundation

final class OrderRepository: @unchecked Sendable {
    private let api: OrderAPIClient
    private let cartStore: CartStore

    init(api: OrderAPIClient, cartStore: CartStore) {
        self.api = api
        self.cartStore = cartStore
    }

    func updateCart(lines: [CartLine]) {
        cartStore.setLines(lines)
    }

    func addOrMergeLine(_ line: CartLine) {
        var lines = cartStore.lines
        if let i = lines.firstIndex(where: { $0.foodId == line.foodId }) {
            let old = lines[i]
            lines[i] = CartLine(
                foodId: old.foodId,
                nameSnapshot: old.nameSnapshot,
                unitPrice: old.unitPrice,
                quantity: old.quantity + line.quantity,
                imagePath: old.imagePath
            )
        } else {
            lines.append(line)
        }
        cartStore.setLines(lines)
    }

    func clearCart() {
        cartStore.clear()
    }

    /// Mirrors OrderRepository.placeOrder (OrderRepository.kt)
    func placeOrder(
        phone: String,
        customerName: String?,
        address: String?,
        notes: String?
    ) async throws -> String {
        let lines = cartStore.lines
        if lines.isEmpty {
            throw NSError(domain: "Order", code: -1, userInfo: [NSLocalizedDescriptionKey: "empty_cart"])
        }
        let totalPrice = lines.reduce(0.0) { $0 + $1.unitPrice * Double($1.quantity) }
        var delivery = ""
        if let a = address?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty {
            delivery = a
        }
        if let n = notes?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            if !delivery.isEmpty { delivery += "\n" }
            delivery += "Notes: \(n)"
        }
        let deliveryAddress = delivery.isEmpty ? nil : delivery
        let trimmedName = customerName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = CreateOrderRequestDTO(
            items: lines.map {
                OrderItemRequestDTO(foodId: $0.foodId, quantity: $0.quantity, price: $0.unitPrice)
            },
            totalPrice: totalPrice,
            deliveryAddress: deliveryAddress,
            customerName: (trimmedName?.isEmpty == false) ? trimmedName : nil,
            customerPhone: phone
        )
        let res = try await api.createOrder(body)
        cartStore.clear()
        return res.resolvedId()
    }

    func orders() async throws -> [OrderSummaryDTO] {
        try await api.getOrders(page: 1, limit: 50).orders
    }
}
