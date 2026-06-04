import Foundation

/// Custom CEF Resource Preloader (Roadmap Item 29)
/// Preloads DNS, TCP, and TLS handshakes for likely next navigations based
/// on hover state and history frequency.
final class CEFResourcePreloader {
    static let shared = CEFResourcePreloader()

    private var preloadQueue: [String] = []
    private let maxConcurrentPreloads = 4

    private init() {}

    func preload(url: String) {
        guard preloadQueue.count < maxConcurrentPreloads else { return }
        guard !preloadQueue.contains(url) else { return }
        preloadQueue.append(url)

        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            self?.preloadQueue.removeAll { $0 == url.absoluteString }
        }.resume()
    }

    func preloadFromHistory(history: HistoryStore) {
        let topUrls = history.entries.prefix(10).map { $0.url }
        for url in topUrls {
            preload(url: url)
        }
    }
}
