import SwiftUI

struct OrderAppShell: View {
    let deps: AppDependencies
    @State private var selectedTab = 0
    @State private var homePath = NavigationPath()
    @State private var categoriesPath = NavigationPath()
    @State private var cartPath = NavigationPath()
    @State private var accountPath = NavigationPath()
    @State private var showUnauthorizedLogin = false
    @State private var authPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView(deps: deps, path: $homePath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $homePath)
                    }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack(path: $categoriesPath) {
                CategoriesView(deps: deps, path: $categoriesPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $categoriesPath)
                    }
            }
            .tabItem { Label("Categories", systemImage: "square.grid.2x2") }
            .tag(1)

            NavigationStack(path: $cartPath) {
                CartView(deps: deps, cartStore: deps.cartStore, path: $cartPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $cartPath)
                    }
            }
            .tabItem { Label("Cart", systemImage: "cart.fill") }
            .tag(2)

            NavigationStack(path: $accountPath) {
                AccountView(deps: deps, path: $accountPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $accountPath)
                    }
            }
            .tabItem { Label("Account", systemImage: "person.fill") }
            .tag(3)
        }
        .onChange(of: deps.sessionManager.unauthorizedTick) { _, _ in
            homePath = NavigationPath()
            categoriesPath = NavigationPath()
            cartPath = NavigationPath()
            accountPath = NavigationPath()
            authPath = NavigationPath()
            showUnauthorizedLogin = true
        }
        .fullScreenCover(isPresented: $showUnauthorizedLogin) {
            NavigationStack(path: $authPath) {
                LoginView(
                    deps: deps,
                    onSuccess: {
                        showUnauthorizedLogin = false
                        deps.refreshAuth()
                        authPath = NavigationPath()
                    },
                    onRegister: {
                        var p = authPath
                        p.append(.register)
                        authPath = p
                    },
                    onGuest: {
                        showUnauthorizedLogin = false
                    }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .register:
                        RegisterView(
                            deps: deps,
                            onSuccess: {
                                showUnauthorizedLogin = false
                                deps.refreshAuth()
                                authPath = NavigationPath()
                            },
                            onLogin: {
                                var ap = authPath
                                if !ap.isEmpty { ap.removeLast() }
                                authPath = ap
                            }
                        )
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute, path: Binding<NavigationPath>) -> some View {
        switch route {
        case let .food(id):
            FoodDetailView(deps: deps, foodId: id)
        case let .categoryFoods(id):
            FoodListView(deps: deps, categoryId: id, path: path)
        case .checkout:
            CheckoutView(deps: deps, path: path)
        case let .orderSuccess(orderId):
            OrderSuccessView(deps: deps, orderId: orderId, onContinue: {
                selectedTab = 0
                homePath = NavigationPath()
                categoriesPath = NavigationPath()
                cartPath = NavigationPath()
                accountPath = NavigationPath()
            })
        case .login:
            LoginView(
                deps: deps,
                onSuccess: { popLast(path) },
                onRegister: {
                    replaceLast(with: .register, path: path)
                },
                onGuest: { popLast(path) }
            )
        case .register:
            RegisterView(
                deps: deps,
                onSuccess: { popLast(path) },
                onLogin: {
                    replaceLast(with: .login, path: path)
                }
            )
        case .orders:
            OrdersListView(deps: deps)
        }
    }

    private func popLast(_ path: Binding<NavigationPath>) {
        var p = path.wrappedValue
        if !p.isEmpty { p.removeLast() }
        path.wrappedValue = p
    }

    private func replaceLast(with route: AppRoute, path: Binding<NavigationPath>) {
        var p = path.wrappedValue
        if !p.isEmpty { p.removeLast() }
        p.append(route)
        path.wrappedValue = p
    }
}
