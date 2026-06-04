import Foundation

/// Page Speed & Lighthouse Mini-Telemetry (Roadmap Item 55)
/// Intercepts Navigation Timing APIs inside CEF and presents a lightweight
/// page speed scorecard.
final class PageSpeedTelemetry: ObservableObject {
    static let shared = PageSpeedTelemetry()

    @Published var latestScore: PageSpeedScore?

    struct PageSpeedScore: Identifiable {
        let id = UUID()
        let url: String
        let loadTimeMs: Int
        let domContentLoadedMs: Int
        let firstPaintMs: Int
        let resourceCount: Int
        let totalTransferSize: Int
        let score: Int // 0-100
    }

    private init() {}

    func measure(tab: BrowserTab) {
        let js = """
        (function() {
            const p = performance.timing;
            const entries = performance.getEntriesByType('resource');
            return {
                loadTime: p.loadEventEnd - p.navigationStart,
                domContentLoaded: p.domContentLoadedEventEnd - p.navigationStart,
                firstPaint: performance.getEntriesByType('paint').find(e => e.name === 'first-paint')?.startTime || 0,
                resourceCount: entries.length,
                totalSize: entries.reduce((sum, e) => sum + (e.transferSize || 0), 0)
            };
        })();
        """
        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let dict = result as? [String: Any],
                  let loadTime = dict["loadTime"] as? Int,
                  let domContentLoaded = dict["domContentLoaded"] as? Int,
                  let firstPaint = dict["firstPaint"] as? Double,
                  let resourceCount = dict["resourceCount"] as? Int,
                  let totalSize = dict["totalSize"] as? Int else { return }

            // Simple scoring heuristic
            let score = max(0, min(100, 100 - Int(Double(loadTime) / 30.0)))
            self?.latestScore = PageSpeedScore(
                url: tab.urlString,
                loadTimeMs: loadTime,
                domContentLoadedMs: domContentLoaded,
                firstPaintMs: Int(firstPaint),
                resourceCount: resourceCount,
                totalTransferSize: totalSize,
                score: score
            )
        }
    }
}
