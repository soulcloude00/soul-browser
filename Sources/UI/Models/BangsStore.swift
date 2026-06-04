import SwiftUI

struct BangItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var key: String
    var template: String
    var enabled: Bool
    var isCustom: Bool
}

final class BangsStore: ObservableObject {
    static let shared = BangsStore()

    @Published var items: [BangItem] = []

    private let fileURL: URL

    private static let defaultBangs: [BangItem] = [
        BangItem(name: "Wikipedia", key: "w", template: "https://en.wikipedia.org/wiki/Special:Search?search={query}", enabled: true, isCustom: false),
        BangItem(name: "Wikipedia (Long)", key: "wikipedia", template: "https://en.wikipedia.org/wiki/Special:Search?search={query}", enabled: true, isCustom: false),
        BangItem(name: "GitHub", key: "gh", template: "https://github.com/search?q={query}", enabled: true, isCustom: false),
        BangItem(name: "GitHub (Long)", key: "github", template: "https://github.com/search?q={query}", enabled: true, isCustom: false),
        BangItem(name: "YouTube", key: "yt", template: "https://www.youtube.com/results?search_query={query}", enabled: true, isCustom: false),
        BangItem(name: "YouTube (Long)", key: "youtube", template: "https://www.youtube.com/results?search_query={query}", enabled: true, isCustom: false),
        BangItem(name: "Google", key: "g", template: "https://www.google.com/search?q={query}", enabled: true, isCustom: false),
        BangItem(name: "Google (Long)", key: "google", template: "https://www.google.com/search?q={query}", enabled: true, isCustom: false),
        BangItem(name: "DuckDuckGo", key: "ddg", template: "https://duckduckgo.com/?q={query}", enabled: true, isCustom: false),
        BangItem(name: "Reddit", key: "r", template: "https://www.reddit.com/search/?q={query}", enabled: true, isCustom: false),
        BangItem(name: "Reddit (Long)", key: "reddit", template: "https://www.reddit.com/search/?q={query}", enabled: true, isCustom: false),
        BangItem(name: "StackOverflow", key: "so", template: "https://stackoverflow.com/search?q={query}", enabled: true, isCustom: false),
        BangItem(name: "WolframAlpha", key: "wa", template: "https://www.wolframalpha.com/input/?i={query}", enabled: true, isCustom: false),
        BangItem(name: "IMDb", key: "imdb", template: "https://www.imdb.com/find?q={query}", enabled: true, isCustom: false),
        BangItem(name: "Google Maps", key: "map", template: "https://www.google.com/maps?q={query}", enabled: true, isCustom: false)
    ]

    init() {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent("SoulBrowser", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("bangs.json")
        load()
    }

    func add(name: String, key: String, template: String) {
        let item = BangItem(name: name, key: key.lowercased(), template: template, enabled: true, isCustom: true)
        items.append(item)
        save()
    }

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    func toggleEnabled(_ item: BangItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].enabled.toggle()
            save()
        }
    }

    func resolve(_ text: String) -> String? {
        let parts = text.split(separator: " ", omittingEmptySubsequences: true)
        guard let first = parts.first else { return nil }

        if first.hasPrefix("!") {
            let key = String(first.dropFirst()).lowercased()
            if let match = items.first(where: { $0.key == key && $0.enabled }) {
                let query = parts.count > 1 ? parts[1...].joined(separator: " ") : ""
                return applyTemplate(match.template, query: query)
            }
        }

        if let last = parts.last, last.hasPrefix("!"), parts.count > 1 {
            let key = String(last.dropFirst()).lowercased()
            if let match = items.first(where: { $0.key == key && $0.enabled }) {
                let query = parts[0..<(parts.count - 1)].joined(separator: " ")
                return applyTemplate(match.template, query: query)
            }
        }

        return nil
    }

    private func applyTemplate(_ template: String, query: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+?/#")
        let encoded = query.addingPercentEncoding(withAllowedCharacters: allowed) ?? query
        if template.contains("{query}") {
            return template.replacingOccurrences(of: "{query}", with: encoded)
        }
        return template + encoded
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([BangItem].self, from: data) {
            items = decoded
        } else {
            items = Self.defaultBangs
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
