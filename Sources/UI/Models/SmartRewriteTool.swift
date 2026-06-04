import Foundation

/// In-Page Inline Smart Rewrite Tool (Roadmap Item 16)
/// Injects a custom context menu helper into CEF text fields. On selection,
/// shows a popover with rewriting options (e.g., "Professional", "Concise",
/// "Fix Grammar").
final class SmartRewriteTool {
    static let shared = SmartRewriteTool()

    enum RewriteStyle: String, CaseIterable {
        case professional = "Professional"
        case concise = "Concise"
        case casual = "Casual"
        case grammar = "Fix Grammar"
        case expand = "Expand"
        case simplify = "Simplify"
    }

    private init() {}

    func rewrite(text: String, style: RewriteStyle, completion: @escaping (String) -> Void) {
        let prompt: String
        switch style {
        case .professional:
            prompt = "Rewrite the following text in a professional, formal tone: \(text)"
        case .concise:
            prompt = "Rewrite the following text to be more concise and direct: \(text)"
        case .casual:
            prompt = "Rewrite the following text in a casual, friendly tone: \(text)"
        case .grammar:
            prompt = "Fix any grammar or spelling issues in the following text, preserving the original meaning: \(text)"
        case .expand:
            prompt = "Expand the following text with more detail and explanation: \(text)"
        case .simplify:
            prompt = "Simplify the following text so a general audience can understand it: \(text)"
        }

        if let endpoint = LLMConfigurator.shared.endpoints.first(where: \.isOnline) {
            callLocalLLM(endpoint: endpoint, prompt: prompt, completion: completion)
        } else {
            completion("No local LLM available. Start Ollama or LM Studio to use Smart Rewrite.")
        }
    }

    private func callLocalLLM(endpoint: LocalLLMEndpoint, prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(endpoint.url)/api/generate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": endpoint.models.first ?? "llama3",
            "prompt": prompt,
            "stream": false
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let response = json["response"] as? String else {
                    completion("Rewrite failed.")
                    return
                }
                completion(response.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }.resume()
    }
}
