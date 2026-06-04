import Foundation

/// Local LLM Developer Helper Panel (Roadmap Item 24)
/// Exposes active tab developer console errors to the Codex panel with a
/// "Debug with AI" button.
final class DeveloperHelperPanel: ObservableObject {
    static let shared = DeveloperHelperPanel()

    @Published var recentErrors: [ConsoleError] = []
    @Published var isAnalyzing = false

    struct ConsoleError: Identifiable {
        let id = UUID()
        let message: String
        let source: String
        let line: Int
        let timestamp: Date
    }

    private init() {}

    func ingestConsoleLog(level: Int, message: String, source: String, line: Int) {
        guard level >= 3 else { return } // error or fatal
        let error = ConsoleError(message: message, source: source, line: line, timestamp: Date())
        DispatchQueue.main.async {
            self.recentErrors.append(error)
            if self.recentErrors.count > 100 {
                self.recentErrors.removeFirst()
            }
        }
    }

    func analyzeWithAI(completion: @escaping (String) -> Void) {
        isAnalyzing = true
        let errorText = recentErrors.map { "\($0.source):\($0.line) – \($0.message)" }.joined(separator: "\n")
        let prompt = """
        Analyze the following browser console errors and suggest fixes:

        \(errorText)
        """

        if let endpoint = LLMConfigurator.shared.endpoints.first(where: \.isOnline) {
            callLocalLLM(endpoint: endpoint, prompt: prompt) { [weak self] result in
                self?.isAnalyzing = false
                completion(result)
            }
        } else {
            isAnalyzing = false
            completion("No local LLM available. Start Ollama or LM Studio to analyze errors.")
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
                    completion("Analysis failed.")
                    return
                }
                completion(response.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }.resume()
    }
}
