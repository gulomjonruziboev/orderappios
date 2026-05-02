import Foundation

final class NewsRepository: @unchecked Sendable {
    private let api: OrderAPIClient

    init(api: OrderAPIClient) {
        self.api = api
    }

    /// Mirrors NewsRepository.kt — errors become empty list.
    func news() async -> [NewsDTO] {
        do {
            return try await api.getNews(page: 1, limit: 24).news
        } catch {
            return []
        }
    }
}
