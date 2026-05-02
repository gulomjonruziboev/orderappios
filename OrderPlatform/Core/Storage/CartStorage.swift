import Foundation

/// Mirrors CartLine in orderandroid CartStorage.kt
struct CartLine: Codable, Equatable, Identifiable, Sendable {
    var id: String { foodId }
    let foodId: String
    let nameSnapshot: String
    let unitPrice: Double
    let quantity: Int
    let imagePath: String?
}

final class CartStorage: @unchecked Sendable {
    private let defaults = UserDefaults.standard
    private let key = "order_cart_lines_json"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func loadLines() -> [CartLine] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? decoder.decode([CartLine].self, from: data)) ?? []
    }

    func saveLines(_ lines: [CartLine]) {
        if lines.isEmpty {
            defaults.removeObject(forKey: key)
        } else if let data = try? encoder.encode(lines) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
