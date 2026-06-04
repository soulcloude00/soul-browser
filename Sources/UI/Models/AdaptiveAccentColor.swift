import SwiftUI
import AppKit

/// Adaptive Window Accent Synchronization (Roadmap Item 83)
/// Samples the dominant color of the active website's favicon or header
/// and blends it subtly into the Soul window frame.
final class AdaptiveAccentColor: ObservableObject {
    static let shared = AdaptiveAccentColor()

    @Published var accentColor: Color = .clear

    private init() {}

    func update(from tab: BrowserTab?) {
        guard let tab else {
            accentColor = .clear
            return
        }
        accentColor = tab.dominantColor
    }
}
