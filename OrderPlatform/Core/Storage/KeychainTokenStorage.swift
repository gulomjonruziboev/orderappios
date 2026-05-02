import Foundation
import Security

/// JWT in Keychain — parity with Android TokenStorage (EncryptedSharedPreferences).
final class KeychainTokenStorage: @unchecked Sendable {
    private let service = "com.orderplatform.app.jwt"
    private let account = "token"

    private let lock = NSLock()
    private var streamContinuations: [UUID: AsyncStream<String?>.Continuation] = [:]

    func getToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data,
              let s = String(data: data, encoding: .utf8), !s.isEmpty
        else {
            return nil
        }
        return s
    }

    func setToken(_ token: String?) {
        lock.lock()
        defer { lock.unlock() }
        SecItemDelete(
            [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
            ] as CFDictionary
        )
        if let token, !token.isEmpty, let data = token.data(using: .utf8) {
            let add: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            ]
            SecItemAdd(add as CFDictionary, nil)
        }
        let t = getToken()
        for c in streamContinuations.values {
            c.yield(t)
        }
    }

    /// Clears JWT only (matches TokenStorage.clearTokenOnly).
    func clearTokenOnly() {
        setToken(nil)
    }

    func tokenStream() -> AsyncStream<String?> {
        AsyncStream { continuation in
            let id = UUID()
            self.lock.lock()
            self.streamContinuations[id] = continuation
            self.lock.unlock()
            continuation.yield(self.getToken())
            continuation.onTermination = { _ in
                self.lock.lock()
                self.streamContinuations.removeValue(forKey: id)
                self.lock.unlock()
            }
        }
    }
}
