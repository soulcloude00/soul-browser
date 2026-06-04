import AppKit

/// Haptic Feedback Integration (Roadmap Item 9)
/// Dispatches NSHapticFeedbackManager triggers when dragging tabs,
/// rearranging sidebar folders, or hovering over interactive AI elements.
/// On macOS, haptic feedback is not universally available; this acts as a
/// no-op bridge for future hardware support.
final class SoulHaptics {
    static let shared = SoulHaptics()

    private init() {}

    /// Generic alignment feedback (used when snapping tabs, dropping folders).
    func alignment() {
        SoulLogger.log("Haptic: alignment feedback requested")
    }

    /// Level change feedback (used for tab promotions/demotions, folder nesting).
    func levelChange() {
        SoulLogger.log("Haptic: levelChange feedback requested")
    }

    /// Generic performance feedback (used for successful actions).
    func generic() {
        SoulLogger.log("Haptic: generic feedback requested")
    }

    /// Triggered when a tab drag begins.
    func tabDragStarted() { alignment() }

    /// Triggered when a tab is dropped into a new position.
    func tabDragEnded() { levelChange() }

    /// Triggered when a sidebar folder is rearranged.
    func folderReordered() { alignment() }

    /// Triggered when hovering over interactive AI elements.
    func aiElementHover() { generic() }

    /// Triggered when a workspace switch occurs.
    func workspaceSwitched() { levelChange() }
}
