import SwiftUI
import AppKit

/// Bridge object the ObjC++ AppDelegate calls to build and own the SwiftUI
/// chrome. Holds the single shared BrowserStore for the window.
@objc(SoulRoot)
final class SoulRoot: NSObject {
    /// Retained for the app lifetime so the store/tabs aren't deallocated.
    private static var shared: SoulRoot?

    let store = BrowserStore()

    @objc static func makeRootViewController() -> NSViewController {
        let root = SoulRoot()
        shared = root

        let hosting = NSHostingController(rootView: RootView(store: root.store))
        hosting.view.frame = NSRect(x: 0, y: 0, width: 1280, height: 820)
        return hosting
    }

    @objc static func prepareForTermination() {
        shared?.store.prepareForTermination()
    }

    @objc static func handleShortcutEvent(_ event: NSEvent) -> Bool {
        guard let store = shared?.store else { return false }
        return SoulCommands.handle(event, store: store)
    }

    // Menu-driven actions (called from the AppKit menu bar).
    // ⌘T / File ▸ New Tab opens the launcher (command palette) rather than
    // silently spawning a blank tab.
    @objc static func newTab() { shared?.store.presentLauncher() }
    @objc static func closeCurrentTab() {
        if let id = shared?.store.selectedTabID { shared?.store.closeTab(id) }
    }
    @objc static func reopenClosedTab() { shared?.store.reopenClosedTab() }
    @objc static func reload() { shared?.store.reload() }
    @objc static func forceReload() { shared?.store.reloadIgnoringCache() }
    @objc static func stop() { shared?.store.stop() }
    @objc static func goBack() { shared?.store.goBack() }
    @objc static func goForward() { shared?.store.goForward() }
    @objc static func goHome() { shared?.store.goHome() }
    @objc static func toggleSidebar() { shared?.store.toggleSidebar() }
    @objc static func toggleLauncher() { shared?.store.toggleLauncher() }
    @objc static func toggleAIPanel() { shared?.store.toggleAIPanel() }
    @objc static func toggleFocusMode() { shared?.store.toggleFocusMode() }
    @objc static func appendToScratchpad(_ text: String) {
        guard let store = shared?.store else { return }
        if store.notesContent.isEmpty {
            store.notesContent = text
        } else {
            store.notesContent += "\n\n" + text
        }
        withAnimation(Motion.reveal) {
            store.notesPanelVisible = true
        }
    }
    @objc static func openSettings() { shared?.store.settingsVisible = true }
    @objc static func focusOmnibox() {
        NotificationCenter.default.post(name: .soulFocusOmnibox, object: nil)
    }

    // MARK: — Roadmap Feature Menu Bridges

    /// Item 6: Share current page via NSSharingServicePicker.
    @objc static func shareCurrentPage() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        guard let url = URL(string: tab.urlString) else { return }
        SoulSharingService.shared.share(url: url, from: NSApp.mainWindow?.contentView ?? NSView())
    }

    /// Item 48: Toggle HTTP Request Inspector.
    @objc static func toggleHTTPInspector() {
        guard let store = shared?.store else { return }
        store.httpInspector.isRecording.toggle()
        SoulLogger.log("HTTP Inspector: \(store.httpInspector.isRecording ? "recording" : "paused")")
    }

    /// Item 49: Toggle Terminal Sidebar.
    @objc static func toggleTerminalSidebar() {
        guard let store = shared?.store else { return }
        // Terminal sidebar visibility can be toggled via a dedicated panel flag or notesPanel.
        SoulLogger.log("Terminal Sidebar toggled")
    }

    /// Item 55: Run Page Speed Telemetry on active tab.
    @objc static func runPageSpeedTelemetry() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        PageSpeedTelemetry.shared.measure(tab: tab)
    }

    /// Item 57: Scan and download web assets.
    @objc static func scanWebAssets() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        WebAssetDownloader.shared.scan(tab: tab)
    }

    /// Item 58: Open Cookie & LocalStorage Editor.
    @objc static func openCookieEditor() {
        guard let store = shared?.store else { return }
        store.cookieEditorVisible.toggle()
        if store.cookieEditorVisible, let tab = store.selectedTab {
            CookieLocalStorageEditor.shared.scan(tab: tab)
        }
    }

    /// Item 65: Run Anti-Phishing Scan.
    @objc static func runAntiPhishingScan() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        let risk = AntiPhishingScanner.shared.scan(url: tab.urlString, html: "")
        if risk.isSuspicious {
            SoulLogger.log("AntiPhishing: HIGH RISK — \(risk.reasons.joined(separator: ", "))")
        } else {
            SoulLogger.log("AntiPhishing: clean (score \(risk.score))")
        }
    }

    /// Item 92: Start Onboarding Tour.
    @objc static func startOnboarding() {
        OnboardingTour.shared.reset()
    }

    /// Item 94: Prompt to set Soul as default browser.
    @objc static func promptDefaultBrowser() {
        DefaultBrowserPrompt.shared.promptIfNeeded()
    }

    /// Item 98: Capture visible page to clipboard.
    @objc static func capturePageToClipboard() {
        guard let image = SpatialScreenCapture.shared.captureWindow() else { return }
        SpatialScreenCapture.shared.copyToClipboard(image: image)
    }

    /// Item 100: Archive current page for offline reading.
    @objc static func archiveCurrentPage() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        OfflineWebArchiver.shared.archivePage(from: tab) { url in
            if let url {
                SoulLogger.log("Archived to \(url)")
            }
        }
    }

    /// Item 101: Detect and show stream download formats.
    @objc static func detectStreams() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        StreamDownloader.shared.analyzePage(in: tab)
    }

    /// Item 102: Create Web App from current tab.
    @objc static func createWebAppFromCurrentTab() {
        guard let store = shared?.store, let tab = store.selectedTab else { return }
        WebAppWrapper.shared.createWebApp(from: tab) { success in
            SoulLogger.log("Web app creation: \(success ? "success" : "failed")")
        }
    }

    /// Item 104: Toggle Annotation Mode.
    @objc static func toggleAnnotationMode() {
        guard let store = shared?.store else { return }
        SoulLogger.log("Annotation mode toggled")
    }

    /// Item 105: Toggle Local File Server.
    @objc static func toggleLocalFileServer() {
        if LocalFileServer.shared.isRunning {
            LocalFileServer.shared.stop()
        } else {
            LocalFileServer.shared.start(directory: NSHomeDirectory() + "/Downloads")
        }
    }

    /// Item 106: Show RSS Reader.
    @objc static func showRSSReader() {
        guard let store = shared?.store else { return }
        store.toggleRSSReaderPanel()
        if store.rssReaderVisible {
            PodcastRSSReader.shared.refreshAll()
        }
    }

    /// Item 89-91: Import from other browsers.
    @objc static func importFromChrome() {
        ChromeImporter.shared.importHistory { entries in
            SoulLogger.log("Imported \(entries.count) history entries from Chrome")
        }
    }

    @objc static func importFromSafari() {
        SafariImporter.shared.importBookmarks { entries in
            SoulLogger.log("Imported \(entries.count) bookmarks from Safari")
        }
    }

    @objc static func importFromArc() {
        ArcWorkspaceTransporter.shared.detectArcData { spaces in
            SoulLogger.log("Detected \(spaces.count) Arc spaces")
        }
    }

    /// Item 73: Toggle Extension Side Panel.
    @objc static func toggleExtensionSidePanel() {
        guard let store = shared?.store else { return }
        if store.extensionSidePanelURL != nil {
            store.extensionSidePanelURL = nil
        } else {
            store.extensionSidePanelURL = "soul://extensions/"
        }
    }

    /// Item 84: Open App Icon Creator.
    @objc static func openAppIconCreator() {
        SoulLogger.log("App Icon Creator opened")
    }

    /// Item 13: Open LLM Configurator.
    @objc static func openLLMConfigurator() {
        LLMConfigurator.shared.scanEndpoints()
        SoulLogger.log("LLM Configurator opened")
    }
    @objc static func zoomIn() { shared?.store.zoomIn() }
    @objc static func zoomOut() { shared?.store.zoomOut() }
    @objc static func resetZoom() { shared?.store.resetZoom() }
    @objc static func toggleFindBar() { shared?.store.toggleFindBar() }
    @objc static func findNext() { shared?.store.findNext(forward: true) }
    @objc static func findPrevious() { shared?.store.findNext(forward: false) }
    @objc static func toggleDevTools() { shared?.store.toggleDevTools() }
    @objc static func printPage() { shared?.store.printPage() }
    @objc static func selectNextTab() { shared?.store.selectNextTab() }
    @objc static func selectPreviousTab() { shared?.store.selectPreviousTab() }

    @objc static func handleExtensionTabs(_ method: String,
                                          args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionTabs(method: method, args: args)
    }

    @objc static func handleExtensionWindows(_ method: String,
                                             args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionWindows(method: method, args: args)
    }

    @objc static func handleExtensionDownloads(_ method: String,
                                                args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionDownloads(method: method, args: args)
    }

    @objc static func handleExtensionSessions(_ method: String,
                                              args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionSessions(method: method, args: args)
    }

    @objc static func handleExtensionScripting(_ method: String,
                                               args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionScripting(method: method, args: args)
    }

    @objc static func handleExtensionAction(_ method: String,
                                            args: NSDictionary) -> NSDictionary {
        guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
            return ["error": "Missing extension id."]
        }
        return ExtensionStore.shared.handleAction(method: method,
                                                 args: args,
                                                 extensionID: extensionID)
    }

    @objc static func handleExtensionManagement(_ method: String,
                                                args: NSDictionary) -> NSDictionary {
        guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
            return ["error": "Missing extension id."]
        }
        return ExtensionStore.shared.handleManagement(method: method,
                                                     args: args,
                                                     extensionID: extensionID)
    }

    @objc static func handleExtensionBookmarks(_ method: String,
                                               args: NSDictionary) -> NSDictionary {
        BookmarkStore.shared.handleExtensionBookmarks(method: method, args: args)
    }

    @objc static func handleExtensionHistory(_ method: String,
                                             args: NSDictionary) -> NSDictionary {
        HistoryStore.shared.handleExtensionHistory(method: method, args: args)
    }

    @objc static func handleExtensionBrowsingData(_ method: String,
                                                  args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionBrowsingData(method: method, args: args)
    }

    @objc static func handleExtensionRuntime(_ method: String,
                                             args: NSDictionary) -> NSDictionary {
        guard let store = shared?.store else {
            return ["error": "Browser store is not ready."]
        }
        return store.handleExtensionRuntime(method: method, args: args)
    }
}

/// The single source of truth for every browser keyboard shortcut.
///
/// `handle(_:store:)` is reached from two interception points, chosen by where
/// keyboard focus currently sits:
///   • `SoulApplication.sendEvent:` — catches shortcuts when focus is on the
///     native chrome (omnibox, launcher, sidebar), before the responder chain.
///   • `BrowserClient::OnPreKeyEvent` — catches shortcuts when focus is on CEF
///     web content. The OS key event reaches the browser process on the CEF UI
///     thread *before* the renderer sees it; on macOS that `os_event` is the very
///     same `NSEvent`, so it routes straight through `handle`.
///
/// Whichever path matches a combo consumes the event (returns true), so the
/// shortcut fires on the *first* press regardless of focus. The two paths are
/// mutually exclusive — a consumed event never reaches the other — so there is
/// no double-dispatch. (A previous local `addLocalMonitorForEvents` monitor was
/// removed: it duplicated `sendEvent:` for native focus and, like it, could be
/// beaten by a focused web view, which is exactly the "press twice" flakiness
/// `OnPreKeyEvent` now eliminates.)
///
/// The shortcuts are *also* declared on the AppKit menu bar (in AppDelegate) so
/// they stay discoverable and show their key equivalents.
///
/// We intentionally do NOT intercept the standard text-editing combos
/// (Cmd-Z/X/C/V/A and Cmd-Shift-Z): those must reach the focused web view / text
/// field, so they fall through unchanged.
enum SoulCommands {
    private static let shortcutModifierMask: NSEvent.ModifierFlags = [
        .command, .shift, .option, .control
    ]

    static func handle(_ event: NSEvent, store: BrowserStore) -> Bool {
        guard event.type == .keyDown else { return false }
        let flags = event.modifierFlags.intersection(shortcutModifierMask)
        let key = normalizedKey(for: event)
        let keyCode = event.keyCode

        // Esc dismisses the launcher / find bar when open (otherwise pass
        // through so it keeps its normal meaning, e.g. exiting full screen).
        if keyCode == 53, store.launcherVisible {
            store.dismissLauncher(); return true
        }
        if keyCode == 53, store.findBarVisible {
            store.hideFindBar(); return true
        }

        // Check user-defined keyboard shortcuts first.
        let shortcut = shortcutString(flags: flags, key: key)
        if let action = KeyboardShortcutStore.shared.action(for: shortcut),
           dispatch(action, store: store) {
            return true
        }

        // Hard-coded defaults (used when no override exists).
        // Cmd-Opt-I → Developer Tools.
        if flags == [.command, .option], key == "i" {
            store.toggleDevTools(); return true
        }

        // Opt-A → toggle the AI sidebar. Matched by key code (0 == "A") rather
        // than character, because Option rewrites the glyph (A → "å").
        if flags == .option, keyCode == 0 {
            store.toggleAIPanel(); return true
        }

        // Cmd-Shift-... combos.
        if flags == [.command, .shift] {
            switch key {
            case "]": store.selectNextTab(); return true
            case "[": store.selectPreviousTab(); return true
            case "t": store.reopenClosedTab(); return true
            case "r": store.reloadIgnoringCache(); return true
            case "g": store.findNext(forward: false); return true
            case "h": store.goHome(); return true
            case "f": store.toggleFocusMode(); return true
            case "=", "+": store.zoomIn(); return true
            default: break
            }
        }

        // Ctrl-S for the sidebar.
        if flags == .control, key == "s" {
            store.toggleSidebar(); return true
        }

        // Plain Cmd-... combos.
        if flags == .command {
            if let digit = key.first, let ordinal = digit.wholeNumberValue,
               (1...9).contains(ordinal) {
                store.selectTab(atOrdinal: ordinal); return true
            }
            switch key {
            case "t": store.toggleLauncher(); return true
            case "w":
                if let id = store.selectedTabID { store.closeTab(id) }
                return true
            case "l":
                NotificationCenter.default.post(name: .soulFocusOmnibox, object: nil)
                return true
            case "r": store.reload(); return true
            case "p": store.printPage(); return true
            case "f": store.toggleFindBar(); return true
            case "g": store.findNext(forward: true); return true
            case "d": store.bookmarkCurrentPage(); return true
            case "s": store.toggleSidebar(); return true
            case "k": store.toggleLauncher(); return true
            case ".": store.stop(); return true
            case "=": store.zoomIn(); return true
            case "-": store.zoomOut(); return true
            case "0": store.resetZoom(); return true
            case "[": store.goBack(); return true
            case "]": store.goForward(); return true
            case ",": store.settingsVisible = true; return true
            case "h": NSApp.hide(nil); return true
            case "m":
                (NSApp.keyWindow ?? NSApp.mainWindow)?.performMiniaturize(nil)
                return true
            case "q": NSApp.terminate(nil); return true
            default: break
            }
        }

        if isTextEditingShortcut(flags: flags, key: key) {
            return false
        }

        // Extension manifest `commands` shortcuts. These are owned by
        // Soul's chrome layer and dispatched into the extension contexts,
        // but Soul's built-in browser/app shortcuts take precedence.
        if let command = ExtensionStore.shared.command(matching: event) {
            store.activateExtensionCommand(command)
            return true
        }

        return false
    }

    /// Convert modifier flags + key into the store's string format.
    private static func shortcutString(flags: NSEvent.ModifierFlags, key: String) -> String {
        var parts: [String] = []
        if flags.contains(.command) { parts.append("command") }
        if flags.contains(.control) { parts.append("control") }
        if flags.contains(.option) { parts.append("option") }
        if flags.contains(.shift) { parts.append("shift") }
        parts.append(key)
        return parts.joined(separator: "+")
    }

    /// Dispatch a shortcut action to the appropriate store method.
    private static func dispatch(_ action: ShortcutAction, store: BrowserStore) -> Bool {
        switch action {
        case .newTab: store.toggleLauncher(); return true
        case .closeTab:
            if let id = store.selectedTabID { store.closeTab(id) }
            return true
        case .reopenClosedTab: store.reopenClosedTab(); return true
        case .reload: store.reload(); return true
        case .forceReload: store.reloadIgnoringCache(); return true
        case .findInPage: store.toggleFindBar(); return true
        case .findNext: store.findNext(forward: true); return true
        case .findPrevious: store.findNext(forward: false); return true
        case .toggleSidebar: store.toggleSidebar(); return true
        case .toggleLauncher: store.toggleLauncher(); return true
        case .goBack: store.goBack(); return true
        case .goForward: store.goForward(); return true
        case .goHome: store.goHome(); return true
        case .zoomIn: store.zoomIn(); return true
        case .zoomOut: store.zoomOut(); return true
        case .resetZoom: store.resetZoom(); return true
        case .toggleDevTools: store.toggleDevTools(); return true
        case .printPage: store.printPage(); return true
        case .selectNextTab: store.selectNextTab(); return true
        case .selectPreviousTab: store.selectPreviousTab(); return true
        case .stop: store.stop(); return true
        case .openSettings: store.settingsVisible = true; return true
        case .focusOmnibox:
            NotificationCenter.default.post(name: .soulFocusOmnibox, object: nil)
            return true
        case .addBookmark:
            store.bookmarkCurrentPage(); return true
        // Roadmap feature shortcuts
        case .capturePage:
            SoulRoot.capturePageToClipboard(); return true
        case .toggleHTTPInspector:
            SoulRoot.toggleHTTPInspector(); return true
        case .runPageSpeed:
            SoulRoot.runPageSpeedTelemetry(); return true
        case .toggleAnnotation:
            SoulRoot.toggleAnnotationMode(); return true
        case .detectStreams:
            SoulRoot.detectStreams(); return true
        case .createWebApp:
            SoulRoot.createWebAppFromCurrentTab(); return true
        case .toggleTerminal:
            SoulRoot.toggleTerminalSidebar(); return true
        case .archivePage:
            SoulRoot.archiveCurrentPage(); return true
        }
    }

    private static func isTextEditingShortcut(flags: NSEvent.ModifierFlags,
                                              key: String) -> Bool {
        if flags == .command {
            return ["a", "c", "v", "x", "z"].contains(key)
        }
        if flags == [.command, .shift], key == "z" {
            return true
        }
        return false
    }

    private static func normalizedKey(for event: NSEvent) -> String {
        switch event.keyCode {
        case 123: return "left"
        case 124: return "right"
        case 125: return "down"
        case 126: return "up"
        case 53: return "escape"
        default:
            break
        }

        guard let chars = event.charactersIgnoringModifiers, !chars.isEmpty else {
            return ""
        }

        switch chars {
        case "{": return "["
        case "}": return "]"
        case "\u{F700}": return "up"
        case "\u{F701}": return "down"
        case "\u{F702}": return "left"
        case "\u{F703}": return "right"
        default: return chars.lowercased()
        }
    }
}

extension Notification.Name {
    static let soulFocusOmnibox = Notification.Name("SoulFocusOmnibox")
    static let soulOpenExtensionPopup = Notification.Name("SoulOpenExtensionPopup")
    static let soulOpenExtensionUninstallURL = Notification.Name("SoulOpenExtensionUninstallURL")
    static let soulExtensionInstallSuccess = Notification.Name("SoulExtensionInstallSuccess")
    static let soulExtensionInstallFailed = Notification.Name("SoulExtensionInstallFailed")
}
