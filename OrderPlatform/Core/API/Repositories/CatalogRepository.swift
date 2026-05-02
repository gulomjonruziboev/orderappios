import Foundation

final class CatalogRepository: @unchecked Sendable {
    private let api: OrderAPIClient

    init(api: OrderAPIClient) {
        self.api = api
    }

    func categories() async throws -> [CategoryDTO] {
        try await api.getCategories()
    }

    func category(id: String) async throws -> CategoryDTO {
        try await api.getCategory(id: id)
    }

    func foods(
        categoryId: String? = nil,
        limit: Int? = nil,
        search: String? = nil,
        popular: Bool? = nil,
        page: Int? = nil
    ) async throws -> [FoodDTO] {
        try await api.getFoods(
            category: categoryId,
            search: search,
            popular: popular,
            page: page,
            limit: limit
        ).foods
    }

    func food(id: String) async throws -> FoodDTO {
        try await api.getFood(id: id)
    }
}
