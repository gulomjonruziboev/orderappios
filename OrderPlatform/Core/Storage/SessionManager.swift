import Foundation
import Observation

/// Mirrors SessionManager.kt — emits unauthorized after 401 (AuthInterceptor).
@Observable
final class SessionManager: @unchecked Sendable {
    private(set) var unauthorizedTick: UInt64 = 0

    func notifyUnauthorized() {
        unauthorizedTick &+= 1
    }
}
