import Foundation

/// Dynamic Dark Mode Web Injector (Roadmap Item 80)
/// Writes a high-quality CSS injection stylesheet that intelligently color-shifts
/// light web pages into elegant dark themes.
final class AIDarkModeInjector {
    static let shared = AIDarkModeInjector()

    private init() {}

    var darkModeCSS: String {
        """
        /* Soul Browser Smart Dark Mode */
        html, body {
            background-color: #1a1a1a !important;
            color: #e0e0e0 !important;
        }
        a { color: #6ea8fe !important; }
        a:visited { color: #b78cf7 !important; }
        img, video, canvas, svg {
            filter: brightness(0.85) contrast(1.1) !important;
        }
        div, section, article, aside, nav, header, footer, main {
            background-color: transparent !important;
        }
        input, textarea, select {
            background-color: #2a2a2a !important;
            color: #e0e0e0 !important;
            border-color: #444 !important;
        }
        button {
            background-color: #333 !important;
            color: #e0e0e0 !important;
            border-color: #555 !important;
        }
        /* Preserve images that already have dark backgrounds */
        img[src*="logo"], img[src*="icon"] {
            filter: none !important;
        }
        """
    }

    func inject(into tab: BrowserTab) {
        let js = """
        (function() {
            if (window.__soulDarkModeInjected) return;
            window.__soulDarkModeInjected = true;
            var style = document.createElement('style');
            style.id = 'soul-smart-dark-mode';
            style.textContent = `\(darkModeCSS.replacingOccurrences(of: "`", with: "\\`"))`;
            document.head.appendChild(style);
        })();
        """
        tab.browserView.evaluateJavaScript(js) { _, _ in }
    }

    func remove(from tab: BrowserTab) {
        let js = """
        (function() {
            var style = document.getElementById('soul-smart-dark-mode');
            if (style) style.remove();
            window.__soulDarkModeInjected = false;
        })();
        """
        tab.browserView.evaluateJavaScript(js) { _, _ in }
    }
}
