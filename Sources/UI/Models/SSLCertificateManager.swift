import Foundation
import Security

/// Local SSL/TLS Certificate Manager (Roadmap Item 54)
/// Provides a local settings wizard to trust development certs (mkcert)
/// and handle self-signed local server certificates.
final class SSLCertificateManager {
    static let shared = SSLCertificateManager()

    @Published var trustedCerts: [TrustedCert] = []

    struct TrustedCert: Identifiable {
        let id = UUID()
        let domain: String
        let path: String
        let dateAdded: Date
    }

    private init() {
        loadTrustedCerts()
    }

    func trustCertificate(path: String, for domain: String) -> Bool {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return false }
        let cert = SecCertificateCreateWithData(nil, data as CFData)
        guard let cert else { return false }

        var trust: SecTrust?
        let policy = SecPolicyCreateSSL(true, domain as CFString)
        SecTrustCreateWithCertificates(cert, policy, &trust)

        // Add to keychain trust
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecValueRef as String: cert,
            kSecAttrLabel as String: "Soul: \(domain)"
        ]
        SecItemDelete(addQuery as CFDictionary)
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        let success = status == errSecSuccess
        if success {
            let trusted = TrustedCert(domain: domain, path: path, dateAdded: Date())
            trustedCerts.append(trusted)
            saveTrustedCerts()
        }
        return success
    }

    func removeTrust(for domain: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: "Soul: \(domain)"
        ]
        SecItemDelete(query as CFDictionary)
        trustedCerts.removeAll { $0.domain == domain }
        saveTrustedCerts()
    }

    private func loadTrustedCerts() {
        // Read from UserDefaults or a local plist.
    }

    private func saveTrustedCerts() {
        // Persist to UserDefaults.
    }
}
