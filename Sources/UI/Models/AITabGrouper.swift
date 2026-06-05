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

    /// Uses the local LLM to cluster tabs automatically.
    func suggestGroupsWithAI(for tabs: [BrowserTab], completion: @escaping ([(name: String, emoji: String, tabIDs: [UUID])]) -> Void) {
        guard let endpoint = LLMConfigurator.shared.endpoints.first(where: \.isOnline) else {
            // Fallback to basic heuristics if LLM is offline
            completion(suggestGroups(for: tabs))
            return
        }
        
        let tabData = tabs.map { "\($0.id): \($0.title) (\($0.urlString))" }.joined(separator: "\\n")
        
        let prompt = """
        Analyze these browser tabs and cluster them into 3-5 logical groups.
        Return ONLY valid JSON in this exact format:
        [
          {"name": "Development", "emoji": "💻", "ids": ["uuid-1", "uuid-2"]}
        ]
        
        Tabs:
        \(tabData)
        """
        
        let isOllama = endpoint.type == .ollama
        let path = isOllama ? "/api/generate" : "/v1/chat/completions"
        guard let url = URL(string: "\(endpoint.url)\(path)") else {
            completion(suggestGroups(for: tabs))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let modelName = endpoint.models.first ?? "llama3"
        let body: [String: Any]
        if isOllama {
            body = ["model": modelName, "prompt": prompt, "stream": false, "format": "json"]
        } else {
            body = [
                "model": modelName,
                "messages": [["role": "user", "content": prompt]],
                "stream": false
            ] // Note: LM Studio JSON formatting depends on the model
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async { completion(self?.suggestGroups(for: tabs) ?? []) }
                return
            }
            
            var jsonString = ""
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if isOllama {
                    jsonString = json["response"] as? String ?? ""
                } else {
                    if let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any] {
                        jsonString = message["content"] as? String ?? ""
                    }
                }
            }
            
            // Clean markdown blocks if LLM adds them
            jsonString = jsonString.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let jsonData = jsonString.data(using: .utf8),
                  let parsedArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
                DispatchQueue.main.async { completion(self.suggestGroups(for: tabs)) }
                return
            }
            
            var results: [(String, String, [UUID])] = []
            for group in parsedArray {
                let name = group["name"] as? String ?? "Group"
                let emoji = group["emoji"] as? String ?? "📁"
                let idsString = group["ids"] as? [String] ?? []
                let uuids = idsString.compactMap { UUID(uuidString: $0) }
                if !uuids.isEmpty {
                    results.append((name, emoji, uuids))
                }
            }
            
            DispatchQueue.main.async {
                completion(results.isEmpty ? self.suggestGroups(for: tabs) : results)
            }
        }.resume()
    }
}
