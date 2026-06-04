import Foundation

/// Custom Soul Extension API Surface (Roadmap Item 78)
/// Exposes proprietary JS hooks (e.g., `soul.ai.summarize()`, `soul.theme.get()`)
/// to authorized developer extensions.
final class SoulExtensionAPI {
    static let shared = SoulExtensionAPI()

    private init() {}

    func apiScript() -> String {
        """
        window.soul = window.soul || {};
        window.soul.ai = {
            summarize: async function(text) {
                return await window.__soul_bridge__('ai.summarize', { text });
            },
            rewrite: async function(text, style) {
                return await window.__soul_bridge__('ai.rewrite', { text, style });
            }
        };
        window.soul.theme = {
            get: function() {
                return window.__soul_bridge__('theme.get', {});
            },
            set: function(themeName) {
                return window.__soul_bridge__('theme.set', { theme: themeName });
            }
        };
        window.soul.sidebar = {
            open: function(url, title) {
                return window.__soul_bridge__('sidebar.open', { url, title });
            },
            close: function() {
                return window.__soul_bridge__('sidebar.close', {});
            }
        };
        """
    }

    func handleBridgeCall(method: String, args: [String: Any]) -> Any? {
        switch method {
        case "theme.get":
            return BrowserSettings.shared.theme.rawValue
        case "theme.set":
            if let theme = args["theme"] as? String {
                BrowserSettings.shared.theme = ThemePreference(rawValue: theme) ?? .system
            }
            return true
        default:
            return nil
        }
    }
}
