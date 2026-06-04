import Foundation

/// Cookie & LocalStorage Editor (Roadmap Item 58)
/// Build a structured tables panel allowing developers to add, edit, or
/// delete cookies, session items, and local storage values.
struct StorageItem: Identifiable {
    let id = UUID()
    var key: String
    var value: String
    var domain: String?
    var type: StorageType

    enum StorageType: String, CaseIterable {
        case cookie = "Cookie"
        case localStorage = "LocalStorage"
        case sessionStorage = "SessionStorage"
    }
}

final class CookieLocalStorageEditor: ObservableObject {
    static let shared = CookieLocalStorageEditor()

    @Published var items: [StorageItem] = []

    private init() {}

    func scan(tab: BrowserTab) {
        let js = """
        (function() {
            const cookies = document.cookie.split('; ').map(c => {
                const [k, ...v] = c.split('=');
                return {key: k, value: v.join('='), type: 'Cookie'};
            });
            const local = Object.entries(localStorage).map(([k, v]) => ({key: k, value: v, type: 'LocalStorage'}));
            const session = Object.entries(sessionStorage).map(([k, v]) => ({key: k, value: v, type: 'SessionStorage'}));
            return [...cookies, ...local, ...session];
        })();
        """
        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let array = result as? [[String: String]] else { return }
            self?.items = array.map { dict in
                StorageItem(
                    key: dict["key"] ?? "",
                    value: dict["value"] ?? "",
                    domain: nil,
                    type: StorageItem.StorageType(rawValue: dict["type"] ?? "Cookie") ?? .cookie
                )
            }
        }
    }

    func update(item: StorageItem, newValue: String, in tab: BrowserTab) {
        switch item.type {
        case .cookie:
            tab.browserView.evaluateJavaScript("document.cookie = '\(item.key)=\(newValue); path=/'") { _, _ in }
        case .localStorage:
            tab.browserView.evaluateJavaScript("localStorage.setItem('\(item.key)', '\(newValue)');") { _, _ in }
        case .sessionStorage:
            tab.browserView.evaluateJavaScript("sessionStorage.setItem('\(item.key)', '\(newValue)');") { _, _ in }
        }
    }

    func delete(item: StorageItem, in tab: BrowserTab) {
        switch item.type {
        case .cookie:
            tab.browserView.evaluateJavaScript("document.cookie = '\(item.key)=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/'") { _, _ in }
        case .localStorage:
            tab.browserView.evaluateJavaScript("localStorage.removeItem('\(item.key)');") { _, _ in }
        case .sessionStorage:
            tab.browserView.evaluateJavaScript("sessionStorage.removeItem('\(item.key)');") { _, _ in }
        }
    }
}
