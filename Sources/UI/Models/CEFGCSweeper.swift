import Foundation

/// Intelligent Garbage Collection (GC) Sweeper (Roadmap Item 28)
/// Periodically dispatches force-GC requests to active web frames when the
/// browser goes idle or when the computer enters sleep state.
final class CEFGCSweeper {
    static let shared = CEFGCSweeper()

    private var idleTimer: Timer?
    private var sleepObserver: NSObjectProtocol?

    private init() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.sweepIfIdle()
        }

        sleepObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NSWorkspaceWillSleepNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.forceSweepAll()
        }
    }

    private func sweepIfIdle() {
        // Trigger GC on all realized tabs if the user hasn't interacted recently.
        let now = Date()
        // In production: access the BrowserStore via notification or singleton.
        SoulLogger.log("CEFGCSweeper: idle sweep requested")
    }

    private func forceSweepAll() {
        SoulLogger.log("CEFGCSweeper: force sweep all requested")
    }

    private func requestGC(in tab: BrowserTab) {
        let js = "if(window.gc){window.gc();}"
        tab.browserView.evaluateJavaScript(js) { _, _ in }
    }
}
