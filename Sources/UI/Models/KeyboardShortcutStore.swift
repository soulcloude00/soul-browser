import SwiftUI
import AppKit

/// A mappable browser action.
enum ShortcutAction: String, CaseIterable, Identifiable {
    case newTab = "New Tab"
    case closeTab = "Close Tab"
    case reopenClosedTab = "Reopen Closed Tab"
    case reload = "Reload"
    case forceReload = "Force Reload"
    case findInPage = "Find in Page"
    case findNext = "Find Next"
    case findPrevious = "Find Previous"
    case toggleSidebar = "Toggle Sidebar"
    case toggleLauncher = "Toggle Launcher"
    case goBack = "Go Back"
    case goForward = "Go Forward"
    case goHome = "Go Home"
    case zoomIn = "Zoom In"
    case zoomOut = "Zoom Out"
    case resetZoom = "Reset Zoom"
    case toggleDevTools = "Developer Tools"
    case printPage = "Print"
    case selectNextTab = "Next Tab"
    case selectPreviousTab = "Previous Tab"
    case stop = "Stop Loading"
    case openSettings = "Settings"
    case focusOmnibox = "Focus Address Bar"
    case addBookmark = "Add Bookmark"
    // Roadmap feature shortcuts
    case capturePage = "Capture Page"
    case toggleHTTPInspector = "Toggle HTTP Inspector"
    case runPageSpeed = "Run Page Speed"
    case toggleAnnotation = "Toggle Annotation Mode"
    case detectStreams = "Detect Video Streams"
    case createWebApp = "Create Web App"
    case toggleTerminal = "Toggle Terminal"
    case archivePage = "Archive Page"

    var id: String { rawValue }

    /// The factory-default key equivalent (e.g. "command+t", "command+r").
    var defaultKey: String {
        switch self {
        case .newTab: return "command+t"
        case .closeTab: return "command+w"
        case .reopenClosedTab: return "command+shift+t"
        case .reload: return "command+r"
        case .forceReload: return "command+shift+r"
        case .findInPage: return "command+f"
        case .findNext: return "command+g"
        case .findPrevious: return "command+shift+g"
        case .toggleSidebar: return "command+s"
        case .toggleLauncher: return "command+k"
        case .goBack: return "command+["
        case .goForward: return "command+]"
        case .goHome: return "command+shift+h"
        case .zoomIn: return "command+="
        case .zoomOut: return "command+-"
        case .resetZoom: return "command+0"
        case .toggleDevTools: return "command+option+i"
        case .printPage: return "command+p"
        case .selectNextTab: return "command+shift+]"
        case .selectPreviousTab: return "command+shift+["
        case .stop: return "command+."
        case .openSettings: return "command+,"
        case .focusOmnibox: return "command+l"
        case .addBookmark: return "command+d"
        // Roadmap feature shortcuts
        case .capturePage: return "command+shift+5"
        case .toggleHTTPInspector: return "command+option+h"
        case .runPageSpeed: return "command+option+p"
        case .toggleAnnotation: return "command+option+a"
        case .detectStreams: return "command+option+d"
        case .createWebApp: return "command+option+w"
        case .toggleTerminal: return "command+option+t"
        case .archivePage: return "command+shift+a"
        }
    }
}

/// Stores user-overridden keyboard shortcuts and falls back to defaults.
final class KeyboardShortcutStore: ObservableObject {
    static let shared = KeyboardShortcutStore()

    @Published private(set) var overrides: [String: String] = [:]

    private let defaults: UserDefaults
    private let key = "soul.keyboardShortcuts"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let dict = defaults.dictionary(forKey: key) as? [String: String] {
            overrides = dict
        }
    }

    /// The active shortcut for an action (override or default).
    func shortcut(for action: ShortcutAction) -> String {
        overrides[action.rawValue] ?? action.defaultKey
    }

    /// Reverse lookup: find the action that matches a given shortcut string.
    func action(for shortcut: String) -> ShortcutAction? {
        for action in ShortcutAction.allCases {
            if self.shortcut(for: action) == shortcut {
                return action
            }
        }
        return nil
    }

    /// Whether the user has overridden this action.
    func isOverridden(_ action: ShortcutAction) -> Bool {
        overrides[action.rawValue] != nil
    }

    func setOverride(_ action: ShortcutAction, to key: String?) {
        if let key, !key.isEmpty {
            overrides[action.rawValue] = key
        } else {
            overrides.removeValue(forKey: action.rawValue)
        }
        save()
    }

    func resetToDefaults() {
        overrides.removeAll()
        save()
    }

    private func save() {
        defaults.set(overrides, forKey: key)
    }
}
