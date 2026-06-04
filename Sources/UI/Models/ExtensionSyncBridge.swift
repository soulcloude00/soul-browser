import Foundation

/// Extension Sync Bridge (Roadmap Item 96)
/// Match chromium extension IDs from the imported browser databases and offer
/// to auto-download and install them.
final class ExtensionSyncBridge {
    static let shared = ExtensionSyncBridge()

    private init() {}

    func syncFromChrome(completion: @escaping ([(id: String, name: String)]) -> Void) {
        let chromeExtensionsPath = NSString(string: "~/Library/Application Support/Google/Chrome/Default/Extensions")
            .expandingTildeInPath
        guard FileManager.default.fileExists(atPath: chromeExtensionsPath) else {
            completion([])
            return
        }
        var found: [(String, String)] = []
        if let dirs = try? FileManager.default.contentsOfDirectory(atPath: chromeExtensionsPath) {
            for id in dirs where id.count == 32 {
                found.append((id: id, name: id))
            }
        }
        completion(found)
    }

    func installFromChromeWebStore(extensionID: String, completion: @escaping (Bool) -> Void) {
        let url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=119.0&acceptformat=crx3&x=id%3D\(extensionID)%26uc"
        let task = URLSession.shared.downloadTask(with: URL(string: url)!) { localURL, _, _ in
            guard let localURL else { completion(false); return }
            let dest = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
                .appendingPathComponent("SoulBrowser/Extensions/\(extensionID).crx")
            guard let dest else { completion(false); return }
            try? FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? FileManager.default.moveItem(at: localURL, to: dest)
            completion(true)
        }
        task.resume()
    }
}
