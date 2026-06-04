import Foundation
import NaturalLanguage

/// AI Contextual Tab Grouping (Roadmap Item 23)
/// Periodically analyzes active tab titles and metadata, clustering them into
/// logically organized workspaces automatically.
final class AITabGrouper {
    static let shared = AITabGrouper()

    private init() {}

    func suggestGroups(for tabs: [BrowserTab]) -> [(name: String, emoji: String, tabIDs: [UUID])] {
        // Heuristic clustering based on domain and title keywords.
        var clusters: [String: [BrowserTab]] = [:]
        for tab in tabs {
            let category = categorize(tab: tab)
            clusters[category, default: []].append(tab)
        }

        let mappings: [String: (String, String)] = [
            "work": ("Work", "💼"),
            "dev": ("Development", "💻"),
            "social": ("Social", "💬"),
            "shopping": ("Shopping", "🛒"),
            "news": ("News", "📰"),
            "entertainment": ("Entertainment", "🎬"),
            "research": ("Research", "🔬"),
            "finance": ("Finance", "💰"),
            "default": ("Misc", "📁")
        ]

        return clusters.map { key, tabs in
            let (name, emoji) = mappings[key] ?? mappings["default"]!
            return (name, emoji, tabs.map(\.id))
        }
    }

    private func categorize(tab: BrowserTab) -> String {
        let url = tab.urlString.lowercased()
        let title = tab.title.lowercased()
        let text = "\(url) \(title)"

        if text.contains("github") || text.contains("stackoverflow") || text.contains("gitlab") || text.contains("docs") || text.contains("api") {
            return "dev"
        }
        if text.contains("slack") || text.contains("discord") || text.contains("twitter") || text.contains("linkedin") {
            return "social"
        }
        if text.contains("amazon") || text.contains("ebay") || text.contains("shop") {
            return "shopping"
        }
        if text.contains("news") || text.contains("bbc") || text.contains("cnn") || text.contains("reuters") {
            return "news"
        }
        if text.contains("youtube") || text.contains("netflix") || text.contains("twitch") || text.contains("spotify") {
            return "entertainment"
        }
        if text.contains("bank") || text.contains("crypto") || text.contains("trading") || text.contains("finance") {
            return "finance"
        }
        if text.contains("wiki") || text.contains("paper") || text.contains("arxiv") || text.contains("scholar") {
            return "research"
        }
        if text.contains("figma") || text.contains("notion") || text.contains("trello") || text.contains("jira") {
            return "work"
        }
        return "default"
    }
}
