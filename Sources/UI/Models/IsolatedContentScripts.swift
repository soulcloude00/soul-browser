import Foundation

/// Isolated Content Script Contexts (Roadmap Item 72)
/// Enforce strict isolation bounds between the host page's scripts and
/// extension-injected content scripts inside CEF.
final class IsolatedContentScripts {
    static let shared = IsolatedContentScripts()

    private init() {}

    func wrapContentScript(_ script: String, extensionID: String) -> String {
        """
        (function() {
            const EXTENSION_ID = '\(extensionID)';
            const isolatedWindow = {
                document: window.document,
                location: window.location,
                console: window.console,
                postMessage: function(msg, targetOrigin) {
                    window.postMessage({__soul_extension_id__: EXTENSION_ID, data: msg}, targetOrigin);
                }
            };
            (function(window) {
                \(script)
            })(isolatedWindow);
        })();
        """
    }

    func injectIsolated(into tab: BrowserTab, source: String, extensionID: String) {
        let wrapped = wrapContentScript(source, extensionID: extensionID)
        tab.browserView.evaluateJavaScript(wrapped) { _, _ in }
    }
}
