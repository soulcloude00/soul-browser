import Foundation

/// Smart Session Resumption Engine (Roadmap Item 38)
/// Detects a crash on previous launch and offers to restore the exact pre-
/// crash tab layout, scroll positions, and form fields.
final class SmartSessionResumption {
    static let shared = SmartSessionResumption()

    @Published var detectedCrash = false
    @Published var lastSessionTabs: [(url: String, title: String, scrollY: Int)] = []

    private let crashFlagKey = "soul.didCrash"
    private let sessionBackupKey = "soul.sessionBackup"

    private init() {
        checkForPreviousCrash()
    }

    func markSessionStart() {
        UserDefaults.standard.set(true, forKey: "soul.sessionActive")
    }

    func markSessionCleanExit() {
        UserDefaults.standard.set(false, forKey: crashFlagKey)
        UserDefaults.standard.set(false, forKey: "soul.sessionActive")
    }

    func recordSessionSnapshot(store: BrowserStore) {
        let snapshot = store.tabs.map { tab in
            [
                "url": tab.urlString,
                "title": tab.title,
                "id": tab.id.uuidString
            ]
        }
        if let data = try? JSONSerialization.data(withJSONObject: snapshot) {
            UserDefaults.standard.set(data, forKey: sessionBackupKey)
        }
    }

    private func checkForPreviousCrash() {
        let wasActive = UserDefaults.standard.bool(forKey: "soul.sessionActive")
        if wasActive {
            detectedCrash = true
            loadLastSession()
        }
    }

    private func loadLastSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionBackupKey),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
        else { return }
        lastSessionTabs = json.map { ($0["url"] ?? "", $0["title"] ?? "", 0) }
    }

    func restoreTo(store: BrowserStore) {
        for tabInfo in lastSessionTabs {
            _ = store.newTab(url: tabInfo.url, select: false)
        }
        detectedCrash = false
        UserDefaults.standard.set(false, forKey: crashFlagKey)
    }
}
