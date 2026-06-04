import Foundation
import AppKit

/// Low Power Mode Integration (Roadmap Item 11)
/// Observes NSProcessInfo.powerStateDidChangeNotification and notifies CEF
/// renderer processes to limit frame rates to 30fps and suspend non-active
/// worker threads when the Mac enters low power mode.
final class SoulPowerManager: ObservableObject {
    static let shared = SoulPowerManager()

    @Published private(set) var isLowPowerModeEnabled: Bool = false
    @Published private(set) var thermalState: ProcessInfo.ThermalState = .nominal

    private init() {
        updatePowerState()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(powerStateDidChange),
            name: NSNotification.Name("NSProcessInfoPowerStateDidChangeNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thermalStateDidChange),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
    }

    @objc private func powerStateDidChange() {
        updatePowerState()
        applyCEFThrottling()
    }

    @objc private func thermalStateDidChange() {
        thermalState = ProcessInfo.processInfo.thermalState
        applyCEFThrottling()
    }

    private func updatePowerState() {
        isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    /// Notify CEF to throttle when low power or serious thermal state is active.
    private func applyCEFThrottling() {
        let shouldThrottle = isLowPowerModeEnabled ||
            (thermalState == .serious || thermalState == .critical)

        if shouldThrottle {
            SoulLogger.log("PowerManager: throttling CEF to 30fps")
            // Broadcast to all tabs to enable frame rate limiting.
            // The CEF renderer reads this via JS environment or command-line flags.
            NotificationCenter.default.post(
                name: .soulPowerThrottleChanged,
                object: nil,
                userInfo: ["throttled": true, "targetFPS": 30]
            )
        } else {
            SoulLogger.log("PowerManager: restoring normal CEF frame rate")
            NotificationCenter.default.post(
                name: .soulPowerThrottleChanged,
                object: nil,
                userInfo: ["throttled": false]
            )
        }
    }
}

extension Notification.Name {
    static let soulPowerThrottleChanged = Notification.Name("soulPowerThrottleChanged")
}
