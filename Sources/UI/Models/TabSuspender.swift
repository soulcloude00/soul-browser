import Foundation

extension NSNotification.Name {
    static let soulTabSuspenderCheck = NSNotification.Name("soulTabSuspenderCheck")
}

/// Heuristic Tab Suspender (Roadmap Item 25)
/// Implements a background timer that tracks tab inactivity. If a tab is
/// untouched for 15 minutes and is not playing media, its CEF browser is
/// closed to drop RAM footprint to near-zero while retaining state.
final class TabSuspender {
    static let shared = TabSuspender()

    private let inactivityThreshold: TimeInterval = 15 * 60 // 15 minutes
    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            NotificationCenter.default.post(name: .soulTabSuspenderCheck, object: nil)
        }
    }

    func checkTabs(in store: BrowserStore) {
        let now = Date()
        for tab in store.tabs where !tab.isSuspended {
            let isActive = tab.id == store.selectedTabID
            let isMediaPlaying = tab.hasRealized ? store.media.isPlayingMedia(browserId: Int(tab.browserView.browserIdentifier)) : false
            let elapsed = now.timeIntervalSince(tab.lastActiveAt)
            if !isActive && !isMediaPlaying && elapsed > inactivityThreshold {
                suspend(tab: tab)
            }
        }
    }

    func suspend(tab: BrowserTab) {
        SoulLogger.log("TabSuspender: suspending tab \(tab.title)")
        tab.browserView.setWebWindowVisible(false)
        tab.isSuspended = true
    }

    func resume(tab: BrowserTab) {
        guard tab.isSuspended else { return }
        SoulLogger.log("TabSuspender: resuming tab \(tab.title)")
        tab.browserView.setWebWindowVisible(true)
        tab.isSuspended = false
        tab.lastActiveAt = Date()
    }
}
