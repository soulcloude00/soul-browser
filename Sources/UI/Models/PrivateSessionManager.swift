import Foundation

/// Auto-Destructive Private Session Mode (Roadmap Item 67)
/// Erases all cookies, cache, storage, and history logs from system memory
/// immediately when closing a private workspace.
final class PrivateSessionManager {
    static let shared = PrivateSessionManager()

    private init() {}

    func destroyPrivateSession() {
        SoulLogger.log("PrivateSessionManager: destroying private session data")

        // Clear all in-memory caches
        URLCache.shared.removeAllCachedResponses()

        // Notify CEF to clear private data
        NotificationCenter.default.post(
            name: .soulClearPrivateData,
            object: nil,
            userInfo: [
                "cookies": true,
                "cache": true,
                "storage": true,
                "history": true
            ]
        )

        // Clear any temporary files
        let fm = FileManager.default
        if let tmpDir = try? fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("SoulBrowser/Private") {
            try? fm.removeItem(at: tmpDir)
        }
    }
}

extension Notification.Name {
    static let soulClearPrivateData = Notification.Name("soulClearPrivateData")
}
