import Foundation

/// Reader Mode AI Summary Engine (Roadmap Item 14)
/// Feeds the distilled HTML output of Reader Mode directly to the active local
/// LLM when clicking "Summarize page".
final class ReaderModeAI {
    static let shared = ReaderModeAI()

    private init() {}

    func summarize(html: String, completion: @escaping (String) -> Void) {
        let prompt = """
        Summarize the following article concisely, preserving key facts and main arguments.
        Use bullet points if there are multiple distinct ideas.

        Article:
        \(html)
        """

        if let endpoint = LLMConfigurator.shared.endpoints.first(where: \.isOnline) {
            callLocalLLM(endpoint: endpoint, prompt: prompt, completion: completion)
        } else {
            completion("No local LLM is currently running. Please start Ollama or LM Studio.")
        }
    }

    private func callLocalLLM(endpoint: LocalLLMEndpoint, prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(endpoint.url)/api/generate") else {
            completion("Invalid endpoint URL.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": endpoint.models.first ?? "llama3",
            "prompt": prompt,
            "stream": false
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard let data, error == nil else {
                    completion("LLM request failed: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let response = json["response"] as? String {
                    completion(response.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion("Unexpected LLM response format.")
                }
            }
        }.resume()
    }
}
