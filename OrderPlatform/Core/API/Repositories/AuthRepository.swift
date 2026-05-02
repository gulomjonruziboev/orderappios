import Foundation

final class AuthRepository: @unchecked Sendable {
    private let api: OrderAPIClient
    private let tokenStorage: KeychainTokenStorage

    init(api: OrderAPIClient, tokenStorage: KeychainTokenStorage) {
        self.api = api
        self.tokenStorage = tokenStorage
    }

    func tokenStream() -> AsyncStream<String?> {
        tokenStorage.tokenStream()
    }

    func login(email: String, password: String) async throws {
        let res = try await api.login(LoginRequestDTO(email: email, password: password))
        guard let t = res.tokenValue() else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "no_token"])
        }
        tokenStorage.setToken(t)
    }

    func register(name: String, email: String, phone: String, password: String) async throws {
        let res = try await api.register(
            RegisterRequestDTO(name: name, email: email, phone: phone, password: password)
        )
        guard let token = res.tokenValue() else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "no_token"])
        }
        tokenStorage.setToken(token)
    }

    func logout() {
        tokenStorage.clearTokenOnly()
    }

    func isLoggedIn() -> Bool {
        tokenStorage.getToken() != nil
    }
}
