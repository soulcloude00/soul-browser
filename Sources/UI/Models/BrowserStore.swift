import SwiftUI
import AppKit

/// Top-level browser state: the open tabs, selection, and chrome toggles.
final class BrowserStore: ObservableObject {
    @Published var tabs: [BrowserTab] = []
    @Published var selectedTabID: BrowserTab.ID?
    @Published var sidebarVisible: Bool
    @Published var isFocusMode: Bool = false
    @Published var aiPanelVisible: Bool = false
    @Published var notesPanelVisible: Bool = false
    @Published var activeNoteName: String = "Default"
    @Published var availableNotes: [String] = ["Default"]
    @Published var notesContent: String = "" {
        didSet {
            saveNotes()
        }
    }
    @Published var extensionSidePanelURL: String?
    @Published var extensionSidePanelTitle: String?
    @Published var settingsVisible: Bool = false
    @Published var findBarVisible: Bool = false
    /// The new-tab launcher (command palette) overlay.
    @Published var launcherVisible: Bool = false
    @Published var miniConsoleVisible: Bool = false
    @Published var extensionManagerVisible: Bool = false
    /// True while the cursor is at the top edge: the web card slides down to
    /// reveal the titlebar (traffic lights) in the chrome above it.
    @Published var topChromeRevealed: Bool = false
    /// The active find-in-page query, held here so the Find Next / Previous menu
    /// commands can drive the search without the bar being focused.
    @Published var findQuery: String = ""
    /// Cookie & Storage Editor side panel (developer tool).
    @Published var cookieEditorVisible: Bool = false
    /// RSS Reader side panel.
    @Published var rssReaderVisible: Bool = false

    // MARK: Spaces / pinned tabs / folders (sidebar organization)

    /// The current space's label and emoji shown atop the sidebar.
    @Published var spaceName: String = "Personal"
    @Published var spaceEmoji: String = "✦"

    /// Tabs surfaced as icon tiles in the pinned grid, in order.
    @Published var pinnedTabIDs: [BrowserTab.ID] = []

    /// Collapsible folders grouping tabs.
    @Published var folders: [TabFolder] = []

    /// Folder row that should enter rename mode as soon as it renders.
    @Published var folderIDPendingRename: TabFolder.ID?

    /// Shared, persisted user preferences.
    let settings = BrowserSettings.shared

    /// Drives the sidebar media player from injected-agent broadcasts.
    let media = MediaController()

    // MARK: — Roadmap Feature Controllers (wired into BrowserStore)

    /// Heuristic tab suspension (Item 25)
    let tabSuspender = TabSuspender.shared

    /// Smart crash recovery (Item 38)
    let sessionResumption = SmartSessionResumption.shared

    /// HTTP request/response inspector (Item 48)
    let httpInspector = HTTPInspector.shared

    /// Terminal sidebar (Item 49)
    let terminalSidebar = TerminalSidebar.shared

    /// Color picker & design inspector (Item 51)
    let colorPicker = ColorPickerInspector.shared

    /// Page speed telemetry (Item 55)
    let pageSpeed = PageSpeedTelemetry.shared

    /// Web asset downloader (Item 57)
    let assetDownloader = WebAssetDownloader.shared

    /// Cookie & localStorage editor (Item 58)
    let cookieEditor = CookieLocalStorageEditor.shared

    /// Privacy: anti-phishing scanner (Item 65)
    let antiPhishing = AntiPhishingScanner.shared

    /// Privacy: HTTPS upgrader (Item 63)
    let httpsUpgrader = HTTPSUpgrader.shared

    /// Privacy: fingerprinting protection (Item 62)
    let fingerprintProtection = FingerprintingProtection.shared

    /// Privacy: Tor proxy (Item 64)
    let torProxy = TorProxyManager.shared

    /// Extension: Chrome Web Store injector (Item 70)
    let webStoreInjector = ChromeWebStoreInjector.shared

    /// Extension: side-panel API (Item 73)
    let extensionSidePanel = SoulExtensionAPI.shared

    /// AI: local LLM configurator (Item 13)
    let llmConfigurator = LLMConfigurator.shared

    /// AI: smart rewrite tool (Item 16)
    let smartRewrite = SmartRewriteTool.shared

    /// AI: form filler (Item 22)
    let formFiller = AIFormFiller.shared

    /// AI: tab grouping (Item 23)
    let tabGrouper = AITabGrouper.shared

    /// AI: reader mode AI summary (Item 14)
    let readerModeAI = ReaderModeAI.shared

    /// AI: clipboard context injector (Item 15)
    let clipboardInjector = ClipboardContextInjector.shared

    /// AI: voice transcription (Item 17)
    let voiceTranscription = VoiceTranscription.shared

    /// AI: developer helper panel (Item 24)
    let devHelper = DeveloperHelperPanel.shared

    /// AI: ad-blocker optimizer (Item 20)
    let adBlockOptimizer = AIAdBlockerOptimizer.shared

    /// AI: offline translator (Item 21)
    let offlineTranslator = OfflineTranslator.shared

    /// AI: semantic history indexer (Item 19)
    let semanticHistory = SemanticHistoryIndexer.shared

    /// AI: dark mode injector (Item 80)
    let darkModeInjector = AIDarkModeInjector.shared

    /// Multi-window coordination (Item 5)
    let windowCoordinator = WindowCoordinator.shared

    /// Workspace audio mixer (Item 43)
    let audioMixer = WorkspaceAudioMixer.shared

    /// Tab tree hierarchy manager (Item 40)
    let tabTree = TabTreeManager.shared

    /// LAN sync (Item 39)
    let lanSync = LANSyncManager.shared

    /// Memory visualizer (Item 26)
    let memoryVisualizer = MemoryVisualizer.shared

    /// Battery throttler (Item 33)
    let batteryThrottler = BatteryThrottler.shared

    /// Extension: resource throttle (Item 77)
    let extensionThrottle = ExtensionResourceThrottle.shared

    /// Extension: permission system (Item 76)
    let extensionPermission = ExtensionPermissionSystem.shared

    /// Extension: backup manager (Item 75)
    let extensionBackup = ExtensionBackupManager.shared

    /// Extension: message pipeline (Item 74)
    let extensionPipeline = ExtensionMessagePipeline.shared

    /// Extension: isolated content scripts (Item 72)
    let isolatedScripts = IsolatedContentScripts.shared

    /// Extension: sandbox (Item 61)
    let extensionSandbox = ExtensionSandbox.shared

    /// Extension: declarative net request (Item 71)
    let declarativeNetRequest = DeclarativeNetRequestEngine.shared

    /// Privacy dashboard (Item 60) – already in PrivacyDashboard.swift
    /// Spotlight indexer (Item 7)
    let spotlight = SoulSpotlightIndexer.shared

    /// Keychain bridge (Item 10)
    let keychain = SoulKeychain.shared

    /// Power manager (Item 11)
    let powerManager = SoulPowerManager.shared

    /// Haptics (Item 9)
    let haptics = SoulHaptics.shared

    /// Sharing service (Item 6)
    let sharing = SoulSharingService.shared

    /// Drag & drop pipeline (Item 12)
    let dragDrop = DragDropPipeline.shared

    /// Focus tracker (Item 103)
    let focusTracker = FocusTracker.shared

    /// Annotation highlighter (Item 104)
    let annotator = AnnotationHighlighter.shared

    /// Offline web archiver (Item 100)
    let webArchiver = OfflineWebArchiver.shared

    /// Stream downloader (Item 101)
    let streamDownloader = StreamDownloader.shared

    /// Web app wrapper (Item 102)
    let webAppWrapper = WebAppWrapper.shared

    /// Local file server (Item 105)
    let fileServer = LocalFileServer.shared

    /// Podcast/RSS reader (Item 106)
    let rssReader = PodcastRSSReader.shared

    /// Onboarding tour (Item 92)
    let onboarding = OnboardingTour.shared

    /// Search engine wizard (Item 93)
    let searchEngineWizard = SearchEngineWizard.shared

    /// Default browser prompt (Item 94)
    let defaultBrowserPrompt = DefaultBrowserPrompt.shared

    /// Credentials migration (Item 95)
    let credentialsMigration = CredentialsMigrationScanner.shared

    /// Extension sync bridge (Item 96)
    let extensionSync = ExtensionSyncBridge.shared

    /// Chrome importer (Item 89)
    let chromeImporter = ChromeImporter.shared

    /// Safari importer (Item 90)
    let safariImporter = SafariImporter.shared

    /// Arc workspace transporter (Item 91)
    let arcTransporter = ArcWorkspaceTransporter.shared

    /// Screen capture (Item 98)
    let screenCapture = SpatialScreenCapture.shared

    /// App icon creator (Item 84)
    let appIconCreator = AppIconCreator.shared

    /// Reader mode typography (Item 85)
    let readerTypography = ReaderModeTypography.shared

    /// Liquid glass animations (Item 81)
    let liquidGlassAnimations = LiquidGlassAnimations.self

    /// Adaptive accent color (Item 83)
    let adaptiveAccent = AdaptiveAccentColor.shared

    /// Adaptive favicon color (Item 87)
    let adaptiveFavicon = AdaptiveFaviconColor.shared

    /// Behind-window blur (Item 86)
    let behindWindowBlur = BehindWindowBlur.self

    /// Tab search console (Item 46)
    let tabSearch = TabSearchConsole.shared

    /// SSL certificate manager (Item 54)
    let sslManager = SSLCertificateManager.shared

    /// Permission controls (Item 66)
    let permissionControls = PermissionControls.shared

    /// Private session manager (Item 67)
    let privateSession = PrivateSessionManager.shared

    /// Media capture spoofer (Item 68)
    let mediaSpoofer = MediaCaptureSpoofer.shared

    /// Smart session resumption – see sessionResumption above

    /// JSON/XML formatter (Item 53)
    let jsonXMLFormatter = JSONXMLFormatter.shared

    /// Responsive layout canvas (Item 52)
    let responsiveCanvas = ResponsiveLayoutCanvas.self

    /// CEF GC sweeper (Item 28)
    let gcSweeper = CEFGCSweeper.shared

    /// CEF resource preloader (Item 29)
    let resourcePreloader = CEFResourcePreloader.shared

    /// Video decode accelerator (Item 30)
    let videoDecode = VideoDecodeAccelerator.shared

    /// Process priority rebalancer (Item 31)
    let priorityRebalancer = ProcessPriorityRebalancer.shared

    /// WebGL capture optimizer (Item 32)
    let webglOptimizer = WebGLCaptureOptimizer.shared

    /// Parallel renderer boot (Item 34)
    let parallelBoot = ParallelRendererBoot.shared

    /// V8 context allocator (Item 27)
    let v8Allocator = V8ContextAllocator.shared

    /// Tab preview cards (Item 37)
    let tabPreviews = TabPreviewCards.shared

    /// LAN sync (Item 39) – see lanSync above

    /// Localhost scanner (Item 47) – already in LocalhostScanner.swift
    let localhostScanner = LocalhostScanner()

    /// User script store (Item 50) – already in UserScriptStore.swift
    let userScripts = UserScriptStore.shared

    /// Extension manager overlay (Item 69) – already in ExtensionManagerOverlay.swift

    /// Privacy dashboard (Item 60) – already in PrivacyDashboard.swift

    /// Mini console (Item 56) – already in MiniConsoleView.swift

    /// Notes panel (Item 99) – already in NotesPanel.swift

    /// Media controller (Item 97) – already in MediaController.swift

    /// Media player (Item 97) – already in MediaPlayer.swift

    /// Launcher overlay (Item 41) – already in LauncherOverlay.swift

    /// Sidebar (Item 42) – already in Sidebar.swift

    /// Workspace manager (Item 42) – already in WorkspaceManagerView.swift

    /// Morphing folder icon (Item 88) – already in MorphingFolderIcon.swift

    /// Theme picker / OKLCH (Item 79) – already in ThemePicker.swift / OKLCH.swift

    /// Font registry (Item 82) – already in FontRegistry.swift

    /// PiP window styler (Item 8) – already in PiPWindowStyler.swift

    /// Browser automation (Item 18) – already in BrowserAutomation.swift

    /// Recently closed tabs, most-recent last. Powers Reopen Closed Tab and
    /// `chrome.sessions`.
    private struct ClosedTabSession {
        let sessionID: String
        let url: String
        let title: String
        let closedAt: Date
    }
    private var closedTabSessions: [ClosedTabSession] = []
    private struct ExtensionSidePanelOptions {
        var path: String?
        var enabled: Bool = true
    }
    private var sidePanelOptions: [String: ExtensionSidePanelOptions] = [:]
    private var sidePanelOpenOnActionClick: [String: Bool] = [:]
    private struct PendingIdentityFlow {
        let extensionID: String
        let requestID: String
        let redirectBase: String
        let redirectOrigin: String
    }
    private var pendingIdentityFlows: [BrowserTab.ID: PendingIdentityFlow] = [:]
    private var notificationObservers: [NSObjectProtocol] = []
    private let sessionFileURL: URL
    private var sessionSaveScheduled = false
    private var isRestoringSession = false
    private var suspensionTimer: Timer?

    private struct PersistedTab: Codable {
        var id: UUID
        var url: String
        var title: String
        var parentTabID: UUID?
        var isCollapsed: Bool?
        var splitTabID: UUID?
    }

    private struct PersistedSession: Codable {
        var tabs: [PersistedTab]
        var selectedTabID: UUID?
        var pinnedTabIDs: [UUID]
        var folders: [TabFolder]
        var spaceName: String
        var spaceEmoji: String
    }

    private struct AllSessions: Codable {
        var activeWorkspaceId: String
        var workspaces: [String: PersistedSession]
        var availableWorkspaces: [Workspace]?
    }

    @Published var activeWorkspaceId: String = "personal"
    @Published var availableWorkspaces: [Workspace] = [.personal, .work]
    private var workspaceSessions: [String: PersistedSession] = [:]

    /// The homepage, sourced from user settings.
    var homeURL: String { settings.homepageURL }

    init() {
        sessionFileURL = BrowserStore.supportDirectory()
            .appendingPathComponent("session.json")
        sidebarVisible = settings.showSidebarOnLaunch
        let startURL = ProcessInfo.processInfo.environment["MORI_START_URL"]
            .flatMap { $0.isEmpty ? nil : $0 }

        isRestoringSession = true
        if let startURL {
            let first = makeTab(url: startURL, title: "New Tab", workspaceID: activeWorkspaceId)
            tabs = [first]
            selectedTabID = first.id
        } else if !restoreSession() {
            let first = makeTab(url: settings.homepageURL, title: "New Tab", workspaceID: activeWorkspaceId)
            tabs = [first]
            selectedTabID = first.id
        }
        isRestoringSession = false
        loadNotes()
        
        // Clean up unused workspace cache directories
        let activeWorkspaceIDs = Set(availableWorkspaces.map { $0.id })
        WorkspaceCacheCleanup.cleanupUnusedWorkspaces(activeWorkspaceIDs: activeWorkspaceIDs)
        notificationObservers.append(
            NotificationCenter.default.addObserver(
                forName: .soulOpenExtensionUninstallURL,
                object: nil,
                queue: .main
            ) { [weak self] note in
                guard let self,
                      let url = note.userInfo?["url"] as? String,
                      !url.isEmpty
                else { return }
                _ = self.newTab(url: url, select: true)
                NSApp.activate(ignoringOtherApps: true)
                NSApp.mainWindow?.makeKeyAndOrderFront(nil)
            })

        // CWS install success / failure alerts.
        notificationObservers.append(
            NotificationCenter.default.addObserver(
                forName: .soulExtensionInstallSuccess,
                object: nil,
                queue: .main
            ) { note in
                guard let name = note.userInfo?["name"] as? String else { return }
                let alert = NSAlert()
                alert.messageText = "Added \"\(name)\" to Soul"
                alert.informativeText = "Reload pages to run its supported content scripts."
                alert.addButton(withTitle: "OK")
                alert.runModal()
            })
        notificationObservers.append(
            NotificationCenter.default.addObserver(
                forName: .soulExtensionInstallFailed,
                object: nil,
                queue: .main
            ) { note in
                guard let error = note.userInfo?["error"] as? String else { return }
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = "Couldn't install extension"
                alert.informativeText = error
                alert.addButton(withTitle: "OK")
                alert.runModal()
            })

        // Let the media controller map an engine broadcast back to its tab.
        media.resolveTab = { [weak self] browserId in
            self?.tabs.first {
                $0.hasRealized && Int($0.browserView.browserIdentifier) == browserId
            }
        }
        installExtensionCommandSmokeIfNeeded()
        
        self.suspensionTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkTabSuspension()
        }
        notificationObservers.append(
            NotificationCenter.default.addObserver(
                forName: .soulTabSuspenderCheck,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.checkTabSuspension()
            })
    }

    private func installExtensionCommandSmokeIfNeeded() {
        let env = ProcessInfo.processInfo.environment
        guard let extensionID = env["MORI_EXTENSION_SMOKE_COMMAND_ID"],
              !extensionID.isEmpty
        else { return }
        let commandName = env["MORI_EXTENSION_SMOKE_COMMAND_NAME"] ?? "_execute_action"
        let extraCommandName = env["MORI_EXTENSION_SMOKE_EXTRA_COMMAND_NAME"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            guard let command = ExtensionStore.shared.commands().first(where: {
                $0.extensionID == extensionID && $0.commandName == commandName
            }) else { return }
            self.activateExtensionCommand(command)
        }
        if let extraCommandName, !extraCommandName.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self else { return }
                guard let command = ExtensionStore.shared.commands().first(where: {
                    $0.extensionID == extensionID && $0.commandName == extraCommandName
                }) else { return }
                self.activateExtensionCommand(command)
            }
        }
    }

    var selectedTab: BrowserTab? {
        tabs.first { $0.id == selectedTabID }
    }

    // MARK: Session restore

    private static func supportDirectory() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent("SoulBrowser", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    @discardableResult
    private func restoreSession() -> Bool {
        guard let data = try? Data(contentsOf: sessionFileURL) else { return false }
        
        var decodedActiveId = "personal"
        var decodedWorkspaces: [Workspace]? = nil
        var sessionsMap: [String: PersistedSession] = [:]

        if let allSessions = try? JSONDecoder().decode(AllSessions.self, from: data) {
            decodedActiveId = allSessions.activeWorkspaceId
            decodedWorkspaces = allSessions.availableWorkspaces
            sessionsMap = allSessions.workspaces
        } else if let legacySession = try? JSONDecoder().decode(PersistedSession.self, from: data) {
            sessionsMap["personal"] = legacySession
        } else {
            return false
        }

        self.availableWorkspaces = decodedWorkspaces ?? [.personal, .work]
        self.workspaceSessions = sessionsMap
        
        return loadWorkspace(decodedActiveId)
    }

    @discardableResult
    private func loadWorkspace(_ id: String) -> Bool {
        self.activeWorkspaceId = id
        let session = workspaceSessions[id]
        if let ps = session {
            for pt in ps.tabs {
                let tab = makeTab(id: pt.id, url: pt.url, title: pt.title.isEmpty ? "New Tab" : pt.title, workspaceID: id, parentTabID: pt.parentTabID, isCollapsed: pt.isCollapsed ?? false, splitTabID: pt.splitTabID)
                tabs.append(tab)
            }
        }

        let liveIDs = Set(tabs.map(\.id))
        selectedTabID = session?.selectedTabID.flatMap { id in
            liveIDs.contains(id) ? id : nil
        } ?? tabs.first?.id
        pinnedTabIDs = session?.pinnedTabIDs.filter { liveIDs.contains($0) } ?? []
        folders = session?.folders.map { folder in
            var copy = folder
            copy.tabIDs = copy.tabIDs.filter { liveIDs.contains($0) }
            return copy
        } ?? []
        
        let ws = availableWorkspaces.first(where: { $0.id == id }) ?? .personal
        spaceName = ws.name
        spaceEmoji = ws.icon
        return !tabs.isEmpty
    }

    func switchWorkspace(_ id: String) {
        if id == activeWorkspaceId { return }
        saveCurrentWorkspaceToMap()
        
        for tab in tabs {
            tab.close()
        }
        
        if !loadWorkspace(id) {
            let first = makeTab(url: settings.homepageURL, title: "New Tab", workspaceID: id)
            tabs = [first]
            selectedTabID = first.id
        }
        scheduleSessionSave()
    }

    func addWorkspace(name: String, icon: String, colorHex: String?) {
        let newId = UUID().uuidString.lowercased()
        let ws = Workspace(id: newId, name: name, icon: icon, colorHex: colorHex)
        availableWorkspaces.append(ws)
        
        let emptySession = PersistedSession(
            tabs: [],
            selectedTabID: nil,
            pinnedTabIDs: [],
            folders: [],
            spaceName: name,
            spaceEmoji: icon
        )
        workspaceSessions[newId] = emptySession
        scheduleSessionSave()
    }
    
    func updateWorkspace(id: String, name: String, icon: String, colorHex: String?) {
        guard let idx = availableWorkspaces.firstIndex(where: { $0.id == id }) else { return }
        availableWorkspaces[idx].name = name
        availableWorkspaces[idx].icon = icon
        availableWorkspaces[idx].colorHex = colorHex
        
        if id == activeWorkspaceId {
            spaceName = name
            spaceEmoji = icon
        }
        
        if var session = workspaceSessions[id] {
            session.spaceName = name
            session.spaceEmoji = icon
            workspaceSessions[id] = session
        }
        
        scheduleSessionSave()
    }
    
    func deleteWorkspace(id: String) {
        guard availableWorkspaces.count > 1 else { return }
        guard let idx = availableWorkspaces.firstIndex(where: { $0.id == id }) else { return }
        
        if id == activeWorkspaceId {
            let otherIdx = idx == 0 ? 1 : 0
            let otherId = availableWorkspaces[otherIdx].id
            switchWorkspace(otherId)
        }
        
        availableWorkspaces.remove(at: idx)
        workspaceSessions.removeValue(forKey: id)
        
        // Clean up the deleted workspace's cache directory
        WorkspaceCacheCleanup.cleanupUnusedWorkspaces(activeWorkspaceIDs: Set(availableWorkspaces.map { $0.id }))
        
        scheduleSessionSave()
    }


    private func saveCurrentWorkspaceToMap() {
        guard !tabs.isEmpty else { return }
        let persistedTabs = tabs.map { PersistedTab(id: $0.id, url: $0.urlString, title: $0.title, parentTabID: $0.parentTabID, isCollapsed: $0.isCollapsed, splitTabID: $0.splitTabID) }
        let state = PersistedSession(
            tabs: persistedTabs,
            selectedTabID: selectedTabID,
            pinnedTabIDs: pinnedTabIDs,
            folders: folders,
            spaceName: spaceName,
            spaceEmoji: spaceEmoji
        )
        workspaceSessions[activeWorkspaceId] = state
    }

    func scheduleSessionSave() {
        guard !isRestoringSession, !sessionSaveScheduled else { return }
        sessionSaveScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.sessionSaveScheduled = false
            self.saveSession()
        }
    }

    private func saveSession() {
        saveCurrentWorkspaceToMap()
        let allSessions = AllSessions(
            activeWorkspaceId: activeWorkspaceId,
            workspaces: workspaceSessions,
            availableWorkspaces: availableWorkspaces
        )
        guard let data = try? JSONEncoder().encode(allSessions) else { return }
        try? data.write(to: sessionFileURL, options: .atomic)
    }

    private func makeTab(id: BrowserTab.ID = UUID(), url: String, title: String, workspaceID: String = "personal", parentTabID: UUID? = nil, isCollapsed: Bool = false, splitTabID: UUID? = nil) -> BrowserTab {
        let tab = BrowserTab(id: id, url: url, title: title, workspaceID: workspaceID, parentTabID: parentTabID, isCollapsed: isCollapsed, splitTabID: splitTabID)
        tab.onRequestNewTab = { [weak self, weak tab] url in
            self?.newTab(url: url, parentTabID: tab?.id)
        }
        tab.onExtensionTabUpdated = { [weak self] tab, changeInfo in
            self?.emitExtensionTabUpdated(tab, changeInfo: changeInfo)
            if changeInfo["url"] != nil || changeInfo["title"] != nil {
                self?.scheduleSessionSave()
            }
            if let url = changeInfo["url"] as? String {
                self?.completeIdentityFlowIfNeeded(tab: tab, url: url)
            }
        }
        tab.onExtensionNavigationEvent = { [weak self] eventName, tab, details in
            self?.emitExtensionWebNavigation(eventName, tab: tab, details: details)
            if let url = details["url"] as? String {
                self?.completeIdentityFlowIfNeeded(tab: tab, url: url)
            }
        }
        return tab
    }

    // MARK: Tab management

    @discardableResult
    func newTab(url: String? = nil, select: Bool = true, parentTabID: UUID? = nil) -> BrowserTab {
        let initialURL = SoulURLRewriter.rewrite(url ?? settings.newTabURL)
        let tab = makeTab(url: initialURL, title: "New Tab", workspaceID: activeWorkspaceId, parentTabID: parentTabID)
        tabs.append(tab)
        emitExtensionEvent("tabs.onCreated", args: [extensionTabRecord(tab)])
        if select { selectTab(tab.id) }
        scheduleSessionSave()
        return tab
    }

    func selectTab(_ id: BrowserTab.ID) {
        let previous = selectedTabID
        selectedTabID = id
        
        if let tab = selectedTab {
            if tab.isSuspended {
                tab.unsuspend()
            }
            tab.lastActiveAt = Date()
        }
        
        selectedTab?.realize()
        if previous != id { scheduleSessionSave() }
        if previous != id, let tab = selectedTab {
            emitExtensionEvent("tabs.onActivated", args: [[
                "tabId": tab.extensionTabID,
                "windowId": 1
            ]])
            emitExtensionEvent("tabs.onHighlighted", args: [[
                "tabIds": [tab.extensionTabID],
                "windowId": 1
            ]])
        }
    }

    private func checkTabSuspension() {
        let now = Date()
        // Fast-path: if no tabs are even close to eligible, skip the full scan.
        let hasCandidate = tabs.contains { tab in
            tab.id != selectedTabID &&
            !tab.isSuspended &&
            !pinnedTabIDs.contains(tab.id) &&
            now.timeIntervalSince(tab.lastActiveAt) > 300
        }
        guard hasCandidate else { return }

        var tabsToClose: [UUID] = []
        for tab in tabs {
            guard tab.id != selectedTabID else { continue }
            guard !tab.isSuspended else { continue }
            guard !pinnedTabIDs.contains(tab.id) else { continue }

            if tab.hasRealized {
                let bid = Int(tab.browserView.browserIdentifier)
                guard !media.isPlayingMedia(browserId: bid) else { continue }
            }

            if now.timeIntervalSince(tab.lastActiveAt) > 86400 {
                tabsToClose.append(tab.id)
            } else if now.timeIntervalSince(tab.lastActiveAt) > 300 {
                tab.suspend()
            }
        }
        for id in tabsToClose {
            closeTab(id)
        }
    }

    // MARK: New-tab launcher (command palette)

    /// Open the new-tab launcher instead of immediately creating a blank tab, so
    /// the user can search, jump to an open tab, or pick from history first.
    func presentLauncher() {
        withAnimation(Motion.reveal) { launcherVisible = true }
    }

    /// ⌘T behavior: open the launcher, or close it again if it's already up.
    func toggleLauncher() {
        if launcherVisible {
            dismissLauncher()
        } else {
            presentLauncher()
        }
    }

    func dismissLauncher() {
        withAnimation(Motion.reveal) { launcherVisible = false }
    }

    // MARK: - Extension Manager (Command Palette Style)

    func presentExtensionManager() {
        withAnimation(Motion.reveal) { extensionManagerVisible = true }
    }

    func toggleExtensionManager() {
        if extensionManagerVisible {
            dismissExtensionManager()
        } else {
            presentExtensionManager()
        }
    }

    func dismissExtensionManager() {
        withAnimation(Motion.reveal) { extensionManagerVisible = false }
    }

    /// Commit typed launcher text: open it (URL or search) in a fresh tab.
    func launcherOpen(_ input: String) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        dismissLauncher()
        guard !text.isEmpty else { newTab(); return }
        newTab(url: URLInterpreter.resolve(text, settings: settings), select: true)
    }

    /// Open a chosen destination (history / suggestion) in a fresh tab.
    func launcherOpen(url: String) {
        dismissLauncher()
        newTab(url: url, select: true)
    }

    /// Jump to an already-open tab from the launcher.
    func launcherSwitch(to id: BrowserTab.ID) {
        dismissLauncher()
        selectTab(id)
    }
    
    func splitTab(_ id: BrowserTab.ID, with otherID: BrowserTab.ID) {
        guard let tab1 = tabs.first(where: { $0.id == id }),
              let tab2 = tabs.first(where: { $0.id == otherID }) else { return }
        
        tab1.splitTabID = tab2.id
        tab2.splitTabID = tab1.id
        
        tab1.realize()
        tab2.realize()
        
        scheduleSessionSave()
        objectWillChange.send()
    }
    
    func unsplitTab(_ id: BrowserTab.ID) {
        guard let tab = tabs.first(where: { $0.id == id }) else { return }
        
        if let partnerID = tab.splitTabID {
            if let partner = tabs.first(where: { $0.id == partnerID }) {
                partner.splitTabID = nil
            }
        }
        tab.splitTabID = nil
        
        scheduleSessionSave()
        objectWillChange.send()
    }

    func closeTab(_ id: BrowserTab.ID, allowPinned: Bool = false) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        // Pinned tabs are permanent: a close gesture (Cmd-W, close button) is
        // ignored. They can only be removed by explicitly unpinning them.
        if pinnedTabIDs.contains(id), !allowPinned { return }
        let tab = tabs[idx]
        let extensionTabID = tab.extensionTabID
        // Remember where it was pointing so Cmd-Shift-T can bring it back.
        let url = tab.urlString
        if url != "about:blank", !url.isEmpty {
            closedTabSessions.append(ClosedTabSession(sessionID: UUID().uuidString,
                                                      url: url,
                                                      title: tab.title,
                                                      closedAt: Date()))
            if closedTabSessions.count > settings.closedTabHistoryLimit { closedTabSessions.removeFirst() }
            emitExtensionEvent("sessions.onChanged", args: [])
        }
        
        // Clear splits
        if let partnerID = tab.splitTabID {
            if let partner = tabs.first(where: { $0.id == partnerID }) {
                partner.splitTabID = nil
            }
        }
        for otherTab in tabs where otherTab.splitTabID == id {
            otherTab.splitTabID = nil
        }
        
        // Reparent children to this tab's parent
        for childTab in tabs where childTab.parentTabID == id {
            childTab.parentTabID = tab.parentTabID
        }
        
        if tab.hasRealized {
            media.removeBrowser(Int(tab.browserView.browserIdentifier))
        }
        tab.close()
        tabs.remove(at: idx)
        pinnedTabIDs.removeAll { $0 == id }
        for folderIndex in folders.indices {
            folders[folderIndex].tabIDs.removeAll { $0 == id }
        }
        emitExtensionEvent("tabs.onRemoved", args: [
            extensionTabID,
            ["windowId": 1, "isWindowClosing": false]
        ])

        if tabs.isEmpty {
            // Always keep at least one tab open.
            let fresh = newTab(select: true)
            selectedTabID = fresh.id
            return
        }
        if selectedTabID == id {
            let newIndex = min(idx, tabs.count - 1)
            selectTab(tabs[newIndex].id)
        }
        scheduleSessionSave()
    }

    func moveTab(from source: IndexSet, to destination: Int) {
        let before = tabs
        let movedIDs = Set(source.compactMap { before.indices.contains($0) ? before[$0].id : nil })
        tabs.move(fromOffsets: source, toOffset: destination)
        emitExtensionTabMoveEvents(before: before, movedIDs: movedIDs)
        scheduleSessionSave()
    }

    @discardableResult
    func duplicateTab(_ id: BrowserTab.ID, select: Bool = true) -> BrowserTab? {
        guard let tab = tabs.first(where: { $0.id == id }) else { return nil }
        let duplicate = makeTab(url: tab.urlString, title: tab.title, workspaceID: activeWorkspaceId)
        duplicate.faviconURL = tab.faviconURL
        let sourceIndex = tabs.firstIndex { $0.id == id } ?? tabs.count - 1
        tabs.insert(duplicate, at: min(sourceIndex + 1, tabs.count))
        emitExtensionEvent("tabs.onCreated", args: [extensionTabRecord(duplicate)])
        if select { selectTab(duplicate.id) }
        scheduleSessionSave()
        return duplicate
    }

    func copyURL(of id: BrowserTab.ID) {
        guard let url = tabs.first(where: { $0.id == id })?.urlString,
              !url.isEmpty
        else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(url, forType: .string)
    }

    func closeOtherTabs(than id: BrowserTab.ID) {
        let ids = tabs
            .map(\.id)
            .filter { $0 != id && !pinnedTabIDs.contains($0) }
        for tabID in ids {
            closeTab(tabID)
        }
        selectTab(id)
    }

    func closeTabsToRight(of id: BrowserTab.ID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }),
              index + 1 < tabs.count
        else { return }
        let ids = tabs[(index + 1)...]
            .map(\.id)
            .filter { !pinnedTabIDs.contains($0) }
        for tabID in ids {
            closeTab(tabID)
        }
        selectTab(id)
    }

    func hasClosableTabsToRight(of id: BrowserTab.ID) -> Bool {
        guard let index = tabs.firstIndex(where: { $0.id == id }),
              index + 1 < tabs.count
        else { return false }
        return tabs[(index + 1)...].contains { !pinnedTabIDs.contains($0.id) }
    }

    /// Reopen the most recently closed tab, restoring its last URL.
    func reopenClosedTab() {
        guard let session = closedTabSessions.popLast() else { return }
        _ = newTab(url: session.url, select: true)
        emitExtensionEvent("sessions.onChanged", args: [])
    }

    /// Select the tab at a 1-based slot (Cmd-1…Cmd-9). By convention the
    /// highest slot, 9, always jumps to the *last* tab regardless of count.
    ///
    /// Slots follow the sidebar's visual order — pinned tabs first — so Cmd-1
    /// lands on the first pinned tab. Recomputed on each press, so it tracks
    /// pinning/unpinning dynamically.
    func selectTab(atOrdinal ordinal: Int) {
        let ordered = orderedTabsForShortcuts
        guard !ordered.isEmpty else { return }
        let index = ordinal >= 9 ? ordered.count - 1 : ordinal - 1
        guard ordered.indices.contains(index) else { return }
        selectTab(ordered[index].id)
    }

    /// Tab order used by the Cmd-1…Cmd-9 shortcuts: pinned tabs first (matching
    /// the sidebar), then the remaining tabs in their existing order.
    private var orderedTabsForShortcuts: [BrowserTab] {
        pinnedTabs + tabs.filter { !pinnedTabIDs.contains($0.id) }
    }

    /// Cycle to the next/previous tab, wrapping around at the ends.
    func selectNextTab() { cycleTab(by: 1) }
    func selectPreviousTab() { cycleTab(by: -1) }

    private func cycleTab(by delta: Int) {
        guard tabs.count > 1,
              let current = tabs.firstIndex(where: { $0.id == selectedTabID })
        else { return }
        let next = (current + delta + tabs.count) % tabs.count
        selectTab(tabs[next].id)
    }

    // MARK: Navigation on the active tab

    func goBack() { selectedTab?.goBack() }
    func goForward() { selectedTab?.goForward() }
    func reload() { selectedTab?.reload() }
    func reloadIgnoringCache() { selectedTab?.reloadIgnoringCache() }
    func stop() { selectedTab?.stop() }

    func zoomIn() { selectedTab?.zoomIn() }
    func zoomOut() { selectedTab?.zoomOut() }
    func resetZoom() { selectedTab?.resetZoom() }

    func toggleDevTools() { selectedTab?.toggleDevTools() }
    func printPage() { selectedTab?.printPage() }

    func bookmarkCurrentPage() {
        guard let tab = selectedTab, !tab.urlString.isEmpty else { return }
        let title = tab.title.isEmpty ? tab.urlString : tab.title
        let added = BookmarkStore.shared.toggle(url: tab.urlString, title: title)
        if added {
            SoulLogger.info("Bookmarked \(tab.urlString)", category: SoulLogger.browser)
        }
    }

    // MARK: Find-in-page

    func showFindBar() {
        withAnimation(Motion.snappy) { findBarVisible = true }
        if !findQuery.isEmpty { selectedTab?.find(findQuery, forward: true) }
    }

    func hideFindBar() {
        selectedTab?.stopFind()
        withAnimation(Motion.snappy) { findBarVisible = false }
    }

    func toggleFindBar() {
        if findBarVisible { hideFindBar() } else { showFindBar() }
    }

    /// Re-run the current query, advancing to the next/previous match. Opens the
    /// bar first if it's closed (Cmd-G with no bar yet).
    func findNext(forward: Bool) {
        guard !findQuery.isEmpty else { showFindBar(); return }
        if !findBarVisible { showFindBar() }
        selectedTab?.find(findQuery, forward: forward)
    }

    /// Interpret omnibox text as either a URL or a search query.
    func navigate(_ input: String) {
        let resolved = SoulURLRewriter.rewrite(
            URLInterpreter.resolve(input, settings: settings))
        selectedTab?.load(resolved)
    }

    // MARK: Extension tab bridge

    func handleExtensionRuntime(method: String, args: NSDictionary) -> NSDictionary {
        switch method {
        case "runtime.openOptionsPage":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            guard let url = ExtensionStore.shared.optionsURL(forExtensionID: extensionID) else {
                return ["error": "Extension has no options page."]
            }
            _ = newTab(url: url, select: true)
            NSApp.activate(ignoringOtherApps: true)
            NSApp.mainWindow?.makeKeyAndOrderFront(nil)
            return ["result": NSNull()]

        case "runtime.getContexts":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            let filter = args["filter"] as? NSDictionary ?? [:]
            return ["result": ExtensionStore.shared.runtimeContexts(forExtensionID: extensionID, filter: filter)]

        case "runtime.setUninstallURL":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            let url = args["url"] as? String ?? ""
            return ExtensionStore.shared.setUninstallURL(forExtensionID: extensionID, url: url)

        case "identity.launchWebAuthFlow":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty,
                  let requestID = args["requestId"] as? String, !requestID.isEmpty
            else {
                return ["error": "Missing identity flow metadata."]
            }
            let details = args["details"] as? NSDictionary ?? [:]
            guard (details["interactive"] as? NSNumber)?.boolValue ?? true else {
                return ["error": "Non-interactive identity flows are not supported in Soul yet."]
            }
            guard let url = details["url"] as? String, !url.isEmpty else {
                return ["error": "Missing identity URL."]
            }
            let redirectOrigin = "https://\(extensionID).chromiumapp.org/"
            let tab = newTab(url: url, select: true)
            pendingIdentityFlows[tab.id] = PendingIdentityFlow(
                extensionID: extensionID,
                requestID: requestID,
                redirectBase: redirectOrigin,
                redirectOrigin: redirectOrigin
            )
            completeIdentityFlowIfNeeded(tab: tab, url: tab.urlString)
            return ["deferred": true, "result": NSNull()]

        case "sidePanel.setOptions":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            let details = args["details"] as? NSDictionary ?? [:]
            var options = sidePanelOptions[extensionID] ?? ExtensionSidePanelOptions()
            if let path = details["path"] as? String {
                options.path = path.isEmpty ? nil : path
            }
            if let enabled = details["enabled"] as? NSNumber {
                options.enabled = enabled.boolValue
            }
            sidePanelOptions[extensionID] = options
            if !options.enabled, extensionSidePanelURL == sidePanelURL(forExtensionID: extensionID) {
                closeExtensionSidePanel()
            }
            return ["result": NSNull()]

        case "sidePanel.getOptions":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            let options = sidePanelOptions[extensionID] ?? ExtensionSidePanelOptions()
            var result: [String: Any] = ["enabled": options.enabled]
            if let path = options.path {
                result["path"] = path
            } else if let url = ExtensionStore.shared.sidePanelURL(forExtensionID: extensionID),
                      let parsed = URL(string: url) {
                result["path"] = String(parsed.path.drop(while: { $0 == "/" }))
            }
            return ["result": result]

        case "sidePanel.open":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            guard openExtensionSidePanel(extensionID: extensionID) else {
                return ["error": "This extension does not have an enabled side panel."]
            }
            return ["result": NSNull()]

        case "sidePanel.close":
            closeExtensionSidePanel()
            return ["result": NSNull()]

        case "sidePanel.setPanelBehavior":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            let behavior = args["behavior"] as? NSDictionary ?? [:]
            if let value = behavior["openPanelOnActionClick"] as? NSNumber {
                sidePanelOpenOnActionClick[extensionID] = value.boolValue
            }
            return ["result": NSNull()]

        case "sidePanel.getPanelBehavior":
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            return ["result": [
                "openPanelOnActionClick": sidePanelOpenOnActionClick[extensionID] ?? false
            ]]

        default:
            return ["error": "Unsupported runtime method: \(method)"]
        }
    }

    func handleExtensionTabs(method: String, args: NSDictionary) -> NSDictionary {
        switch method {
        case "tabs.query":
            let queryInfo = args["queryInfo"] as? NSDictionary ?? [:]
            let result = extensionTabs(matching: queryInfo).map(extensionTabRecord)
            return ["result": result]

        case "tabs.get":
            guard let tab = extensionTab(for: args["tabId"]) else {
                return ["error": "No tab with that id."]
            }
            return ["result": extensionTabRecord(tab)]

        case "tabs.getCurrent":
            guard let tab = selectedTab else {
                return ["result": NSNull()]
            }
            return ["result": extensionTabRecord(tab)]

        case "tabs.create":
            let props = args["createProperties"] as? NSDictionary ?? [:]
            let url = props["url"] as? String
            let active = (props["active"] as? NSNumber)?.boolValue ?? true
            let tab = newTab(url: url, select: active)
            return ["result": extensionTabRecord(tab)]

        case "tabs.duplicate":
            guard let tab = extensionTab(for: args["tabId"]) else {
                return ["error": "No tab with that id."]
            }
            guard let duplicate = duplicateTab(tab.id, select: true) else {
                return ["error": "Could not duplicate that tab."]
            }
            return ["result": extensionTabRecord(duplicate)]

        case "tabs.reload":
            let tab = extensionTab(for: args["tabId"]) ?? selectedTab
            guard let tab else { return ["error": "No active tab."] }
            let props = args["reloadProperties"] as? NSDictionary ?? [:]
            if (props["bypassCache"] as? NSNumber)?.boolValue == true {
                tab.reloadIgnoringCache()
            } else {
                tab.reload()
            }
            return ["result": NSNull()]

        case "tabs.goBack":
            let tab = extensionTab(for: args["tabId"]) ?? selectedTab
            guard let tab else { return ["error": "No active tab."] }
            if tab.canGoBack { tab.goBack() }
            return ["result": NSNull()]

        case "tabs.goForward":
            let tab = extensionTab(for: args["tabId"]) ?? selectedTab
            guard let tab else { return ["error": "No active tab."] }
            if tab.canGoForward { tab.goForward() }
            return ["result": NSNull()]

        case "tabs.getZoom":
            let tab = extensionTab(for: args["tabId"]) ?? selectedTab
            guard let tab else { return ["error": "No active tab."] }
            return ["result": Double(tab.zoomPercent) / 100.0]

        case "tabs.setZoom":
            let tab = extensionTab(for: args["tabId"]) ?? selectedTab
            guard let tab else { return ["error": "No active tab."] }
            let factor = (args["zoomFactor"] as? NSNumber)?.doubleValue ?? 1.0
            tab.setZoomFactor(factor)
            return ["result": NSNull()]

        case "tabs.getZoomSettings":
            return ["result": [
                "mode": "automatic",
                "scope": "per-tab",
                "defaultZoomFactor": 1.0
            ]]

        case "tabs.setZoomSettings":
            return ["result": NSNull()]

        case "tabs.captureVisibleTab":
            guard let tab = selectedTab else {
                return ["error": "No active tab."]
            }
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty,
                  let requestID = args["requestId"] as? String, !requestID.isEmpty else {
                return ["error": "tabs.captureVisibleTab requires an extension request."]
            }
            guard tab.captureVisiblePNGDataURL(extensionID: extensionID, requestID: requestID) else {
                return ["error": "The active tab is not ready to capture."]
            }
            return ["deferred": true, "result": NSNull()]

        case "tabs.remove":
            let tabIDs = extensionTabIDs(from: args["tabIds"])
            guard !tabIDs.isEmpty else {
                return ["error": "tabs.remove requires a tab id."]
            }
            for tabID in tabIDs {
                guard let tab = extensionTab(for: NSNumber(value: tabID)) else {
                    return ["error": "No tab with id \(tabID)."]
                }
                closeTab(tab.id, allowPinned: true)
            }
            return ["result": NSNull()]

        case "tabs.move":
            let tabIDs = extensionTabIDs(from: args["tabIds"])
            guard !tabIDs.isEmpty else {
                return ["error": "tabs.move requires at least one tab id."]
            }
            let before = tabs
            let movingTabs = tabIDs.compactMap {
                extensionTab(for: NSNumber(value: $0))
            }
            guard movingTabs.count == tabIDs.count else {
                return ["error": "No tab with one of those ids."]
            }
            let props = args["moveProperties"] as? NSDictionary ?? [:]
            let requestedIndex = (props["index"] as? NSNumber)?.intValue ?? tabs.count
            let movingIDs = Set(movingTabs.map(\.id))
            tabs.removeAll { movingIDs.contains($0.id) }
            var insertionIndex = requestedIndex < 0
                ? tabs.count
                : max(0, min(Int(requestedIndex), tabs.count))
            for tab in movingTabs {
                tabs.insert(tab, at: insertionIndex)
                insertionIndex += 1
            }
            emitExtensionTabMoveEvents(before: before, movedIDs: movingIDs)
            let records = movingTabs.map(extensionTabRecord)
            return ["result": tabIDs.count == 1 ? records[0] : records]

        case "tabs.update":
            let tab = extensionTab(for: args["tabId"]) ?? selectedTab
            guard let tab else { return ["error": "No active tab."] }
            let props = args["updateProperties"] as? NSDictionary ?? [:]
            if let active = props["active"] as? NSNumber, active.boolValue {
                selectTab(tab.id)
            }
            if let url = props["url"] as? String, !url.isEmpty {
                tab.load(SoulURLRewriter.rewrite(url))
            }
            return ["result": extensionTabRecord(tab)]

        case "tabs.highlight":
            let info = args["highlightInfo"] as? NSDictionary ?? [:]
            let indices = extensionTabIndices(from: info["tabs"])
            guard let index = indices.first,
                  tabs.indices.contains(index)
            else { return ["error": "No tab with that index."] }
            selectTab(tabs[index].id)
            return ["result": extensionWindowRecord(populate: true)]

        case "tabs.sendMessage":
            guard let tab = extensionTab(for: args["tabId"]) else {
                return ["error": "No tab with that id."]
            }
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty else {
                return ["error": "Missing extension id."]
            }
            let message = args["message"] ?? NSNull()
            let requestID = args["messageRequestId"] ?? NSNull()
            let sourceURL = args["sourceUrl"] ?? NSNull()
            let sourceOrigin = args["sourceOrigin"] ?? NSNull()
            let source = "if(window.__soulExtDispatchMessage){window.__soulExtDispatchMessage(\(jsonLiteral(extensionID)),\(jsonLiteral(message)),\(jsonLiteral(requestID)),\(jsonLiteral(sourceURL)),\(jsonLiteral(sourceOrigin)));}"
            tab.realize().executeExtensionJavaScript(source, allFrames: true)
            return ["result": NSNull()]

        default:
            return ["error": "Unsupported tabs method: \(method)"]
        }
    }

    func handleExtensionWindows(method: String, args: NSDictionary) -> NSDictionary {
        switch method {
        case "windows.getCurrent", "windows.getLastFocused":
            let populate = (args["populate"] as? NSNumber)?.boolValue ?? false
            return ["result": extensionWindowRecord(populate: populate)]

        case "windows.get":
            let windowID = (args["windowId"] as? NSNumber)?.intValue ?? 1
            guard windowID == 1 || windowID == -2 else {
                return ["error": "No Soul window with that id."]
            }
            let getInfo = args["getInfo"] as? NSDictionary ?? [:]
            let populate = (getInfo["populate"] as? NSNumber)?.boolValue ?? false
            return ["result": extensionWindowRecord(populate: populate)]

        case "windows.getAll":
            let getInfo = args["getInfo"] as? NSDictionary ?? [:]
            let populate = (getInfo["populate"] as? NSNumber)?.boolValue ?? false
            return ["result": [extensionWindowRecord(populate: populate)]]

        case "windows.create":
            let props = args["createData"] as? NSDictionary ?? [:]
            let urls = extensionWindowCreateURLs(props["url"])
            if urls.isEmpty {
                _ = newTab(select: true)
            } else {
                for (idx, url) in urls.enumerated() {
                    _ = newTab(url: url, select: idx == 0)
                }
            }
            if (props["focused"] as? NSNumber)?.boolValue ?? true {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.mainWindow?.makeKeyAndOrderFront(nil)
            }
            emitExtensionEvent("windows.onCreated",
                               args: [extensionWindowRecord(
                                populate: true,
                                focusedOverride: (props["focused"] as? NSNumber)?.boolValue ?? true
                               )])
            return ["result": extensionWindowRecord(
                populate: true,
                focusedOverride: (props["focused"] as? NSNumber)?.boolValue ?? true
            )]

        case "windows.update":
            let updateInfo = args["updateInfo"] as? NSDictionary ?? [:]
            let window = extensionHostWindow()
            if (updateInfo["focused"] as? NSNumber)?.boolValue == true {
                NSApp.activate(ignoringOtherApps: true)
                window?.makeKeyAndOrderFront(nil)
                emitExtensionEvent("windows.onFocusChanged", args: [1])
            }
            if let state = updateInfo["state"] as? String {
                if state == "minimized" {
                    window?.miniaturize(nil)
                } else if window?.isMiniaturized == true {
                    window?.deminiaturize(nil)
                }
            }
            return ["result": extensionWindowRecord(
                populate: true,
                focusedOverride: (updateInfo["focused"] as? NSNumber)?.boolValue
            )]

        case "windows.remove":
            // Soul currently owns one persistent browser window. A close
            // request from an extension is acknowledged without terminating the
            // app or destroying the user's only window.
            return ["result": NSNull()]

        default:
            return ["error": "Unsupported windows method: \(method)"]
        }
    }

    func handleExtensionDownloads(method: String, args: NSDictionary) -> NSDictionary {
        if method == "downloads.download" {
            let options = args["options"] as? NSDictionary ?? [:]
            guard let url = options["url"] as? String, !url.isEmpty else {
                return ["error": "downloads.download requires a url."]
            }
            guard let extensionID = args["extensionId"] as? String, !extensionID.isEmpty,
                  let requestID = args["requestId"] as? String, !requestID.isEmpty else {
                return ["error": "Missing extension download request metadata."]
            }
            guard let tab = selectedTab ?? tabs.first else {
                return ["error": "No browser tab can start the download."]
            }
            let filename = options["filename"] as? String
            guard tab.startDownload(url: url,
                                    extensionID: extensionID,
                                    requestID: requestID,
                                    filename: filename) else {
                return ["error": "Chromium browser is not ready to start the download."]
            }
            return ["deferred": true, "result": NSNull()]
        }
        return DownloadStore.shared.handleExtensionDownloads(method: method, args: args)
    }

    func handleExtensionSessions(method: String, args: NSDictionary) -> NSDictionary {
        switch method {
        case "sessions.getRecentlyClosed":
            let filter = args["filter"] as? NSDictionary ?? [:]
            let maxResults = max(0, min(
                (filter["maxResults"] as? NSNumber)?.intValue ?? 25,
                25
            ))
            let result = closedTabSessions
                .reversed()
                .prefix(maxResults)
                .map(extensionSessionRecord)
            return ["result": Array(result)]

        case "sessions.getDevices":
            return ["result": []]

        case "sessions.restore":
            let rawSessionID = args["sessionId"] as? String
            let index: Int?
            if let rawSessionID, !rawSessionID.isEmpty {
                index = closedTabSessions.firstIndex { $0.sessionID == rawSessionID }
            } else {
                index = closedTabSessions.indices.last
            }
            guard let index else {
                return ["error": "No recently closed tab to restore."]
            }
            let session = closedTabSessions.remove(at: index)
            let tab = newTab(url: session.url, select: true)
            emitExtensionEvent("sessions.onChanged", args: [])
            return ["result": ["tab": extensionTabRecord(tab)]]

        default:
            return ["error": "Unsupported sessions method: \(method)"]
        }
    }

    func handleExtensionScripting(method: String, args: NSDictionary) -> NSDictionary {
        let target = args["target"] as? NSDictionary ?? [:]
        let tab = extensionTab(for: target["tabId"]) ?? selectedTab
        guard let tab else { return ["error": "No target tab."] }

        let allFrames = (target["allFrames"] as? NSNumber)?.boolValue ?? false
        switch method {
        case "scripting.executeScript", "scripting.insertCSS", "scripting.removeCSS":
            guard let source = args["source"] as? String, !source.isEmpty else {
                return ["error": "No script source to execute."]
            }
            tab.realize().executeExtensionJavaScript(source, allFrames: allFrames)
            if (args["deferred"] as? NSNumber)?.boolValue == true {
                return ["deferred": true, "result": NSNull()]
            }
            return ["result": [["frameId": 0, "result": NSNull()]]]
        default:
            return ["error": "Unsupported scripting method: \(method)"]
        }
    }

    func activateExtensionAction(extensionID: String) {
        guard !extensionID.isEmpty, let tab = selectedTab else { return }
        if sidePanelOpenOnActionClick[extensionID] == true,
           openExtensionSidePanel(extensionID: extensionID) {
            return
        }
        emitExtensionEvent("action.onClicked",
                           args: [extensionTabRecord(tab)],
                           extensionID: extensionID)
    }

    func activateExtensionCommand(_ command: ExtensionStore.CommandDescriptor) {
        if command.commandName == "_execute_action" {
            if ExtensionStore.shared.requestActionPopup(extensionID: command.extensionID,
                                                        reason: "command") {
                return
            }
            activateExtensionAction(extensionID: command.extensionID)
            return
        }
        emitExtensionEvent("commands.onCommand",
                           args: [command.commandName],
                           extensionID: command.extensionID)
    }

    private func extensionTab(for rawID: Any?) -> BrowserTab? {
        guard let number = rawID as? NSNumber else { return nil }
        let tabID = number.intValue
        return tabs.first { $0.extensionTabID == tabID }
    }

    private func extensionTabIDs(from raw: Any?) -> [Int] {
        if let number = raw as? NSNumber {
            return [number.intValue]
        }
        if let numbers = raw as? [NSNumber] {
            return numbers.map(\.intValue)
        }
        if let array = raw as? NSArray {
            return array.compactMap { ($0 as? NSNumber)?.intValue }
        }
        return []
    }

    private func extensionTabIndices(from raw: Any?) -> [Int] {
        if let number = raw as? NSNumber {
            return [number.intValue]
        }
        if let numbers = raw as? [NSNumber] {
            return numbers.map(\.intValue)
        }
        if let array = raw as? NSArray {
            return array.compactMap { ($0 as? NSNumber)?.intValue }
        }
        return []
    }

    private func extensionTabs(matching queryInfo: NSDictionary) -> [BrowserTab] {
        tabs.compactMap { tab in
            if let active = queryInfo["active"] as? NSNumber,
               active.boolValue != (tab.id == selectedTabID) {
                return nil
            }
            if let currentWindow = queryInfo["currentWindow"] as? NSNumber,
               currentWindow.boolValue == false {
                return nil
            }
            if let urlPatterns = extensionQueryPatterns(queryInfo["url"]),
               !urlPatterns.contains(where: { wildcard($0, matches: tab.urlString) }) {
                return nil
            }
            if let titlePattern = queryInfo["title"] as? String,
               !wildcard(titlePattern, matches: tab.title) {
                return nil
            }
            return tab
        }
    }

    private func extensionQueryPatterns(_ raw: Any?) -> [String]? {
        if let value = raw as? String { return [value] }
        if let values = raw as? [String] { return values }
        return nil
    }

    private func extensionTabRecord(_ tab: BrowserTab) -> NSDictionary {
        let index = tabs.firstIndex { $0.id == tab.id } ?? 0
        let active = tab.id == selectedTabID
        var record: [String: Any] = [
            "id": tab.extensionTabID,
            "index": index,
            "windowId": 1,
            "active": active,
            "highlighted": active,
            "selected": active,
            "pinned": pinnedTabIDs.contains(tab.id),
            "url": tab.urlString,
            "title": tab.title,
            "status": tab.isLoading ? "loading" : "complete"
        ]
        if let favicon = tab.faviconURL { record["favIconUrl"] = favicon }
        return record as NSDictionary
    }

    private func extensionSessionRecord(_ session: ClosedTabSession) -> NSDictionary {
        [
            "lastModified": session.closedAt.timeIntervalSince1970,
            "tab": [
                "sessionId": session.sessionID,
                "windowId": 1,
                "index": 0,
                "url": session.url,
                "title": session.title,
                "active": false,
                "highlighted": false,
                "selected": false,
                "pinned": false,
                "status": "complete",
                "incognito": false
            ]
        ]
    }

    private func extensionWindowRecord(populate: Bool,
                                       focusedOverride: Bool? = nil) -> NSDictionary {
        let window = extensionHostWindow()
        let frame = window?.frame ?? .zero
        let state: String
        if window?.isMiniaturized == true {
            state = "minimized"
        } else if window?.styleMask.contains(.fullScreen) == true {
            state = "fullscreen"
        } else {
            state = "normal"
        }

        var record: [String: Any] = [
            "id": 1,
            "focused": focusedOverride ?? (window?.isKeyWindow ?? true),
            "top": Int(frame.origin.y.rounded()),
            "left": Int(frame.origin.x.rounded()),
            "width": Int(frame.size.width.rounded()),
            "height": Int(frame.size.height.rounded()),
            "incognito": false,
            "type": "normal",
            "state": state,
            "alwaysOnTop": window?.level.rawValue ?? 0 > NSWindow.Level.normal.rawValue
        ]
        if populate {
            record["tabs"] = tabs.map(extensionTabRecord)
        }
        return record as NSDictionary
    }

    private func extensionHostWindow() -> NSWindow? {
        NSApp.mainWindow
            ?? NSApp.keyWindow
            ?? NSApp.windows.first {
                $0.isVisible && !$0.isMiniaturized && $0.frame.width > 0 && $0.frame.height > 0
            }
            ?? NSApp.windows.first {
                $0.frame.width > 0 && $0.frame.height > 0
            }
    }

    private func extensionWindowCreateURLs(_ raw: Any?) -> [String] {
        if let value = raw as? String, !value.isEmpty { return [value] }
        if let values = raw as? [String] { return values.filter { !$0.isEmpty } }
        if let values = raw as? NSArray {
            return values.compactMap { $0 as? String }.filter { !$0.isEmpty }
        }
        return []
    }

    private func emitExtensionTabUpdated(_ tab: BrowserTab, changeInfo: [String: Any]) {
        guard tabs.contains(where: { $0.id == tab.id }) else { return }
        emitExtensionEvent("tabs.onUpdated", args: [
            tab.extensionTabID,
            changeInfo,
            extensionTabRecord(tab)
        ])
    }

    private func completeIdentityFlowIfNeeded(tab: BrowserTab, url: String) {
        guard let flow = pendingIdentityFlows[tab.id],
              url == flow.redirectBase || url.hasPrefix(flow.redirectBase) || url.hasPrefix(flow.redirectOrigin)
        else { return }
        pendingIdentityFlows.removeValue(forKey: tab.id)
        let tabID = tab.id
        DispatchQueue.main.async { [weak self] in
            SoulBrowserView.dispatchExtensionBridgeResponse([
                "requestId": flow.requestID,
                "extensionId": flow.extensionID,
                "result": url
            ])
            self?.closeTab(tabID, allowPinned: true)
        }
    }

    private func emitExtensionTabMoveEvents(before: [BrowserTab],
                                            movedIDs: Set<BrowserTab.ID>) {
        guard !movedIDs.isEmpty else { return }
        let beforeIndices = Dictionary(uniqueKeysWithValues: before.enumerated().map {
            ($0.element.id, $0.offset)
        })
        for tab in tabs where movedIDs.contains(tab.id) {
            guard let fromIndex = beforeIndices[tab.id],
                  let toIndex = tabs.firstIndex(where: { $0.id == tab.id }),
                  fromIndex != toIndex
            else { continue }
            emitExtensionEvent("tabs.onMoved", args: [
                tab.extensionTabID,
                [
                    "windowId": 1,
                    "fromIndex": fromIndex,
                    "toIndex": toIndex
                ]
            ])
        }
    }

    private func emitExtensionWebNavigation(_ name: String,
                                            tab: BrowserTab,
                                            details rawDetails: [String: Any]) {
        guard tabs.contains(where: { $0.id == tab.id }) else { return }
        var details = rawDetails
        details["tabId"] = tab.extensionTabID
        details["timeStamp"] = Date().timeIntervalSince1970 * 1000
        emitExtensionEvent(name, args: [details])
    }

    private func emitExtensionEvent(_ name: String,
                                    args: [Any],
                                    extensionID: String? = nil) {
        SoulBrowserView.dispatchExtensionEvent(name, args: args, forExtensionID: extensionID)
    }

    private func wildcard(_ pattern: String, matches value: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: pattern)
            .replacingOccurrences(of: "\\*", with: ".*")
        return value.range(of: "^\(escaped)$", options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func jsonLiteral(_ value: Any) -> String {
        let object: Any
        if value is NSNull || JSONSerialization.isValidJSONObject([value]) {
            object = [value]
        } else {
            object = [String(describing: value)]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let array = String(data: data, encoding: .utf8),
              array.count >= 2
        else { return "null" }
        return String(array.dropFirst().dropLast())
    }

    /// Send the active tab to the configured homepage.
    func goHome() {
        selectedTab?.load(settings.homepageURL)
    }

    func toggleSidebar() {
        withAnimation(Motion.snappy) { sidebarVisible.toggle() }
    }

    func toggleAIPanel() {
        withAnimation(Motion.reveal) { aiPanelVisible.toggle() }
    }

    func toggleFocusMode() {
        withAnimation(Motion.snappy) { isFocusMode.toggle() }
    }

    static func notesDirectory() -> URL {
        let dir = supportDirectory().appendingPathComponent("notes", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func scanNotes() {
        let dir = BrowserStore.notesDirectory()
        if let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            let names = urls.filter { $0.pathExtension == "md" }.map { $0.deletingPathExtension().lastPathComponent }
            availableNotes = names.isEmpty ? ["Default"] : names.sorted()
        } else {
            availableNotes = ["Default"]
        }
    }

    func loadNotes() {
        scanNotes()
        if !availableNotes.contains(activeNoteName) {
            activeNoteName = availableNotes.first ?? "Default"
        }
        let url = BrowserStore.notesDirectory().appendingPathComponent("\(activeNoteName).md")
        if let content = try? String(contentsOf: url, encoding: .utf8) {
            self.notesContent = content
        } else {
            self.notesContent = ""
        }
    }

    func saveNotes() {
        let content = self.notesContent
        let name = self.activeNoteName
        let url = BrowserStore.notesDirectory().appendingPathComponent("\(name).md")
        DispatchQueue.global(qos: .background).async {
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    func toggleNotesPanel() {
        withAnimation(Motion.reveal) {
            notesPanelVisible.toggle()
        }
    }

    func toggleRSSReaderPanel() {
        withAnimation(Motion.reveal) {
            rssReaderVisible.toggle()
        }
    }

    func switchToNote(_ name: String) {
        // Save current first
        let currentUrl = BrowserStore.notesDirectory().appendingPathComponent("\(activeNoteName).md")
        try? notesContent.write(to: currentUrl, atomically: true, encoding: .utf8)
        
        activeNoteName = name
        let url = BrowserStore.notesDirectory().appendingPathComponent("\(name).md")
        if let content = try? String(contentsOf: url, encoding: .utf8) {
            notesContent = content
        } else {
            notesContent = ""
        }
    }
    
    func createNewNote(name: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        // Save current first
        let currentUrl = BrowserStore.notesDirectory().appendingPathComponent("\(activeNoteName).md")
        try? notesContent.write(to: currentUrl, atomically: true, encoding: .utf8)
        
        let newUrl = BrowserStore.notesDirectory().appendingPathComponent("\(cleanName).md")
        try? "".write(to: newUrl, atomically: true, encoding: .utf8)
        
        activeNoteName = cleanName
        notesContent = ""
        scanNotes()
    }
    
    func deleteNote(_ name: String) {
        let url = BrowserStore.notesDirectory().appendingPathComponent("\(name).md")
        try? FileManager.default.removeItem(at: url)
        scanNotes()
        if activeNoteName == name || !availableNotes.contains(activeNoteName) {
            switchToNote(availableNotes.first ?? "Default")
        }
    }

    @discardableResult
    func openExtensionSidePanel(extensionID: String) -> Bool {
        guard let url = sidePanelURL(forExtensionID: extensionID) else { return false }
        let title = ExtensionStore.shared.extensions.first { $0.id == extensionID }?.name ?? "Extension"
        withAnimation(Motion.reveal) {
            extensionSidePanelURL = url
            extensionSidePanelTitle = title
        }
        return true
    }

    func closeExtensionSidePanel() {
        withAnimation(Motion.reveal) {
            extensionSidePanelURL = nil
            extensionSidePanelTitle = nil
        }
    }

    private func sidePanelURL(forExtensionID extensionID: String) -> String? {
        let options = sidePanelOptions[extensionID] ?? ExtensionSidePanelOptions()
        guard options.enabled else { return nil }
        if let path = options.path, !path.isEmpty {
            if path.contains("://") { return path }
            return ExtensionStore.shared.extensionResourceURL(forExtensionID: extensionID, path: path)
        }
        return ExtensionStore.shared.sidePanelURL(forExtensionID: extensionID)
    }

    func toggleSettings() {
        settingsVisible.toggle()
    }

    func prepareForTermination() {
        // Make sure the cookie jar is written before we tear CEF down, so
        // sessions reliably survive the quit.
        saveSession()
        SoulPrivacy.flushCookies()
        for tab in tabs { tab.close() }
    }

    /// Clear browsing data: history (and optionally cookies / cache). Cookies and
    /// cache go through the native CEF global stores.
    func clearBrowsingData(history: Bool = true,
                           cookies: Bool = true,
                           cache: Bool = true,
                           downloads: Bool = false) {
        if history { HistoryStore.shared.clear() }
        if cookies { SoulPrivacy.clearCookies() }
        if cache { SoulPrivacy.clearCache() }
        if downloads { DownloadStore.shared.clearAllRecords() }
    }

    func handleExtensionBrowsingData(method: String, args: NSDictionary) -> NSDictionary {
        let dataToRemove = args["dataToRemove"] as? NSDictionary ?? [:]

        func wants(_ key: String) -> Bool {
            (dataToRemove[key] as? NSNumber)?.boolValue ?? false
        }

        let history: Bool
        let cookies: Bool
        let cache: Bool
        let downloads: Bool

        switch method {
        case "browsingData.remove":
            history = wants("history")
            cookies = wants("cookies")
            cache = wants("cache")
            downloads = wants("downloads")
        case "browsingData.removeHistory":
            history = true
            cookies = false
            cache = false
            downloads = false
        case "browsingData.removeCookies":
            history = false
            cookies = true
            cache = false
            downloads = false
        case "browsingData.removeCache":
            history = false
            cookies = false
            cache = true
            downloads = false
        case "browsingData.removeDownloads":
            history = false
            cookies = false
            cache = false
            downloads = true
        case "browsingData.removeFormData",
             "browsingData.removeLocalStorage",
             "browsingData.removePasswords",
             "browsingData.removePluginData":
            return ["result": NSNull()]
        default:
            return ["error": "Unsupported browsingData method: \(method)"]
        }

        clearBrowsingData(history: history, cookies: cookies, cache: cache, downloads: downloads)
        return ["result": NSNull()]
    }

    // MARK: - Pinned tabs & folders

    private func tab(for id: BrowserTab.ID) -> BrowserTab? {
        tabs.first { $0.id == id }
    }

    /// Tabs in the pinned grid (stale ids are skipped).
    var pinnedTabs: [BrowserTab] {
        pinnedTabIDs.compactMap { tab(for: $0) }
    }

    private var folderedIDs: Set<BrowserTab.ID> {
        Set(folders.flatMap { $0.tabIDs })
    }

    /// Open tabs that are neither pinned nor inside a folder.
    var looseTabs: [BrowserTab] {
        tabs.filter { !pinnedTabIDs.contains($0.id) && !folderedIDs.contains($0.id) }
    }

    func tabs(in folder: TabFolder) -> [BrowserTab] {
        folder.tabIDs.compactMap { tab(for: $0) }
    }

    func isPinned(_ id: BrowserTab.ID) -> Bool { pinnedTabIDs.contains(id) }

    func togglePin(_ id: BrowserTab.ID) {
        withAnimation(Motion.snappy) {
            if pinnedTabIDs.contains(id) {
                pinnedTabIDs.removeAll { $0 == id }
            } else {
                detachFromFolders(id)
                pinnedTabIDs.append(id)
            }
            scheduleSessionSave()
        }
    }

    // MARK: Folder management

    @discardableResult
    func addFolder(name: String = "New Folder", parentFolderID: UUID? = nil) -> TabFolder {
        let folder = TabFolder(name: name, isExpanded: true, parentFolderID: parentFolderID)
        withAnimation(Motion.snappy) { folders.append(folder) }
        scheduleSessionSave()
        return folder
    }

    @discardableResult
    func addFolderForEditing(name: String = "New Folder", parentFolderID: UUID? = nil) -> TabFolder {
        let folder = addFolder(name: name, parentFolderID: parentFolderID)
        folderIDPendingRename = folder.id
        return folder
    }

    func consumeFolderRenameRequest(for folderID: TabFolder.ID) {
        guard folderIDPendingRename == folderID else { return }
        folderIDPendingRename = nil
    }

    func toggleFolder(_ folderID: TabFolder.ID) {
        guard let idx = folders.firstIndex(where: { $0.id == folderID }) else { return }
        withAnimation(Motion.snappy) { folders[idx].isExpanded.toggle() }
        scheduleSessionSave()
    }

    func renameFolder(_ folderID: TabFolder.ID, to name: String) {
        guard let idx = folders.firstIndex(where: { $0.id == folderID }) else { return }
        folders[idx].name = name
        scheduleSessionSave()
    }

    func moveFolder(_ folderID: TabFolder.ID, toParent parentID: TabFolder.ID?) {
        guard folderID != parentID else { return }
        guard let idx = folders.firstIndex(where: { $0.id == folderID }) else { return }
        
        var p = parentID
        while let currentParent = p {
            if currentParent == folderID {
                return
            }
            p = folders.first(where: { $0.id == currentParent })?.parentFolderID
        }
        
        withAnimation(Motion.snappy) {
            folders[idx].parentFolderID = parentID
        }
        scheduleSessionSave()
    }

    /// Delete a folder; its tabs fall back into the parent folder or the loose list.
    func deleteFolder(_ folderID: TabFolder.ID) {
        guard let idx = folders.firstIndex(where: { $0.id == folderID }) else { return }
        let parentID = folders[idx].parentFolderID
        let tabsToMove = folders[idx].tabIDs
        
        withAnimation(Motion.snappy) {
            for i in 0..<folders.count {
                if folders[i].parentFolderID == folderID {
                    folders[i].parentFolderID = parentID
                }
            }
            
            if let parentID = parentID, let parentIdx = folders.firstIndex(where: { $0.id == parentID }) {
                folders[parentIdx].tabIDs.append(contentsOf: tabsToMove)
            }
            
            folders.removeAll { $0.id == folderID }
        }
        scheduleSessionSave()
    }

    /// Move a tab into a folder, removing it from any other folder / the pins.
    func addTab(_ tabID: BrowserTab.ID, toFolder folderID: TabFolder.ID) {
        guard let idx = folders.firstIndex(where: { $0.id == folderID }) else { return }
        withAnimation(Motion.snappy) {
            detachFromFolders(tabID)
            pinnedTabIDs.removeAll { $0 == tabID }
            folders[idx].tabIDs.append(tabID)
            folders[idx].isExpanded = true
        }
        scheduleSessionSave()
    }

    func removeTabFromFolders(_ tabID: BrowserTab.ID) {
        withAnimation(Motion.snappy) { detachFromFolders(tabID) }
        scheduleSessionSave()
    }

    private func detachFromFolders(_ tabID: BrowserTab.ID) {
        for i in folders.indices {
            folders[i].tabIDs.removeAll { $0 == tabID }
        }
    }
}

/// Normalizes URLs that must stay inside Soul before a tab is ever created.
enum SoulURLRewriter {
    static func rewrite(_ raw: String) -> String {
        guard var components = URLComponents(string: raw),
              components.scheme?.lowercased() ==
                ["chrome", "extension"].joined(separator: "-")
        else {
            return raw
        }
        components.scheme = "soul-extension"
        return components.string ?? raw
    }
}

/// Turns omnibox input into a navigable URL or a search, honoring the user's
/// configured homepage and default search engine.
enum URLInterpreter {
    static func resolveBang(_ text: String) -> String? {
        return BangsStore.shared.resolve(text)
    }

    static func resolve(_ raw: String, settings: BrowserSettings) -> String {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return settings.homepageURL }

        // Already has a scheme.
        if let url = URL(string: text), let scheme = url.scheme,
           scheme == "http" || scheme == "https" || scheme == "file" ||
            scheme == "about" || scheme == "soul" || scheme == "soul-extension" ||
            scheme == ["chrome", "extension"].joined(separator: "-") {
            return text
        }

        // Check for local !bangs shortcut
        if let bangURL = resolveBang(text) {
            return bangURL
        }

        // Looks like a domain (has a dot, no spaces) → treat as URL.
        let looksLikeDomain = text.contains(".") && !text.contains(" ")
        if looksLikeDomain {
            return "https://\(text)"
        }

        // Otherwise search with the configured engine.
        return settings.searchURL(for: text)
    }
}
