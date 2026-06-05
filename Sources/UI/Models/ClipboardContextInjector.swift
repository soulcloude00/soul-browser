import AppKit

/// Intelligent Clipboard Context Injector (Roadmap Item 15)
/// Monitors the macOS clipboard via NSPasteboard and shows an option inside
/// the AI Panel to "Analyze copied content" if paste content changes.
final class ClipboardContextInjector: ObservableObject {
    static let shared = ClipboardContextInjector()

    @Published var hasNewContent = false
    @Published var currentContent: String = ""

    private var lastChangeCount = NSPasteboard.general.changeCount
    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        if let string = pb.string(forType: .string), !string.isEmpty {
            currentContent = string
            hasNewContent = true
            SoulLogger.log("Clipboard changed: \(string.prefix(50))...")
        }
    }

    func acknowledge() {
        hasNewContent = false
    }
    
    enum AnalysisAction: String {
        case explain = "Explain this code or text snippet."
        case format = "Format this text or code block correctly."
        case translate = "Translate this text to English."
    }

    /// Feeds the clipboard content to the local LLM for instant analysis.
    func analyzeContent(action: AnalysisAction, completion: @escaping (String) -> Void) {
        guard !currentContent.isEmpty else {
            completion("Clipboard is empty.")
            return
        }
        
        let prompt = "\(action.rawValue)\\n\\nContent:\\n\(currentContent)"
        
        guard let endpoint = LLMConfigurator.shared.endpoints.first(where: \.isOnline) else {
            completion("No local LLM is currently running.")
            return
        }
        
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
            body = ["model": modelName, "prompt": prompt, "stream": false]
        } else {
            body = [
                "model": modelName,
                "messages": [["role": "user", "content": prompt]],
                "stream": false
            ]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    let errStr = error?.localizedDescription ?? "unknown error"
                    completion("LLM request failed: \(errStr)")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    var parsedResponse: String? = nil
                    if isOllama {
                        parsedResponse = json["response"] as? String
                    } else {
                        if let choices = json["choices"] as? [[String: Any]],
                           let first = choices.first,
                           let message = first["message"] as? [String: Any] {
                            parsedResponse = message["content"] as? String
                        }
                    }
                    if let response = parsedResponse {
                        completion(response.trimmingCharacters(in: .whitespacesAndNewlines))
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
