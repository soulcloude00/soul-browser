import SwiftUI
import AppKit

/// Multi-Window Coordination & Architecture (Roadmap Item 5)
/// Migrate from a single-window model to a multi-window management
/// architecture using a coordinator pattern mapped to active Swift states.
final class WindowCoordinator: ObservableObject {
    static let shared = WindowCoordinator()

    @Published var windows: [SoulWindow] = []
    @Published var activeWindowID: UUID?

    private init() {}

    func createWindow(with store: BrowserStore) -> SoulWindow {
        let window = SoulWindow(id: UUID(), store: store)
        windows.append(window)
        activeWindowID = window.id
        return window
    }

    func closeWindow(id: SoulWindow.ID) {
        windows.removeAll { $0.id == id }
        if activeWindowID == id {
            activeWindowID = windows.first?.id
        }
    }

    func moveTab(_ tab: BrowserTab, from: SoulWindow.ID, to: SoulWindow.ID) {
        guard let source = windows.first(where: { $0.id == from }),
              let destination = windows.first(where: { $0.id == to }) else { return }
        source.store.closeTab(tab.id)
        let newTab = destination.store.newTab(url: tab.urlString, select: true)
        newTab.parentTabID = tab.parentTabID
    }
}

struct SoulWindow: Identifiable {
    let id: UUID
    let store: BrowserStore
    var frame: NSRect = NSMakeRect(100, 100, 1280, 820)
}
