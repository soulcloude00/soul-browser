import Foundation
import IOKit.ps

/// Battery-Aware Background Throttling (Roadmap Item 33)
/// When the Mac is unplugged and battery drops below 20%, background tabs
/// are aggressively suspended and media is paused to preserve charge.
final class BatteryThrottler: ObservableObject {
    static let shared = BatteryThrottler()

    @Published var batteryLevel: Int = 100
    @Published var isPluggedIn: Bool = true
    @Published var isThrottling = false

    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkBattery()
        }
        checkBattery()
    }

    private func checkBattery() {
        let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let first = sources.first,
              let info = IOPSGetPowerSourceDescription(snapshot, first)?.takeUnretainedValue() as? [String: Any]
        else { return }

        if let capacity = info[kIOPSCurrentCapacityKey] as? Int {
            batteryLevel = capacity
        }
        if let powerSource = info[kIOPSPowerSourceStateKey] as? String {
            isPluggedIn = (powerSource == kIOPMACPowerKey)
        }

        let shouldThrottle = !isPluggedIn && batteryLevel < 20
        if shouldThrottle != isThrottling {
            isThrottling = shouldThrottle
            applyThrottle(shouldThrottle)
        }
    }

    private func applyThrottle(_ throttle: Bool) {
        if throttle {
            SoulLogger.log("BatteryThrottler: throttling background tabs (battery \(batteryLevel)%)")
            NotificationCenter.default.post(name: .soulBatteryThrottle, object: nil, userInfo: ["throttle": true])
        } else {
            SoulLogger.log("BatteryThrottler: restoring normal operation")
            NotificationCenter.default.post(name: .soulBatteryThrottle, object: nil, userInfo: ["throttle": false])
        }
    }
}

extension Notification.Name {
    static let soulBatteryThrottle = Notification.Name("soulBatteryThrottle")
}
