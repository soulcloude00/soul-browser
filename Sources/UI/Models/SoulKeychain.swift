import Security
import Foundation

/// Native Keychain Storage Migration (Roadmap Item 10)
/// A Swift bridge to Apple Keychain Services, replacing mocked password stores
/// when launching with MORI_USE_REAL_KEYCHAIN=1.
final class SoulKeychain {
    static let shared = SoulKeychain()
    private let service = "com.soul.browser"

    private init() {}

    // MARK: - Credentials

    @discardableResult
    func savePassword(account: String, password: String, server: String? = nil) -> Bool {
        guard useRealKeychain else {
            SoulLogger.log("Keychain: mocked save for \(account)")
            return true
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: password.data(using: .utf8)!
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            SoulLogger.log("Keychain: saved password for \(account)")
            return true
        } else {
            SoulLogger.log("Keychain: save failed (status \(status))")
            return false
        }
    }

    func readPassword(account: String) -> String? {
        guard useRealKeychain else {
            SoulLogger.log("Keychain: mocked read for \(account)")
            return nil
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8)
        else { return nil }
        return password
    }

    @discardableResult
    func deletePassword(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    // MARK: - Internet Passwords (for web logins)

    @discardableResult
    func saveInternetPassword(account: String, password: String, server: String) -> Bool {
        guard useRealKeychain else { return true }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account,
            kSecValueData as String: password.data(using: .utf8)!
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    func readInternetPassword(account: String, server: String) -> String? {
        guard useRealKeychain else { return nil }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8)
        else { return nil }
        return password
    }

    // MARK: - Helpers

    /// Checks environment variables to determine if the real macOS Keychain should be used.
    /// Supports `SOUL_USE_REAL_KEYCHAIN` as defined in Roadmap Item #10, and legacy `MORI_USE_REAL_KEYCHAIN`.
    private var useRealKeychain: Bool {
        let processInfo = ProcessInfo.processInfo
        let soulEnv = processInfo.environment["SOUL_USE_REAL_KEYCHAIN"]
        let moriEnv = processInfo.environment["MORI_USE_REAL_KEYCHAIN"]
        
        return soulEnv == "1" || soulEnv?.lowercased() == "true" ||
               moriEnv == "1" || moriEnv?.lowercased() == "true"
    }
}
