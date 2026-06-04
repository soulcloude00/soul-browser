import Foundation

/// Extension Runtime Resource Throttle (Roadmap Item 77)
/// Monitor the CPU usage of background extension workers, automatically
/// placing high-CPU threads in sleep mode.
final class ExtensionResourceThrottle: ObservableObject {
    static let shared = ExtensionResourceThrottle()

    @Published var throttledExtensions: Set<String> = []

    private var cpuHistory: [String: [Double]] = [:]
    private let cpuThreshold = 15.0 // percent

    private init() {}

    func recordCPUSample(extensionID: String, cpuPercent: Double) {
        cpuHistory[extensionID, default: []].append(cpuPercent)
        if cpuHistory[extensionID, default: []].count > 10 {
            cpuHistory[extensionID]?.removeFirst()
        }

        let avg = cpuHistory[extensionID]?.reduce(0, +) ?? 0 / Double(cpuHistory[extensionID]?.count ?? 1)
        if avg > cpuThreshold {
            throttle(extensionID: extensionID)
        } else if throttledExtensions.contains(extensionID) {
            unthrottle(extensionID: extensionID)
        }
    }

    func throttle(extensionID: String) {
        throttledExtensions.insert(extensionID)
        SoulLogger.log("ExtensionResourceThrottle: throttled \(extensionID)")
        NotificationCenter.default.post(
            name: .soulExtensionThrottled,
            object: nil,
            userInfo: ["extensionID": extensionID, "throttled": true]
        )
    }

    func unthrottle(extensionID: String) {
        throttledExtensions.remove(extensionID)
        SoulLogger.log("ExtensionResourceThrottle: unthrottled \(extensionID)")
        NotificationCenter.default.post(
            name: .soulExtensionThrottled,
            object: nil,
            userInfo: ["extensionID": extensionID, "throttled": false]
        )
    }
}

extension Notification.Name {
    static let soulExtensionThrottled = Notification.Name("soulExtensionThrottled")
}
