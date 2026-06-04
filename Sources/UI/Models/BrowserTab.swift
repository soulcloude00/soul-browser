import SwiftUI
import AppKit

/// Represents a javascript console log message.
struct LogMessage: Identifiable {
    let id = UUID()
    let timestamp = Date()
    let level: Int
    let message: String
    let source: String
    let line: Int
}

/// One browser tab. Owns a native `SoulBrowserView` (a live CEF browser) and
/// republishes its navigation state for SwiftUI. The native view is created
/// lazily so background/unopened tabs stay cheap.
final class BrowserTab: NSObject, ObservableObject, Identifiable {
    let id: UUID
    let workspaceID: String
    let extensionTabID: Int
    private static var nextExtensionTabID = 1

    @Published var title: String
    @Published var urlString: String
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var faviconURL: String?
    @Published var dominantColor: Color = .clear
    @Published var didFail: Bool = false
    @Published var isMatrixMode: Bool = false {
        didSet {
            if !isMatrixMode {
                _tabletBrowserView?.closeBrowser()
                _tabletBrowserView = nil
                _mobileBrowserView?.closeBrowser()
                _mobileBrowserView = nil
            }
        }
    }
    
    /// Developer console logs for this tab
    @Published var consoleLogs: [LogMessage] = []

    /// Find-in-page results for the active query (1-based active match, total).
    @Published var findOrdinal: Int = 0
    @Published var findCount: Int = 0

    /// Tab Tree properties
    @Published var parentTabID: UUID?
    @Published var isCollapsed: Bool = false

    /// Tab Split View properties
    @Published var splitTabID: UUID?

    /// Article Reader Mode properties
    @Published var isReaderMode: Bool = false

    /// Tab suspension (performance optimization)
    @Published var isSuspended: Bool = false
    var lastActiveAt: Date = Date()

    /// Native AdBlocker tracking count for the current page
    @Published var blockedTrackers: Set<String> = []

    /// Page zoom as a percentage (100 = default). Tracked on the Swift side so
    /// the chrome can show it: CEF zoom is logarithmic (factor = 1.2^level) and
    /// every zoom command routes through the methods below, so mirroring the
    /// level here stays in sync without a native readback.
    @Published private(set) var zoomPercent: Int = 100
    /// Mirrors `kZoomStep` in SoulBrowserView.mm.
    private static let zoomStep = 0.5
    private var zoomLevel: Double = 0 {
        didSet { zoomPercent = Int((pow(1.2, zoomLevel) * 100).rounded()) }
    }

    /// The address shown in the omnibox while the user is *not* editing it.
    var displayURL: String {
        if urlString == "about:blank" { return "" }
        if urlString.hasPrefix("soul://") { return "" }
        return urlString
    }

    /// Cached URL scheme to avoid repeated parsing in hot paths (StatusBar, security indicators).
    var urlScheme: String {
        URL(string: urlString)?.scheme?.lowercased() ?? ""
    }

    /// Callback set by the store so a tab can request opening a sibling tab
    /// (popups / target=_blank).
    var onRequestNewTab: ((String) -> Void)?
    var onExtensionTabUpdated: ((BrowserTab, [String: Any]) -> Void)?
    var onExtensionNavigationEvent: ((String, BrowserTab, [String: Any]) -> Void)?

    private(set) lazy var browserView: SoulBrowserView = {
        let view = SoulBrowserView(url: urlString, workspaceID: workspaceID)
        view.extensionTabID = extensionTabID
        view.navDelegate = self
        return view
    }()

    private var _tabletBrowserView: SoulBrowserView?
    private var _mobileBrowserView: SoulBrowserView?

    var tabletBrowserView: SoulBrowserView {
        if let view = _tabletBrowserView { return view }
        let view = SoulBrowserView(url: urlString, workspaceID: workspaceID)
        view.extensionTabID = extensionTabID
        view.navDelegate = nil
        _tabletBrowserView = view
        return view
    }

    var mobileBrowserView: SoulBrowserView {
        if let view = _mobileBrowserView { return view }
        let view = SoulBrowserView(url: urlString, workspaceID: workspaceID)
        view.extensionTabID = extensionTabID
        view.navDelegate = nil
        _mobileBrowserView = view
        return view
    }

    private var isRealized = false

    init(id: UUID = UUID(), url: String, title: String = "New Tab", workspaceID: String = "personal", parentTabID: UUID? = nil, isCollapsed: Bool = false, splitTabID: UUID? = nil) {
        self.id = id
        self.workspaceID = workspaceID
        self.parentTabID = parentTabID
        self.isCollapsed = isCollapsed
        self.splitTabID = splitTabID
        extensionTabID = Self.nextExtensionTabID
        Self.nextExtensionTabID += 1
        self.urlString = url
        self.dominantColor = FaviconSource.themeColor(for: FaviconSource.host(from: url))
        self.title = title
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConsoleMessage(_:)),
            name: NSNotification.Name("SoulConsoleMessageReceived"),
            object: nil
        )
    }

    @objc private func handleConsoleMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let browserId = userInfo["browserId"] as? Int,
              hasRealized,
              browserView.browserIdentifier == browserId else {
            return
        }
        
        let level = userInfo["level"] as? Int ?? 0
        let message = userInfo["message"] as? String ?? ""
        let source = userInfo["source"] as? String ?? ""
        let line = userInfo["line"] as? Int ?? 0
        
        let log = LogMessage(level: level, message: message, source: source, line: line)
        DispatchQueue.main.async {
            self.consoleLogs.append(log)
            // Limit to 500 logs to avoid memory bloat
            if self.consoleLogs.count > 500 {
                self.consoleLogs.removeFirst(self.consoleLogs.count - 500)
            }
        }

        // Bridge for Chrome Web Store "Install in Soul" button clicks.
        if message.hasPrefix("SOUL_CWS_INSTALL:") {
            let id = String(message.dropFirst("SOUL_CWS_INSTALL:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            if !id.isEmpty {
                CWSInstaller.shared.install(extensionID: id)
            }
        }
    }

    /// Force the native view (and CEF browser) into existence.
    @discardableResult
    func realize() -> SoulBrowserView {
        isRealized = true
        return browserView
    }

    var hasRealized: Bool { isRealized }

    // MARK: Navigation passthrough

    func load(_ url: String) {
        let target = SoulURLRewriter.rewrite(url)
        urlString = target
        didFail = false
        onExtensionTabUpdated?(self, ["url": target, "status": "loading"])
        realize().loadURL(target)
        if isMatrixMode {
            tabletBrowserView.loadURL(target)
            mobileBrowserView.loadURL(target)
        }
    }

    func goBack() { 
        browserView.goBack()
        if isMatrixMode { tabletBrowserView.goBack(); mobileBrowserView.goBack() }
    }
    func goForward() { 
        browserView.goForward()
        if isMatrixMode { tabletBrowserView.goForward(); mobileBrowserView.goForward() }
    }
    func reload() {
        didFail = false
        browserView.reload()
        if isMatrixMode { tabletBrowserView.reload(); mobileBrowserView.reload() }
    }
    func reloadIgnoringCache() {
        didFail = false
        browserView.reloadIgnoringCache()
        if isMatrixMode { tabletBrowserView.reloadIgnoringCache(); mobileBrowserView.reloadIgnoringCache() }
    }
    func stop() { 
        browserView.stopLoading()
        if isMatrixMode { tabletBrowserView.stopLoading(); mobileBrowserView.stopLoading() }
    }
    func focus() { browserView.focusBrowser() }
    func startDownload(url: String, extensionID: String, requestID: String, filename: String?) -> Bool {
        realize().startDownload(url, extensionID: extensionID, requestID: requestID, filename: filename)
    }

    func captureVisiblePNGDataURL(extensionID: String, requestID: String) -> Bool {
        guard hasRealized else { return false }
        return browserView.captureVisiblePNGDataURL(forExtensionID: extensionID, requestID: requestID)
    }

    func evaluateJavaScript(_ source: String) async throws -> Any {
        let view = realize()
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            func resumeOnce(_ result: Result<Any, Error>) {
                guard !didResume else { return }
                didResume = true
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            let started = view.evaluateJavaScript(source) { result, errorMessage in
                if let errorMessage, !errorMessage.isEmpty {
                    resumeOnce(.failure(BrowserAutomationError.pageScriptFailed(errorMessage)))
                    return
                }
                resumeOnce(.success(result ?? NSNull()))
            }
            if !started {
                resumeOnce(.failure(BrowserAutomationError.browserUnavailable))
            }
        }
    }

    func zoomIn() { zoomLevel += Self.zoomStep; browserView.zoomIn() }
    func zoomOut() { zoomLevel -= Self.zoomStep; browserView.zoomOut() }
    func resetZoom() { zoomLevel = 0; browserView.resetZoom() }
    func setZoomFactor(_ factor: Double) {
        let safeFactor = min(max(factor, 0.25), 5.0)
        zoomLevel = log(safeFactor) / log(1.2)
        realize().setZoomFactor(safeFactor)
    }

    // MARK: Find-in-page / devtools / print

    func find(_ text: String, forward: Bool = true) {
        browserView.findText(text, forward: forward)
    }

    func stopFind() {
        browserView.stopFinding(true)
        findOrdinal = 0
        findCount = 0
    }

    func showDevTools() { browserView.showDevTools() }
    func toggleDevTools() { browserView.toggleDevTools() }
    func printPage() { browserView.printPage() }

    func close() {
        if isRealized {
            browserView.closeBrowser()
        }
        _tabletBrowserView?.closeBrowser()
        _mobileBrowserView?.closeBrowser()
    }

    // MARK: - Tab Suspension

    /// Suspend this tab to free its renderer process. Saves the current URL
    /// and kills the CEF browser. The tab stays in the sidebar with a 💤 badge.
    func suspend() {
        guard isRealized, !isSuspended else { return }
        isSuspended = true
        browserView.closeBrowser()
        isRealized = false
    }

    /// Wake a suspended tab by re-realizing its browser view and reloading.
    func unsuspend() {
        guard isSuspended else { return }
        isSuspended = false
        lastActiveAt = Date()
        load(urlString.isEmpty ? "about:blank" : urlString)
    }

    /// Tell the CEF renderer whether this tab's content is visible.
    /// Hidden tabs stop compositing, saving significant GPU cycles.
    func setContentHidden(_ hidden: Bool) {
        guard isRealized, !isSuspended else { return }
        browserView.isHidden = hidden
    }

    func toggleReaderMode() {
        guard hasRealized, !isSuspended else { return }
        
        let js = #"""
        (function() {
            if (window.__originalBodyHTML) {
                document.body.innerHTML = window.__originalBodyHTML;
                if (window.__originalHeadHTML) {
                    document.head.innerHTML = window.__originalHeadHTML;
                }
                delete window.__originalBodyHTML;
                delete window.__originalHeadHTML;
                return "restored";
            }

            window.__originalBodyHTML = document.body.innerHTML;
            window.__originalHeadHTML = document.head.innerHTML;

            const title = document.querySelector('h1')?.innerText || document.title;
            
            let bestContainer = null;
            let maxTextLen = 0;
            
            const candidates = document.querySelectorAll('article, main, .article, .post, .entry, .content, div');
            for (let c of candidates) {
                let pCount = c.querySelectorAll('p').length;
                if (pCount > 0) {
                    let textLen = 0;
                    c.querySelectorAll('p').forEach(p => textLen += p.innerText.length);
                    if (textLen > maxTextLen) {
                        maxTextLen = textLen;
                        bestContainer = c;
                    }
                }
            }
            
            if (!bestContainer) {
                bestContainer = document.body;
            }
            
            const elements = bestContainer.querySelectorAll('p, h2, h3, img, ul, ol, pre, code');
            let articleHTML = "";
            
            for (let el of elements) {
                if (el.tagName === 'P') {
                    if (el.innerText.trim().length > 10) {
                        articleHTML += `<p>${el.innerHTML}</p>`;
                    }
                } else if (el.tagName.startsWith('H')) {
                    articleHTML += `<${el.tagName.toLowerCase()}>${el.innerHTML}</${el.tagName.toLowerCase()}>`;
                } else if (el.tagName === 'IMG') {
                    const src = el.getAttribute('src');
                    if (src) {
                        articleHTML += `<div class="img-wrapper"><img src="${src}" alt="Article Image"></div>`;
                    }
                } else if (el.tagName === 'UL' || el.tagName === 'OL') {
                    articleHTML += el.outerHTML;
                } else if (el.tagName === 'PRE') {
                    articleHTML += el.outerHTML;
                }
            }
            
            if (articleHTML.length < 100) {
                articleHTML = bestContainer.innerHTML;
            }

            const style = document.createElement('style');
            style.innerHTML = `
                html, body {
                    background-color: #121212 !important;
                    color: #e4e4e7 !important;
                    font-family: Georgia, serif !important;
                    line-height: 1.62 !important;
                    font-size: 18px !important;
                    margin: 0 !important;
                    padding: 0 !important;
                    width: 100% !important;
                }
                @media (prefers-color-scheme: light) {
                    html, body {
                        background-color: #fcfbf9 !important;
                        color: #1c1c1e !important;
                    }
                }
                .reader-container {
                    max-width: 680px !important;
                    margin: 0 auto !important;
                    padding: 60px 24px !important;
                    box-sizing: border-box !important;
                }
                h1 {
                    font-size: 34px !important;
                    font-weight: 800 !important;
                    line-height: 1.25 !important;
                    margin-bottom: 24px !important;
                    letter-spacing: -0.02em !important;
                    font-family: -apple-system, BlinkMacSystemFont, system-ui, sans-serif !important;
                }
                h2, h3 {
                    font-family: -apple-system, BlinkMacSystemFont, system-ui, sans-serif !important;
                    margin-top: 36px !important;
                    margin-bottom: 16px !important;
                }
                p { margin-bottom: 20px !important; }
                img {
                    max-width: 100% !important;
                    height: auto !important;
                    border-radius: 8px !important;
                    display: block !important;
                    margin: 0 auto !important;
                }
                .img-wrapper { margin: 32px 0 !important; }
                pre, code {
                    font-family: ui-monospace, monospace !important;
                    background: rgba(255, 255, 255, 0.05) !important;
                    padding: 2px 6px !important;
                    border-radius: 4px !important;
                    font-size: 15px !important;
                }
                pre {
                    padding: 16px !important;
                    overflow-x: auto !important;
                    margin: 24px 0 !important;
                }
                ul, ol { margin-bottom: 20px !important; padding-left: 24px !important; }
                li { margin-bottom: 8px !important; }
                a { color: #8b5cf6 !important; text-decoration: underline !important; }
                @media (prefers-color-scheme: light) {
                    a { color: #6d28d9 !important; }
                    pre, code { background: rgba(0, 0, 0, 0.04) !important; }
                }
            `;

            document.head.innerHTML = "";
            document.head.appendChild(style);
            
            document.body.innerHTML = `
                <div class="reader-container">
                    <h1>${title}</h1>
                    <div class="reader-content">
                        ${articleHTML}
                    </div>
                </div>
            `;
            return "activated";
        })()
        """#
        
        browserView.evaluateJavaScript(js) { [weak self] result, error in
            guard let self = self else { return }
            if let status = result as? String {
                DispatchQueue.main.async {
                    self.isReaderMode = (status == "activated")
                }
            }
        }
    }
}

// MARK: - SoulBrowserViewDelegate

extension BrowserTab: SoulBrowserViewDelegate {
    func browserView(_ view: SoulBrowserView, didChangeTitle title: String) {
        self.title = title.isEmpty ? "Untitled" : title
        HistoryStore.shared.updateTitle(self.title, for: urlString)
        onExtensionTabUpdated?(self, ["title": self.title])
    }

    func browserView(_ view: SoulBrowserView, didChangeURL url: String) {
        self.urlString = url
        self.dominantColor = FaviconSource.themeColor(for: FaviconSource.host(from: url))
        HistoryStore.shared.record(url: url, title: title)
        onExtensionTabUpdated?(self, ["url": url])
    }

    func browserView(_ view: SoulBrowserView,
                     didChangeLoading isLoading: Bool,
                     canGoBack: Bool,
                     canGoForward: Bool) {
        if isLoading {
            didFail = false
        }
        self.isLoading = isLoading
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        onExtensionTabUpdated?(self, ["status": isLoading ? "loading" : "complete"])
    }

    func browserView(_ view: SoulBrowserView, didChangeFaviconURLs urls: [String]) {
        self.faviconURL = urls.first
        if let faviconURL {
            onExtensionTabUpdated?(self, ["favIconUrl": faviconURL])
        }
    }

    func browserView(_ view: SoulBrowserView,
                     didStartNavigationToURL url: String,
                     isRedirect: Bool,
                     userGesture: Bool) {
        self.isReaderMode = false
        if !isRedirect {
            self.blockedTrackers.removeAll()
        }
        onExtensionNavigationEvent?("webNavigation.onBeforeNavigate", self, [
            "url": url,
            "frameId": 0,
            "parentFrameId": -1,
            "isRedirect": isRedirect,
            "userGesture": userGesture
        ])
    }

    func browserView(_ view: SoulBrowserView, didCommitNavigationToURL url: String) {
        injectUserScripts(for: url, runAt: .documentStart)
        onExtensionNavigationEvent?("webNavigation.onCommitted", self, [
            "url": url,
            "frameId": 0,
            "parentFrameId": -1,
            "transitionType": "link",
            "transitionQualifiers": []
        ])
    }

    func browserView(_ view: SoulBrowserView,
                     didFinishNavigationToURL url: String,
                     httpStatusCode: Int) {
        injectUserScripts(for: url, runAt: .documentEnd)

        // Inject the "Install in Soul" button on Chrome Web Store pages.
        if ChromeWebStoreInjector.shared.isChromeWebStoreURL(url) {
            let script = ChromeWebStoreInjector.shared.installationScript()
            browserView.evaluateJavaScript(script) { _, _ in }
        }

        let details: [String: Any] = [
            "url": url,
            "frameId": 0,
            "parentFrameId": -1,
            "statusCode": httpStatusCode
        ]
        onExtensionNavigationEvent?("webNavigation.onDOMContentLoaded", self, details)
        onExtensionNavigationEvent?("webNavigation.onCompleted", self, details)
    }

    /// Inject enabled user scripts whose pattern matches the current URL.
    private func injectUserScripts(for url: String, runAt: UserScript.RunAt) {
        let scripts = UserScriptStore.shared.scripts(for: url, at: runAt)
        for script in scripts {
            let wrapped = """
                (function(){try{var __soulScriptName='\(script.name.replacingOccurrences(of: "'", with: "\\'"))';
                \(script.code)
                }catch(e){console.error('[Soul user-script]','\(script.name)',e);}})();
                """
            browserView.evaluateJavaScript(wrapped) { _, _ in }
        }
    }

    func browserView(_ view: SoulBrowserView,
                     didFailLoad errorText: String,
                     failedURL: String) {
        self.didFail = true
        onExtensionNavigationEvent?("webNavigation.onErrorOccurred", self, [
            "url": failedURL,
            "frameId": 0,
            "parentFrameId": -1,
            "error": errorText
        ])
    }

    func browserView(_ view: SoulBrowserView, requestsNewTabWithURL url: String) {
        onRequestNewTab?(url)
    }

    func browserView(_ view: SoulBrowserView,
                     didUpdateFindMatchOrdinal ordinal: Int32,
                     ofMatches count: Int32) {
        self.findOrdinal = Int(ordinal)
        self.findCount = Int(count)
    }

    func browserView(_ view: SoulBrowserView, didBlockTracker host: String) {
        if !host.isEmpty {
            self.blockedTrackers.insert(host)
        }
    }
}
