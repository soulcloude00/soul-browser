import Foundation

/// Custom Manifest V3 DeclarativeNetRequest Support (Roadmap Item 71)
/// Maps extension network-filtering rules directly to the native blocklist parser.
struct DeclarativeNetRule: Codable {
    let id: Int
    let priority: Int
    let action: RuleAction
    let condition: RuleCondition

    struct RuleAction: Codable {
        let type: String
    }

    struct RuleCondition: Codable {
        let urlFilter: String?
        let domains: [String]?
        let resourceTypes: [String]?
    }
}

final class DeclarativeNetRequestEngine {
    static let shared = DeclarativeNetRequestEngine()

    private var rules: [DeclarativeNetRule] = []

    private init() {}

    func loadRules(from extensionID: String) {
        let path = NSString(string: "~/Library/Application Support/SoulBrowser/Extensions/\(extensionID)/rules.json")
            .expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let decoded = try? JSONDecoder().decode([DeclarativeNetRule].self, from: data)
        else { return }
        rules.append(contentsOf: decoded)
    }

    func shouldBlock(url: String, domain: String, resourceType: String) -> Bool {
        for rule in rules {
            guard rule.condition.domains?.contains(domain) ?? true else { continue }
            guard rule.condition.resourceTypes?.contains(resourceType) ?? true else { continue }
            if let filter = rule.condition.urlFilter, url.contains(filter) {
                return rule.action.type == "block"
            }
        }
        return false
    }

    func getDynamicRuleCount() -> Int {
        rules.count
    }
}
