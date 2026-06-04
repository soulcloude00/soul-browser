# Soul Browser — Master Implementation Audit

## Last Updated: June 2025
## Scope: All 106 roadmap items + core browser functionality
## Method: Code inspection of model depth, CEF wiring, and UI completeness

---

## Legend

| Grade | Meaning |
|-------|---------|
| **A** | Production-ready. Fully implemented, wired, tested. |
| **B** | Functional. Core logic works, minor gaps remain. |
| **C** | Partial. Skeleton exists, significant wiring/UI missing. |
| **D** | Stub. File created, mostly TODO comments / placeholder logic. |
| **F** | Not Started. Listed in roadmap, no code exists. |
| **N/A** | Already existed / merged into another feature. |

---

## Part 1: Core Browser Engine (The Foundation)

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 1 | **CEF Integration** | B | CEF loads, renders, navigates. Helper processes spawn correctly. Some GPU crashes on certain sites. |
| 2 | **Message Loop Pump** | B | 30Hz NSTimer on NSRunLoopCommonModes. Stable. CEF processes events cooperatively. |
| 3 | **Tab Lifecycle** | B | Create, close, select, reload, back/forward all work. Lazy realization of CEF views is efficient. |
| 4 | **Session Autosave** | C | Writes `session.json` on quit. Loads on startup. **Missing**: periodic autosave during browsing, crash recovery UI. |
| 5 | **Crash Recovery** | C | `SmartSessionResumption` detects crashes via UserDefaults flags. **Missing**: actual "restore session?" dialog on launch. |
| 6 | **Omnibox / Navigation** | B | URL entry, search, bangs all work. History suggestions query SQLite in real-time. |
| 7 | **Find in Page** | B | ⌘F bar, find next/previous, match count. Works via CEF `find()` API. |
| 8 | **Zoom** | B | ⌘= / ⌘- / ⌘0. CEF zoom level synced to SwiftUI percent display. |
| 9 | **Page Load States** | B | `isLoading` flag, progress bar, error state (`didFail`). |
| 10 | **Downloads** | B | CEF download callback → Swift DownloadStore with progress, speed, completion. |
| 11 | **Print** | C | Menu item wired. **Missing**: actual print dialog implementation. |
| 12 | **PDF Handling** | D | Renders PDFs in CEF. **Missing**: native macOS PDF viewer integration, annotation, save. |

---

## Part 2: Data Persistence (The "Never Lose My Stuff" Layer)

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 13 | **History (SQLite)** | A | Full SQLite with FTS, 500-entry limit per query, suggestions, search. `HistoryAPI` exposed to JS. |
| 14 | **Bookmarks (JSON)** | A | CRUD, folders, pinning, toolbar visibility. Persists to Application Support. Extension API (`bookmarks.getTree`). |
| 15 | **Session State** | B | `session.json` with tabs, selection, workspaces. **Missing**: scroll position, form data, tree state. |
| 16 | **Notes / Scratchpad** | B | Per-tab notes, persisted to disk. **Missing**: rich text, markdown, sync. |
| 17 | **Settings** | A | `BrowserSettings` Codable, persisted to UserDefaults. All toggles survive relaunch. |
| 18 | **Extension Catalog** | A | JSON persistence, enabled states, icons, manifest parsing. Robust migration between versions. |
| 19 | **Keychain Storage** | C | `SoulKeychain` wrapper around `SecItemAdd`/`SecItemCopyMatching`. **Missing**: actual credential saving on form submit. |
| 20 | **User Scripts** | B | `UserScriptStore` parses `@match`, `@run-at`, injects via `executeJavaScript`. **Missing**: GM_* API emulation. |

---

## Part 3: UI / UX Chrome (What Users See and Click)

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 21 | **Sidebar** | B | Vertical tabs, pinned grid, folders, drag-and-drop, media player, bottom bar. **Missing**: workspace switcher UI, folder icons. |
| 22 | **Omnibox** | B | URL display, edit mode, secure icon, suggestion dropdown, extension buttons. **Missing**: favicon in field, inline autocomplete. |
| 23 | **Toolbar** | B | Navigation buttons, reader mode toggle, bookmark star, download button. **Missing**: proper toolbar customization. |
| 24 | **Top Chrome / Titlebar** | B | Hover-to-reveal traffic lights, card offset animation. **Fixed**: was full-window overlay stealing clicks. |
| 25 | **Command Palette (⌘T)** | A | Spotlight-style search, history, bookmarks, open tabs, actions. Beautiful card UI. Keyboard navigation. |
| 26 | **Extension Manager Overlay** | B | Search, enable/disable, import, uninstall. **Missing**: actual Chrome Web Store browsing, auto-update. |
| 27 | **Settings Panel** | B | 9 tabs, organized sections, keyboard shortcuts editor. **Missing**: some advanced CEF flags, proxy settings. |
| 28 | **Theme / Appearance** | B | Light/dark/auto, gradients, OKLCH engine, glass effects. **Missing**: custom CSS injection, user themes. |
| 29 | **Context Menus** | C | Sidebar context menu exists. **Missing**: web page right-click menu (copy link, inspect, save image). |
| 30 | **Notifications / Toast** | D | No unified toast/notification system. Errors logged to console only. |
| 31 | **Status Bar** | B | URL preview, security status, localhost scanner indicator. |
| 32 | **Find Bar** | B | Inline find bar with match count, up/down navigation. |
| 33 | **AI Panel** | C | Slide-out panel exists. **Missing**: actual chat UI, message history, streaming responses. |
| 34 | **Mini Console** | C | Sidebar console log streamer. **Missing**: filtering by level, JS execution, object expansion. |

---

## Part 4: Privacy & Security (The "Brave Killer" Layer)

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 35 | **Ad/Tracker Blocking** | C | `DeclarativeBlocklistEngine` parses EasyList. **CRITICAL MISSING**: Not wired to CEF `OnBeforeResourceLoad`. Blocklist is loaded but never consulted during navigation. |
| 36 | **Privacy Dashboard** | B | Beautiful UI showing blocked tracker count, per-domain list, toggle shield. **Missing**: actual real-time updates from blocked requests. |
| 37 | **HTTPS-Only Mode** | C | `HTTPSUpgrader` has redirect logic. **Missing**: Not wired to CEF `OnBeforeBrowse`. Never actually upgrades HTTP to HTTPS. |
| 38 | **Fingerprinting Protection** | C | Canvas/WebGL spoof scripts written. **Missing**: Not injected into page contexts. |
| 39 | **Anti-Phishing** | C | URL heuristic scanner (regex patterns). **Missing**: Not wired to page load pipeline. No visual warning UI. |
| 40 | **Tor Proxy** | C | SOCKS5 configuration logic exists. **Missing**: No UI to toggle, no proxy routing through CEF. |
| 41 | **Permission Controls** | C | Model for site permissions. **Missing**: No permission prompt UI, no per-site settings panel. |
| 42 | **Private Session Mode** | D | `PrivateSessionManager` exists. **Missing**: No ephemeral CEF context, no visual indicator, no auto-destruct timer. |
| 43 | **Media Capture Spoofing** | D | Device enumeration spoof script. **Missing**: Not injected, no UI panel. |
| 44 | **Sandbox Isolated Extensions** | D | `ExtensionSandbox` has restricted API wrapper. **Missing**: No actual process isolation, content scripts run in main context. |
| 45 | **Cookie Protection** | C | `CookieLocalStorageEditor` has scanning logic. **Missing**: No UI, no actual cookie manipulation via CEF API. |
| 46 | **SSL Certificate Manager** | D | `SSLCertificateManager` has parsing helpers. **Missing**: No UI, no cert pinning, no warning dialogs. |

**Privacy Verdict**: The *models* for privacy are extensive (best-in-class on paper). The *wiring* to CEF is almost entirely missing. Soul currently does NOT block ads, NOT upgrade HTTPS, NOT spoof fingerprints. This is the single highest-priority fix area.

---

## Part 5: AI & Local Intelligence (The 2025 Differentiator)

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 47 | **LLM Configurator** | B | Scans Ollama (port 11434) and LM Studio (port 1234). Lists models. Detects online/offline. |
| 48 | **Reader Mode AI Summary** | C | Calls `/api/generate` on Ollama. **Missing**: No UI to trigger it, no streaming, no error handling for large HTML. |
| 49 | **AI Tab Grouping** | B | Heuristic clustering by domain/title keyword. Returns group suggestions. **Missing**: No UI to apply suggestions. |
| 50 | **AI Form Filler** | C | Profile model, JS injection logic. **Missing**: No UI to manage profile, not wired to detect forms automatically. |
| 51 | **AI Ad Blocker Optimizer** | C | Keyword-based DOM analysis (cookie banners, ads). **Missing**: Not wired to actual page content, no auto-hide injection. |
| 52 | **Smart Rewrite Tool** | C | Sends selected text to LLM. **Missing**: No text selection detection, no inline rewrite UI. |
| 53 | **Clipboard Context Injector** | D | Copies clipboard to prompt. **Missing**: No UI, no paste detection, no LLM call. |
| 54 | **Voice Transcription** | C | CoreAudio recording works on macOS. **Missing**: No Whisper integration, no speech-to-text output, no UI. |
| 55 | **Offline Translation** | D | Bergamot-style stub. **Missing**: No actual translation model, no UI. |
| 56 | **Developer Helper Panel** | D | Console error collection exists. **Missing**: No AI analysis loop, no fix suggestions UI. |
| 57 | **AI Chat Panel** | D | Slide-out panel exists. **Missing**: No chat UI, no message history, no streaming, no tool calling. |

**AI Verdict**: Local LLM *discovery* works. LLM *calling* works for basic summarization. The *UI integration* is almost entirely missing. Users cannot actually chat with AI, summarize pages, or get writing assistance from the browser chrome.

---

## Part 6: Extensions & Ecosystem (The "Chrome Compatibility" Layer)

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 58 | **Extension Catalog** | B | Parse manifest.json, extract metadata, persist catalog. Import from folder. |
| 59 | **Extension Enable/Disable** | A | Toggle on/off, persist state. Takes effect on next page load. |
| 60 | **Content Script Injection** | C | `@match` parsing, `@run-at` support. **Missing**: No DOM mutation observer re-injection, no `window.postMessage` bridge fully wired. |
| 61 | **Chrome Web Store Install** | C | "Install in Soul" button injected on CWS pages. **Missing**: No actual download/extract/install flow. |
| 62 | **Extension Popup Pages** | D | `popupPage` field parsed from manifest. **Missing**: No popup window rendering, no click handler. |
| 63 | **Extension Options Pages** | D | `optionsPage` field parsed. **Missing**: No options UI rendering. |
| 64 | **Extension Icons in Toolbar** | B | Pinned extensions show icons in omnibox. Clickable. |
| 65 | **Extension Message Passing** | C | `ExtensionMessagePipeline` with port abstraction. **Missing**: Not wired to CEF `V8Context`, JS side incomplete. |
| 66 | **Extension Storage API** | D | `chrome.storage.local` stub. **Missing**: No actual key-value persistence for extensions. |
| 67 | **Extension Bookmarks API** | B | `bookmarks.getTree`, `bookmarks.getChildren` wired to BookmarkStore. |
| 68 | **DeclarativeNetRequest** | D | Rule parser stub. **Missing**: No rule application to CEF request pipeline. |
| 69 | **Extension Backup / Import** | C | Export to `.soul-ext` manifest. **Missing**: ZIP packaging (removed due to dependency), actual restore flow. |
| 70 | **Extension Permissions** | D | `ExtensionPermissionSystem` model. **Missing**: No permission prompt UI, no granular toggles. |
| 71 | **Extension Resource Throttle** | D | Model exists. **Missing**: No throttling implementation. |
| 72 | **Soul Extension API** | D | Custom API surface defined. **Missing**: No documentation, no sample extensions. |

**Extension Verdict**: Catalog management is solid. Content script injection has the basics. The *runtime* (popups, storage, messaging, options) is largely unimplemented. Users cannot meaningfully use Chrome extensions yet.

---

## Part 7: Developer & Power User Tools

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 73 | **HTTP Inspector** | C | Model with request/response entries, filtering. **Missing**: Not wired to CEF `CefRequestHandler`. No actual network interception. |
| 74 | **Terminal Sidebar** | D | `TerminalSidebar` PTY wrapper stub. **Missing**: No real terminal UI, no shell process spawning. |
| 75 | **Color Picker** | C | `NSColorPanel` wrapper. **Missing**: No eyedropper from web page, no CSS export. |
| 76 | **Page Speed Telemetry** | B | Reads Navigation Timing API via JS injection. Returns metrics object. |
| 77 | **Web Asset Downloader** | C | Scans page for media URLs. **Missing**: No actual download action, no batch download UI. |
| 78 | **JSON/XML Formatter** | C | Tree formatter logic. **Missing**: Not auto-applied to API responses, no UI panel. |
| 79 | **Responsive Layout Canvas** | D | Multi-viewport preview View. **Missing**: Not accessible from UI, renders dummy BrowserStore tabs. |
| 80 | **Mini Console** | B | Streams console logs from `consoleMessage` CEF callback. Filterable list view. |
| 81 | **Localhost Scanner** | B | `lsof` parser, shows discovered services in status bar. |
| 82 | **Cookie/LocalStorage Editor** | C | Model for cookie scanning. **Missing**: No UI, no CEF cookie API calls. |
| 83 | **SSL Certificate Viewer** | D | Parsing helpers. **Missing**: No UI, no cert extraction from CEF. |
| 84 | **Browser Automation (Codex)** | C | `soul_browser_action` JS bridge, click/type/navigate/scroll. **Missing**: No tool-calling loop, no LLM agent integration. |

---

## Part 8: Session, Workspaces & Organization

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 85 | **Workspaces** | B | Multiple spaces, per-space tabs, space switcher in sidebar. **Missing**: visual workspace switcher UI, space icons. |
| 86 | **Pinned Tabs** | B | Grid of pinned tabs in sidebar. Drag to pin/unpin. Persistent. |
| 87 | **Tab Folders** | B | Create, rename, collapse, drag tabs into folders. |
| 88 | **Tab Tree (Parent/Child)** | C | Data model (`parentTabID`, `isCollapsed`). **Missing**: No visual tree indentation in sidebar. |
| 89 | **Tab Search (⌘⇧P)** | C | `TabSearchConsole` model. **Missing**: Not wired to keyboard shortcut, no search UI. |
| 90 | **Tab Preview / Hover Cards** | D | `TabPreviewCards` stub. **Missing**: No thumbnail capture, no hover overlay. |
| 91 | **Tab Suspender** | C | Timer checks inactivity. **Missing**: Timer doesn't call `checkTabs()`, suspend uses `setWebWindowVisible(false)` which may not free memory. |
| 92 | **Session Resumption** | C | Crash detection, backup to UserDefaults. **Missing**: Restore dialog on launch, scroll position recovery. |
| 93 | **LAN Sync** | C | Bonjour discovery (`NWListener`/`NWBrowser`). **Missing**: No sync protocol, no data exchange. |
| 94 | **Multi-Window** | C | `WindowCoordinator` model. **Missing**: No "New Window" menu item, no drag-tab-to-new-window. |
| 95 | **Focus Mode** | B | Hides all chrome, shows only page. Toggle from sidebar. |
| 96 | **Reader Mode** | C | `isReaderMode` flag, basic JS extraction. **Missing**: Poor extraction quality vs Safari/Chrome, no typography controls wired. |

---

## Part 9: Media, Content & Productivity

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 97 | **Picture-in-Picture** | C | `PiPWindowStyler` exists. **Missing**: No video detection, no PiP button, relies on CEF default. |
| 98 | **Media Controls** | B | Sidebar media player with play/pause, skip, mute. Driven by injected JS agent. |
| 99 | **Workspace Audio Mixer** | C | Per-tab volume model. **Missing**: Not wired to CEF audio, no volume sliders in UI. |
| 100 | **Screen Capture** | C | Window capture via `bitmapImageRepForCachingDisplay`. **Missing**: Full-page capture stub, no CEF DevTools capture. |
| 101 | **Stream Downloader** | D | `StreamDownloader` stub. **Missing**: No HLS/DASH parsing, no actual download logic. |
| 102 | **Annotation / Highlighting** | D | `AnnotationHighlighter` stub. **Missing**: No JS injection for highlighting, no persistence. |
| 103 | **Offline Web Archiver** | C | `OfflineWebArchiver` with MHTML intent. **Missing**: No actual MHTML generation, no archive library. |
| 104 | **Web App Wrapper (SSB)** | D | `WebAppWrapper` stub. **Missing**: No .app bundle creation, no icon generation, no standalone window. |
| 105 | **Local File Server** | C | `LocalFileServer` with `GCDWebServer` comments. **Missing**: No actual server implementation, no directory browsing UI. |
| 106 | **RSS / Podcast Reader** | C | `PodcastRSSReader` parses RSS. **Missing**: No UI for feed management, no article list, no audio player. |
| 107 | **App Icon Creator** | D | Stub. **Missing**: No icon generation, no export. |
| 108 | **Onboarding Tour** | D | `OnboardingTour` model with steps. **Missing**: No actual onboarding UI flow, no highlighting. |
| 109 | **Search Engine Wizard** | C | Custom search engine support in settings. **Missing**: No discovery wizard, no favicon fetching. |
| 110 | **Default Browser Prompt** | C | `DefaultBrowserPrompt` calls `LSSetDefaultHandlerForURLScheme`. **Missing**: No post-prompt confirmation UI. |
| 111 | **Credentials Migration** | D | `CredentialsMigrationScanner` stub. **Missing**: No Safari keychain reading, no Chrome password DB parsing. |
| 112 | **Extension Sync Bridge** | D | `ExtensionSyncBridge` stub. **Missing**: No sync protocol. |
| 113 | **Focus Tracker / Productivity** | D | `FocusTracker` stub. **Missing**: No time tracking, no dashboard. |
| 114 | **Arc Workspace Import** | C | Detects Arc's `StorableSpaces.json`. **Missing**: No actual workspace creation from import. |
| 115 | **Chrome/Safari Import** | C | History/cookie parsing stubs. **Missing**: No actual data migration UI or flow. |

---

## Part 10: Performance & System Integration

| # | Feature | Grade | Notes |
|---|---------|-------|-------|
| 116 | **Apple Silicon / Metal** | C | `MetalRenderHandler` exists with CAMetalLayer. **Missing**: Not actually used as CEF's rendering path. CEF still uses software/IOSurface. |
| 117 | **Liquid Glass** | B | `.liquidGlass()` modifier with fallback. Applied to cards and inputs. Looks good on macOS 26+. |
| 118 | **Memory Visualizer** | C | `task_info` for browser process. **Missing**: Renderer/GPU helper memory not tracked, no visual graph UI. |
| 119 | **Battery Throttling** | C | `IOKit` power source observer. **Missing**: No actual CEF throttling implementation (frame rate, worker suspension). |
| 120 | **Process Priority** | D | `ProcessPriorityRebalancer` stub. **Missing**: No QoS adjustments, no background deprioritization. |
| 121 | **V8 Context Allocator** | D | Command-line flags defined. **Missing**: Not passed to CEF on launch. |
| 122 | **Resource Preloader** | D | HEAD preflight logic. **Missing**: Not wired to CEF request pipeline. |
| 123 | **Video Decode Accelerator** | D | VideoToolbox flags. **Missing**: Not passed to CEF. |
| 124 | **WebGL Capture** | D | IOSurface bridge stub. **Missing**: No actual capture path. |
| 125 | **Parallel Renderer Boot** | D | Prewarm logic. **Missing**: No prewarming implementation. |
| 126 | **GC Sweeper** | C | Idle `window.gc()` dispatch. **Missing**: Not wired to actual idle detection, timer just logs. |
| 127 | **Core Spotlight** | C | `CSSearchableIndex` indexing. **Missing**: Not populated with real browsing data, no searchable items created. |
| 128 | **Share Sheet** | B | `NSSharingServicePicker` wrapper. Works for URLs. |
| 129 | **Keychain** | C | `SecItemAdd`/`SecItemCopyMatching` wrapper. **Missing**: No actual form password save flow. |
| 130 | **Haptics** | C | `NSHapticFeedbackManager` wrapper. **Missing**: macOS desktop haptics are limited; mostly no-op. |
| 131 | **Drag & Drop (AppKit)** | C | `NSDraggingDestination` wrapper. **Missing**: No actual file drop to upload, no image drag-out. |
| 132 | **Low Power Mode** | C | `powerStateDidChangeNotification` observer. **Missing**: No CEF-side throttling applied. |

---

## Critical Path: What Will Make or Break Soul

### P0 — Fix Before Any User Testing (Ship-Blockers)

| # | Issue | Why Critical |
|---|-------|--------------|
| 1 | **Ad/Tracker Blocking Not Wired** | `DeclarativeBlocklistEngine` is loaded but `shouldBlock()` is never called by CEF. Every page loads trackers. Privacy promise is broken. |
| 2 | **HTTPS Upgrader Not Wired** | `HTTPSUpgrader` logic exists but no CEF `OnBeforeBrowse` hook calls it. HTTP sites stay HTTP. |
| 3 | **Fingerprinting Protection Not Injected** | Scripts written but never injected into page V8 contexts. Fingerprinting test sites show full entropy. |
| 4 | **AI Panel Has No Chat UI** | Panel slides out but contains no messages, no input field, no send button. Dead UI. |
| 5 | **Extension Popups Don't Render** | Clicking extension icons in toolbar does nothing. No popup window creation. |
| 6 | **Cookie Editor Has No UI** | Model exists but no way to view/edit cookies. Developers need this. |
| 7 | **Session Restore Dialog Missing** | Crash is detected but user never sees "Restore your previous session?" prompt. Tabs are lost silently. |
| 8 | **Web Page Context Menu Missing** | Right-click on any web page shows nothing. No copy link, save image, inspect element. |

### P1 — Fix Before Beta Launch (User Expectations)

| # | Issue | Why Important |
|---|-------|---------------|
| 9 | **Extension Content Scripts Not Re-Injected** | Scripts inject on first load but not on SPA navigation (React Router, etc.). Extensions break on modern sites. |
| 10 | **Reader Mode Extraction Quality** | Current extraction is naive textContent. Needs Mozilla Readability.js or equivalent for quality output. |
| 11 | **AI Summarization UI Missing** | Model calls Ollama but no button triggers it. Hidden feature. |
| 12 | **Tab Suspender Doesn't Suspend** | Timer logs but never calls `checkTabs()`. Memory not freed. |
| 13 | **Memory Visualizer Only Tracks Browser Process** | Renderer/GPU memory (the bulk) is not monitored. Misleading data. |
| 14 | **LAN Sync Doesn't Sync** | Discovery works, no data protocol. False promise. |
| 15 | **Terminal Sidebar Is a Shell** | No PTY, no shell, just a label. Remove or implement. |
| 16 | **RSS Reader Has No UI** | Parser works, no feed list, no article view. |
| 17 | **Password Manager Integration** | No 1Password/Bitwarden extension API means no autofill. Users will abandon. |
| 18 | **Chrome Web Store Install Flow** | Button appears but clicking does nothing. No download, extract, install pipeline. |
| 19 | **Search Engine Wizard Not Discoverable** | Buried in settings. No omnibox right-click "add search engine." |
| 20 | **Auto-Update Mechanism** | No Sparkle integration. Users on old builds indefinitely. |

### P2 — Fix Before 1.0 (Polish & Power Users)

| # | Issue | Notes |
|---|-------|-------|
| 21 | **Split View for Tabs** | Data model has `splitTabID`. No UI. |
| 22 | **Custom New Tab Page** | Currently `about:blank`. Needs shortcuts, widgets, background. |
| 23 | **Web App Wrapper** | No .app bundle creation. High-demand feature from Arc users. |
| 24 | **Full-Page Screenshot** | Window capture works. Full page needs CEF DevTools protocol. |
| 25 | **PDF Viewer / Annotation** | CEF renders PDFs poorly. Native PDFKit integration needed. |
| 26 | **Mobile Companion** | iOS app for sync, send-to-device. Ecosystem play. |
| 27 | **Crash Reporting** | No Sentry/Crashlytics. Debugging user issues is impossible. |
| 28 | **Translation UI** | Engine stub, no language picker, no inline translation. |
| 29 | **Voice Search** | CoreAudio works, no Whisper, no speech-to-text in omnibox. |
| 30 | **Annotation / Highlighting** | Students and researchers expect this. Not wired. |

---

## The "What We Actually Have" Summary

### Production-Ready (Grade A-B)
- Core browsing (navigate, back, forward, reload, zoom, find)
- History (SQLite, searchable, suggestions)
- Bookmarks (JSON, folders, toolbar)
- Downloads (CEF-integrated, progress tracking)
- Settings panel (9 tabs, persistence)
- Sidebar (tabs, folders, pins, drag-drop, media player)
- Command palette (history, bookmarks, tab search, actions)
- Theme system (gradients, OKLCH, liquid glass, dark mode)
- Extension catalog (import, enable/disable, persist)
- Basic content script injection
- Mini console (console log streaming)
- macOS menu bar (actions wired to SoulRoot)
- Share sheet integration
- Spotlight indexing (infrastructure)
- Metal rendering infrastructure
- Battery/low power observers

### Partially Working (Grade C)
- Session autosave (writes but doesn't show restore UI)
- Crash recovery (detects but doesn't prompt)
- Privacy dashboard (UI beautiful but data is fake/stale)
- AI features (models exist, UI missing)
- Tab suspender (timer fires but doesn't check tabs)
- Reader mode (flag exists, extraction weak)
- Extension runtime (catalog works, execution half-baked)
- HTTP inspector (model works, no CEF wiring)
- LAN sync (discovery works, no protocol)
- Tab tree (data model, no visual tree)
- Many "developer tools" have models but no CEF integration

### Stubs (Grade D)
- Terminal sidebar
- Cookie editor (no UI)
- SSL certificate viewer
- Annotation/highlighting
- Web app wrapper
- Responsive layout canvas
- Stream downloader
- Voice transcription (no Whisper)
- Offline translation (no model)
- Browser automation (no agent loop)
- App icon creator
- Onboarding tour (model, no UI)
- Focus tracker
- Credentials migration
- Extension sync bridge
- Process priority rebalancer
- V8 context allocator (flags not passed)
- Resource preloader
- Video decode accelerator
- WebGL capture optimizer
- Parallel renderer boot
- Private session mode
- Media capture spoofing

### Entirely Missing (Grade F)
- Password manager autofill (1Password/Bitwarden API)
- Cloud sync (iCloud/CloudKit)
- iOS companion app
- Auto-update (Sparkle)
- Crash reporting
- Context menu on web content
- Custom new tab page
- PDF annotation
- Print dialog
- Full-page screenshot
- Split view UI
- Profile/user accounts
