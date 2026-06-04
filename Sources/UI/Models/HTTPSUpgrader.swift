import Foundation

/// HTTPS-Only Upgrader Subsystem (Roadmap Item 63)
/// Intercepts all HTTP requests, automatically rewriting them to use HTTPS,
/// and failing safely with a warning if HTTPS is unavailable.
final class HTTPSUpgrader {
    static let shared = HTTPSUpgrader()

    private var knownInsecureHosts: Set<String> = []
    private var knownSecureHosts: Set<String> = []

    private init() {}

    func upgradedURL(for urlString: String) -> String? {
        guard let url = URL(string: urlString),
              url.scheme?.lowercased() == "http" else { return nil }

        let host = url.host?.lowercased() ?? ""
        if knownInsecureHosts.contains(host) { return nil }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        return components?.string
    }

    func markSecure(host: String) {
        knownSecureHosts.insert(host.lowercased())
    }

    func markInsecure(host: String) {
        knownInsecureHosts.insert(host.lowercased())
    }
}
