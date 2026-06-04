import Foundation

/// Workspace Audio Mixer & Muting (Roadmap Item 43)
/// Allows per-workspace or global muting and per-tab volume control,
/// with a spatial audio mixer in the sidebar.
final class WorkspaceAudioMixer: ObservableObject {
    static let shared = WorkspaceAudioMixer()

    @Published var globalVolume: Double = 1.0
    @Published var isGloballyMuted = false
    @Published var tabVolumes: [BrowserTab.ID: Double] = [:]
    @Published var mutedTabs: Set<BrowserTab.ID> = []

    private init() {}

    func setVolume(for tab: BrowserTab, volume: Double) {
        tabVolumes[tab.id] = max(0, min(1, volume))
        tab.browserView.evaluateJavaScript("document.querySelectorAll('audio, video').forEach(el => el.volume = \(volume));") { _, _ in }
    }

    func mute(tab: BrowserTab) {
        mutedTabs.insert(tab.id)
        tab.browserView.evaluateJavaScript("document.querySelectorAll('audio, video').forEach(el => el.muted = true);") { _, _ in }
    }

    func unmute(tab: BrowserTab) {
        mutedTabs.remove(tab.id)
        tab.browserView.evaluateJavaScript("document.querySelectorAll('audio, video').forEach(el => el.muted = false);") { _, _ in }
    }

    func toggleMute(tab: BrowserTab) {
        if mutedTabs.contains(tab.id) {
            unmute(tab: tab)
        } else {
            mute(tab: tab)
        }
    }

    func setGlobalVolume(_ volume: Double) {
        globalVolume = max(0, min(1, volume))
    }

    func toggleGlobalMute() {
        isGloballyMuted.toggle()
    }
}
