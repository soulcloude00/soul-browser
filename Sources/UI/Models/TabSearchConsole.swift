import Foundation

/// Tab Search Console (The "Tab Command Palette") (Roadmap Item 46)
/// Build a quick search launcher (⌘⇧P) that lets users search titles and
/// domains across all open tabs.
final class TabSearchConsole: ObservableObject {
    static let shared = TabSearchConsole()

    @Published var query = ""

    private init() {}

    func search(in store: BrowserStore) -> [BrowserTab] {
        let q = query.lowercased()
        if q.isEmpty { return store.tabs }
        return store.tabs.filter {
            $0.title.lowercased().contains(q) ||
            $0.urlString.lowercased().contains(q)
        }
    }

    func selectTab(_ tab: BrowserTab, in store: BrowserStore) {
        store.selectTab(tab.id)
        query = ""
    }
}
