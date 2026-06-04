import Foundation

/// Global Focus Tracker & Productivity Dashboard (Roadmap Item 103)
/// Keeps track of active site durations locally, presenting a beautiful SwiftUI
/// chart of weekly internet habits.
final class FocusTracker: ObservableObject {
    static let shared = FocusTracker()

    @Published var dailyStats: [DailyStat] = []

    struct DailyStat: Identifiable {
        let id = UUID()
        let date: Date
        let domain: String
        let duration: TimeInterval
        let category: String
    }

    private var activeStartTime: Date?
    private var activeDomain: String?
    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.recordSession()
        }
    }

    func track(domain: String) {
        recordSession()
        activeDomain = domain
        activeStartTime = Date()
    }

    private func recordSession() {
        guard let start = activeStartTime, let domain = activeDomain else { return }
        let duration = Date().timeIntervalSince(start)
        guard duration > 1 else { return }

        let category = categorize(domain: domain)
        let stat = DailyStat(date: Date(), domain: domain, duration: duration, category: category)
        DispatchQueue.main.async {
            self.dailyStats.append(stat)
            if self.dailyStats.count > 10000 { self.dailyStats.removeFirst() }
        }
        activeStartTime = Date()
    }

    private func categorize(domain: String) -> String {
        let lower = domain.lowercased()
        if lower.contains("github") || lower.contains("stackoverflow") { return "Development" }
        if lower.contains("slack") || lower.contains("discord") || lower.contains("twitter") { return "Social" }
        if lower.contains("youtube") || lower.contains("netflix") || lower.contains("twitch") { return "Entertainment" }
        if lower.contains("docs.") || lower.contains("notion") || lower.contains("figma") { return "Work" }
        return "Other"
    }

    var weeklySummary: [(category: String, totalDuration: TimeInterval)] {
        let grouped = Dictionary(grouping: dailyStats) { $0.category }
        return grouped.map { (category: $0.key, totalDuration: $0.value.map(\.duration).reduce(0, +)) }
            .sorted { $0.totalDuration > $1.totalDuration }
    }
}
