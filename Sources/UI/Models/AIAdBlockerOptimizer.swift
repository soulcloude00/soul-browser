import Foundation

/// Local AI Ad-Blocker Optimization (Roadmap Item 20)
/// Feeds suspicious DOM elements or layout changes to a lightweight model
/// to determine if they constitute hidden ads or cookie consent banners.
final class AIAdBlockerOptimizer {
    static let shared = AIAdBlockerOptimizer()

    private init() {}

    func analyzeDOMSnapshot(html: String, completion: @escaping ([String]) -> Void) {
        // Heuristic ML-lite: use keyword and layout signal detection.
        let suspiciousSelectors = detectSuspiciousElements(in: html)
        completion(suspiciousSelectors)
    }

    private func detectSuspiciousElements(in html: String) -> [String] {
        var selectors: [String] = []
        let lower = html.lowercased()

        // Cookie / GDPR banner patterns
        let cookiePatterns = [
            "cookie-consent", "gdpr", "cookie-banner", "cookie-policy",
            "accept-cookies", "cookie-popup", "consent-banner"
        ]
        for pattern in cookiePatterns {
            if lower.contains(pattern) {
                selectors.append("[class*=\'\(pattern)\'],[id*=\'\(pattern)\']")
            }
        }

        // Ad container patterns
        let adPatterns = [
            "ad-container", "ad-wrapper", "sponsored", "promoted",
            "advertisement", "adsbygoogle", "display-ad"
        ]
        for pattern in adPatterns {
            if lower.contains(pattern) {
                selectors.append("[class*=\'\(pattern)\'],[id*=\'\(pattern)\']")
            }
        }

        return Array(Set(selectors))
    }
}
