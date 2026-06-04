import Foundation

/// Chrome Web Store Installation Injector (Roadmap Item 70)
/// Intercept Chrome Web Store URLs and inject a native installation trigger
/// script directly into the page.
final class ChromeWebStoreInjector {
    static let shared = ChromeWebStoreInjector()

    private init() {}

    func installationScript() -> String {
        #"""
        (function() {
            if (window.__soulCWSInjected) return;
            window.__soulCWSInjected = true;

            function addInstallButton() {
                const header = document.querySelector('h1');
                if (!header || document.getElementById('soul-install-btn')) return;
                const btn = document.createElement('button');
                btn.id = 'soul-install-btn';
                btn.textContent = 'Install in Soul';
                btn.style.cssText = 'background:#4CAF50;color:#fff;border:none;padding:10px 20px;border-radius:4px;cursor:pointer;margin-top:10px;font-size:16px;';
                btn.onclick = function() {
                    const match = location.pathname.match(/\/detail\/[^/]+\/([a-z]+)/);
                    const extId = match ? match[1] : null;
                    if (extId) {
                        console.info('SOUL_CWS_INSTALL:' + extId);
                    }
                };
                header.parentNode.insertBefore(btn, header.nextSibling);
            }

            if (document.readyState === 'complete') {
                addInstallButton();
            } else {
                window.addEventListener('load', addInstallButton);
            }
        })();
        """#
    }

    func isChromeWebStoreURL(_ url: String) -> Bool {
        url.contains("chromewebstore.google.com") || url.contains("chrome.google.com/webstore")
    }
}
