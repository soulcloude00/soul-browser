import Foundation

/// Visual Local LLM Configurator (Roadmap Item 13)
/// Checks local ports (11434 for Ollama, 1234 for LM Studio), lists local
/// model weight files, and allows downloading of new models natively.
struct LocalLLMEndpoint: Identifiable, Codable {
    let id = UUID()
    var name: String
    var url: String
    var port: Int
    var type: EndpointType
    var isOnline: Bool = false
    var models: [String] = []

    enum EndpointType: String, Codable, CaseIterable {
        case ollama = "Ollama"
        case lmStudio = "LM Studio"
        case custom = "Custom"
    }
}

final class LLMConfigurator: ObservableObject {
    static let shared = LLMConfigurator()

    @Published var endpoints: [LocalLLMEndpoint] = []
    @Published var isScanning = false

    private init() {
        endpoints = [
            LocalLLMEndpoint(name: "Ollama", url: "http://localhost:11434", port: 11434, type: .ollama),
            LocalLLMEndpoint(name: "LM Studio", url: "http://localhost:1234", port: 1234, type: .lmStudio)
        ]
    }

    func scanEndpoints() {
        isScanning = true
        for idx in endpoints.indices {
            checkEndpoint(at: idx)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isScanning = false
        }
    }

    private func checkEndpoint(at index: Int) {
        let endpoint = endpoints[index]
        
        let path = endpoint.type == .ollama ? "/api/tags" : "/v1/models"
        guard let url = URL(string: "\(endpoint.url)\(path)") else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 3
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }
                var updated = endpoint
                updated.isOnline = (error == nil && (response as? HTTPURLResponse)?.statusCode == 200)
                if let data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    if endpoint.type == .ollama {
                        if let models = json["models"] as? [[String: Any]] {
                            updated.models = models.compactMap { $0["name"] as? String }
                        }
                    } else {
                        // LM Studio / OpenAI format
                        if let dataArray = json["data"] as? [[String: Any]] {
                            updated.models = dataArray.compactMap { $0["id"] as? String }
                        }
                    }
                }
                self.endpoints[index] = updated
            }
        }.resume()
    }

    func addCustomEndpoint(name: String, url: String, port: Int) {
        endpoints.append(LocalLLMEndpoint(name: name, url: url, port: port, type: .custom))
    }
}
