import Foundation

/// Deep links mirroring OrderNavHost.kt routes.
enum AppRoute: Hashable {
    case food(String)
    case categoryFoods(String)
    case checkout
    case orderSuccess(String)
    case login
    case register
    case orders
}
