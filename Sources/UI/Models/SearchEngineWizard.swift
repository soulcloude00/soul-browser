import Foundation

/// Dynamic Search Engine Switcher Wizard (Roadmap Item 93)
/// Include a direct configuration wizard for quickly choosing DuckDuckGo, Kagi,
/// Brave Search, or custom endpoints.
final class SearchEngineWizard: ObservableObject {
    static let shared = SearchEngineWizard()

    @Published var isPresented = false

    let engines: [(name: String, url: String)] = [
        ("DuckDuckGo", "https://duckduckgo.com/?q={query}"),
        ("Kagi", "https://kagi.com/search?q={query}"),
        ("Brave Search", "https://search.brave.com/search?q={query}"),
        ("Google", "https://www.google.com/search?q={query}"),
        ("Bing", "https://www.bing.com/search?q={query}"),
        ("Ecosia", "https://www.ecosia.org/search?q={query}")
    ]

    private init() {}

    func applyEngine(name: String, template: String) {
        BrowserSettings.shared.searchEngine = .custom
        BrowserSettings.shared.customSearchTemplate = template
        SoulLogger.log("SearchEngineWizard: set engine to \(name)")
    }
}
