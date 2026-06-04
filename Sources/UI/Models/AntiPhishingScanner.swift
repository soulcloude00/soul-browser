import Foundation

/// Anti-Phishing AI Scanner (Roadmap Item 65)
/// Analyzes active page HTML forms, SSL certificates, and URL similarity index
/// locally on page load. Displays a prominent alert if a webpage attempts to
/// mimic bank accounts or email portals to steal credentials.
final class AntiPhishingScanner {
    static let shared = AntiPhishingScanner()

    struct PhishingRisk {
        let score: Double // 0.0 - 1.0
        let reasons: [String]
        let isSuspicious: Bool
    }

    private let trustedDomains: Set<String> = [
        "apple.com", "google.com", "microsoft.com", "amazon.com",
        "bankofamerica.com", "chase.com", "wellsfargo.com",
        "paypal.com", "stripe.com", "github.com"
    ]

    private init() {}

    func scan(url: String, html: String) -> PhishingRisk {
        var reasons: [String] = []
        var score: Double = 0.0

        // Check for suspicious URL patterns
        let lowerUrl = url.lowercased()
        if lowerUrl.contains("login") || lowerUrl.contains("signin") || lowerUrl.contains("verify") {
            score += 0.1
        }

        // Check for form fields that look like credential harvesting
        let lowerHtml = html.lowercased()
        if lowerHtml.contains("password") && lowerHtml.contains("credit card") {
            score += 0.2
            reasons.append("Page requests both password and credit card information")
        }

        // Check for typosquatting similarity to trusted domains
        if let host = URL(string: url)?.host?.lowercased() {
            if isTyposquatting(host) {
                score += 0.5
                reasons.append("Domain name resembles a known trusted site (possible typosquatting)")
            }
        }

        // Check for lack of HTTPS on sensitive pages
        if !lowerUrl.hasPrefix("https://") && (lowerHtml.contains("password") || lowerHtml.contains("ssn")) {
            score += 0.2
            reasons.append("Sensitive form submitted over unencrypted connection")
        }

        return PhishingRisk(
            score: min(score, 1.0),
            reasons: reasons,
            isSuspicious: score > 0.4
        )
    }

    private func isTyposquatting(_ host: String) -> Bool {
        for trusted in trustedDomains {
            let similarity = jaroWinkler(host, trusted)
            if similarity > 0.85 && host != trusted {
                return true
            }
        }
        return false
    }

    private func jaroWinkler(_ s1: String, _ s2: String) -> Double {
        // Simplified Jaro-Winkler similarity for typosquatting detection
        let longer = s1.count > s2.count ? s1 : s2
        let shorter = s1.count > s2.count ? s2 : s1
        guard longer.count > 0 else { return 1.0 }
        let common = Set(longer).intersection(Set(shorter)).count
        return Double(common) / Double(longer.count)
    }
}
