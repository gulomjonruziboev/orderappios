import Foundation

enum APIError: Error, Sendable {
    case invalidURL
    case unauthorized
    case httpStatus(Int)
    case decoding(Error)
    case emptyBody
}

/// Mirrors OrderApi.kt — URLSession + Codable.
final class OrderAPIClient: @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let tokenProvider: @Sendable () -> String?
    private let onUnauthorized: @Sendable () -> Void

    init(
        baseURL: URL = APIConfig.baseURL,
        session: URLSession = .shared,
        tokenProvider: @escaping @Sendable () -> String?,
        onUnauthorized: @escaping @Sendable () -> Void
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
        self.onUnauthorized = onUnauthorized
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        jsonDecoder = decoder
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        jsonEncoder = encoder
    }

    private func url(path: String, query: [String: String?] = [:]) -> URL? {
        guard var comp = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        else { return nil }
        let items = query.compactMap { key, value -> URLQueryItem? in
            guard let value, !value.isEmpty else { return nil }
            return URLQueryItem(name: key, value: value)
        }
        if !items.isEmpty {
            comp.queryItems = items
        }
        return comp.url
    }

    private func request(
        method: String,
        path: String,
        query: [String: String?] = [:]
    ) async throws -> Data {
        guard let url = url(path: path, query: query) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = tokenProvider(), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.httpStatus(-1) }
        if http.statusCode == 401 {
            onUnauthorized()
            throw APIError.unauthorized
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        return data
    }

    private func request<B: Encodable>(
        method: String,
        path: String,
        query: [String: String?] = [:],
        body: B
    ) async throws -> Data {
        guard let url = url(path: path, query: query) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = tokenProvider(), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = try jsonEncoder.encode(body)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.httpStatus(-1) }
        if http.statusCode == 401 {
            onUnauthorized()
            throw APIError.unauthorized
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        return data
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    // MARK: - OrderApi.kt

    func getCategories() async throws -> [CategoryDTO] {
        let data = try await request(method: "GET", path: "categories")
        return try decode([CategoryDTO].self, from: data)
    }

    func getCategory(id: String) async throws -> CategoryDTO {
        let data = try await request(method: "GET", path: "categories/\(id)")
        return try decode(CategoryDTO.self, from: data)
    }

    func getFoods(
        category: String? = nil,
        search: String? = nil,
        popular: Bool? = nil,
        page: Int? = nil,
        limit: Int? = nil
    ) async throws -> FoodsPageDTO {
        let data = try await request(
            method: "GET",
            path: "foods",
            query: [
                "category": category,
                "search": search,
                "popular": popular.map { $0 ? "true" : "false" },
                "page": page.map(String.init),
                "limit": limit.map(String.init),
            ]
        )
        return try decode(FoodsPageDTO.self, from: data)
    }

    func getFood(id: String) async throws -> FoodDTO {
        let data = try await request(method: "GET", path: "foods/\(id)")
        return try decode(FoodDTO.self, from: data)
    }

    func createOrder(_ body: CreateOrderRequestDTO) async throws -> CreateOrderResponseDTO {
        let data = try await request(method: "POST", path: "orders", body: body)
        return try decode(CreateOrderResponseDTO.self, from: data)
    }

    func getOrders(page: Int, limit: Int) async throws -> OrdersPageDTO {
        let data = try await request(
            method: "GET",
            path: "orders",
            query: ["page": String(page), "limit": String(limit)]
        )
        return try decode(OrdersPageDTO.self, from: data)
    }

    func getNews(page: Int, limit: Int) async throws -> NewsPageDTO {
        let data = try await request(
            method: "GET",
            path: "news",
            query: ["page": String(page), "limit": String(limit)]
        )
        return try decode(NewsPageDTO.self, from: data)
    }

    func login(_ body: LoginRequestDTO) async throws -> AuthResponseDTO {
        let data = try await request(method: "POST", path: "auth/login", body: body)
        return try decode(AuthResponseDTO.self, from: data)
    }

    func register(_ body: RegisterRequestDTO) async throws -> AuthResponseDTO {
        let data = try await request(method: "POST", path: "auth/register", body: body)
        return try decode(AuthResponseDTO.self, from: data)
    }
}
