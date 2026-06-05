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
        let isOllama = endpoint.type == .ollama
        let path = isOllama ? "/api/generate" : "/v1/chat/completions"
        guard let url = URL(string: "\(endpoint.url)\(path)") else {
            completion("Invalid endpoint URL.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let modelName = endpoint.models.first ?? "llama3"
        let body: [String: Any]
        
        if isOllama {
            body = [
                "model": modelName,
                "prompt": prompt,
                "stream": false
            ]
        } else {
            // LM Studio / OpenAI format
            body = [
                "model": modelName,
                "messages": [
                    ["role": "user", "content": prompt]
                ],
                "stream": false
            ]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard let data, error == nil else {
                    completion("LLM request failed: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    var parsedResponse: String? = nil
                    
                    if isOllama {
                        parsedResponse = json["response"] as? String
                    } else {
                        if let choices = json["choices"] as? [[String: Any]],
                           let first = choices.first,
                           let message = first["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            parsedResponse = content
                        }
                    }
                    
                    if let parsedResponse {
                        completion(parsedResponse.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        completion("Unexpected LLM response format.")
                    }
                } else {
                    completion("Unexpected LLM response format.")
                }
            }
        }.resume()
    }
}
