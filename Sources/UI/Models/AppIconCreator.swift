import SwiftUI
import AppKit

/// Custom App Icon Creator (Roadmap Item 84)
/// Offers an array of styled Soul app icons (Liquid Glass, Classic macOS,
/// Minimal, Cyberpunk, Retro) in the Settings view.
final class AppIconCreator: ObservableObject {
    static let shared = AppIconCreator()

    @Published var currentStyle: IconStyle = .liquidGlass

    enum IconStyle: String, CaseIterable, Identifiable {
        case liquidGlass = "Liquid Glass"
        case classic = "Classic macOS"
        case minimal = "Minimal"
        case cyberpunk = "Cyberpunk"
        case retro = "Retro"

        var id: String { rawValue }
    }

    private init() {}

    func applyStyle(_ style: IconStyle) {
        currentStyle = style
        SoulLogger.log("AppIconCreator: applied \(style.rawValue)")
        // In production: regenerate app icon assets and update Info.plist
    }
}
