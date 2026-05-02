import Foundation
import Observation

@Observable
@MainActor
final class AppDependencies {
    let tokenStorage: KeychainTokenStorage
    let sessionManager: SessionManager
    let cartStore: CartStore
    let apiClient: OrderAPIClient
    let authRepository: AuthRepository
    let catalogRepository: CatalogRepository
    let orderRepository: OrderRepository
    let newsRepository: NewsRepository
    private(set) var authState: AuthState

    init() {
        let tokenStorage = KeychainTokenStorage()
        let sessionManager = SessionManager()
        let cartStore = CartStore()
        self.tokenStorage = tokenStorage
        self.sessionManager = sessionManager
        self.cartStore = cartStore
        let authState = AuthState(tokenStorage: tokenStorage)
        self.authState = authState

        let api = OrderAPIClient(
            tokenProvider: { tokenStorage.getToken() },
            onUnauthorized: {
                tokenStorage.clearTokenOnly()
                Task { @MainActor in
                    sessionManager.notifyUnauthorized()
                    authState.refresh()
                }
            }
        )
        apiClient = api
        authRepository = AuthRepository(api: api, tokenStorage: tokenStorage)
        catalogRepository = CatalogRepository(api: api)
        orderRepository = OrderRepository(api: api, cartStore: cartStore)
        newsRepository = NewsRepository(api: api)
    }

    func refreshAuth() {
        authState.refresh()
    }
}

@Observable
@MainActor
final class AuthState {
    private let tokenStorage: KeychainTokenStorage
    private(set) var isLoggedIn: Bool

    init(tokenStorage: KeychainTokenStorage) {
        self.tokenStorage = tokenStorage
        isLoggedIn = tokenStorage.getToken() != nil
    }

    func refresh() {
        isLoggedIn = tokenStorage.getToken() != nil
    }
}
