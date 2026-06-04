import Foundation

/// Custom Declarative Blocklist Engine (Roadmap Item 59)
/// Write a high-performance Rust or Swift parser matching EasyList/EasyPrivacy
/// rules, running natively before CEF requests load.
final class DeclarativeBlocklistEngine {
    static let shared = DeclarativeBlocklistEngine()

    @Published var isEnabled = true
    @Published var blockedCount = 0

    private var blocklist: Set<String> = []
    private var regexRules: [NSRegularExpression] = []

    private init() {
        loadBuiltInList()
    }

    func loadBuiltInList() {
        guard let path = Bundle.main.path(forResource: "trackers", ofType: "txt") else { return }
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("!"), !trimmed.hasPrefix("#") else { continue }
            if trimmed.hasPrefix("||") {
                blocklist.insert(String(trimmed.dropFirst(2)))
            } else if trimmed.hasPrefix("/") && trimmed.hasSuffix("/") {
                let pattern = String(trimmed.dropFirst().dropLast())
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    regexRules.append(regex)
                }
            } else {
                blocklist.insert(trimmed)
            }
        }
    }

    func shouldBlock(url: String) -> Bool {
        guard isEnabled else { return false }
        let lower = url.lowercased()
        for domain in blocklist {
            if lower.contains(domain) {
                blockedCount += 1
                return true
            }
        }
        for regex in regexRules {
            let range = NSRange(lower.startIndex..., in: lower)
            if regex.firstMatch(in: lower, options: [], range: range) != nil {
                blockedCount += 1
                return true
            }
        }
        return false
    }

    func addCustomRule(_ rule: String) {
        blocklist.insert(rule.lowercased())
    }

    func removeCustomRule(_ rule: String) {
        blocklist.remove(rule.lowercased())
    }
}
