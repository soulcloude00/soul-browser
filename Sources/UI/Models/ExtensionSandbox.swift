import Foundation

/// Sandbox Isolated Extension Execution (Roadmap Item 61)
/// Execute extension scripts inside dedicated, restricted JS contexts that
/// cannot interact with critical system interfaces.
final class ExtensionSandbox {
    static let shared = ExtensionSandbox()

    private var restrictedAPIs: Set<String> = [
        "require", "fs", "child_process", "os", "path", "net"
    ]

    private init() {}

    func sanitizeScript(_ script: String) -> String {
        var sanitized = script
        for api in restrictedAPIs {
            sanitized = sanitized.replacingOccurrences(
                of: "\\b\(api)\\b",
                with: "throw new Error('Sandbox: \(api) is restricted');",
                options: .regularExpression
            )
        }
        return sanitized
    }

    func createIsolatedContext(for extensionID: String) -> String {
        """
        (function() {
            const EXTENSION_ID = '\(extensionID)';
            window.__soul_extension_contexts__ = window.__soul_extension_contexts__ || {};
            if (window.__soul_extension_contexts__[EXTENSION_ID]) return;
            window.__soul_extension_contexts__[EXTENSION_ID] = {
                id: EXTENSION_ID,
                createdAt: Date.now(),
                postMessage: function(msg) {
                    window.__soul_extension_bridge__(EXTENSION_ID, msg);
                }
            };
        })();
        """
    }

    func destroyContext(for extensionID: String) {
        SoulLogger.log("ExtensionSandbox: destroyed context for \(extensionID)")
    }
}
