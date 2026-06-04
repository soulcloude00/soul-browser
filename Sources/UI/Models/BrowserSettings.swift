import SwiftUI

/// User-facing browser preferences. Persisted to `UserDefaults` and observed by
/// the chrome so changes apply live. One shared instance backs the single
/// window; views that need live updates observe it directly.
final class BrowserSettings: ObservableObject {
    static let shared = BrowserSettings()

    // MARK: General

    /// The page opened at launch and by "new tab → homepage".
    @Published var homepageURL: String {
        didSet { defaults.set(homepageURL, forKey: Key.homepage) }
    }

    /// What a freshly opened tab loads.
    @Published var newTabBehavior: NewTabBehavior {
        didSet { defaults.set(newTabBehavior.rawValue, forKey: Key.newTab) }
    }

    // MARK: Search

    @Published var searchEngine: SearchEngine {
        didSet { defaults.set(searchEngine.rawValue, forKey: Key.engine) }
    }

    /// Used only when `searchEngine == .custom`. `{query}` is substituted.
    @Published var customSearchTemplate: String {
        didSet { defaults.set(customSearchTemplate, forKey: Key.customEngine) }
    }

    // MARK: Appearance

    @Published var theme: ThemePreference {
        didSet { defaults.set(theme.rawValue, forKey: Key.theme) }
    }

    /// Whether the tab sidebar is shown when the window opens.
    @Published var showSidebarOnLaunch: Bool {
        didSet { defaults.set(showSidebarOnLaunch, forKey: Key.sidebarOnLaunch) }
    }

    /// Which side of the window hosts the tab sidebar.
    @Published var sidebarPosition: SidebarPosition {
        didSet { defaults.set(sidebarPosition.rawValue, forKey: Key.sidebarPosition) }
    }

    /// The user's custom gradient theme (chrome wash + derived accent). Empty
    /// means "no custom theme" — the chrome uses the plain light/dark tint.
    /// Persisted as JSON. Single global theme for now; when multi-space lands,
    /// this becomes a per-space map keyed by the active space.
    @Published var gradientTheme: GradientTheme {
        didSet {
            if let data = try? JSONEncoder().encode(gradientTheme) {
                defaults.set(data, forKey: Key.gradientTheme)
            }
        }
    }

    // MARK: Media

    /// Automatically enter Picture-in-Picture when you switch away from a tab
    /// that's playing video (YouTube, etc.).
    @Published var autoPiP: Bool {
        didSet {
            defaults.set(autoPiP, forKey: Key.autoPiP)
            SoulBrowserView.setAutoPiPEnabled(autoPiP)
        }
    }

    // MARK: Privacy & Security

    /// Natively blocks known ad and tracking domains.
    @Published var enableAdBlocker: Bool {
        didSet {
            defaults.set(enableAdBlocker, forKey: Key.enableAdBlocker)
            SoulBrowserView.setAdBlockerEnabled(enableAdBlocker)
        }
    }

    @Published var adBlockExceptions: Set<String> {
        didSet {
            let array = Array(adBlockExceptions)
            defaults.set(array, forKey: Key.adBlockExceptions)
            SoulBrowserView.setAdBlockExceptions(array)
        }
    }

    @Published var developerModeEnabled: Bool {
        didSet {
            defaults.set(developerModeEnabled, forKey: Key.developerModeEnabled)
        }
    }

    /// Show the bookmarks bar below the toolbar for one-click access.
    @Published var showBookmarkBar: Bool {
        didSet {
            defaults.set(showBookmarkBar, forKey: Key.showBookmarkBar)
        }
    }

    /// Maximum number of recently closed tabs to remember for Cmd-Shift-T.
    @Published var closedTabHistoryLimit: Int {
        didSet {
            defaults.set(closedTabHistoryLimit, forKey: Key.closedTabHistoryLimit)
        }
    }

    // MARK: Resolution helpers

    /// The built-in start page, served from Soul's internal scheme so it
    /// reads as native chrome (empty address bar, no file:// path).
    static let defaultHomepageURL = "soul://newtab/"

    /// Build the destination for a query, honoring the active engine.
    func searchURL(for query: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+?/#")
        let encoded = query.addingPercentEncoding(withAllowedCharacters: allowed) ?? query
        let rawTemplate = searchEngine == .custom ? customSearchTemplate : searchEngine.queryTemplate
        let template = rawTemplate.isEmpty ? SearchEngine.google.queryTemplate : rawTemplate
        if template.contains("{query}") {
            return template.replacingOccurrences(of: "{query}", with: encoded)
        }
        // Tolerate a bare endpoint by appending the query.
        return template + encoded
    }

    /// The URL a new tab should load given the current behavior setting.
    var newTabURL: String {
        switch newTabBehavior {
        case .homepage: return homepageURL
        case .blank: return "about:blank"
        }
    }

    // MARK: Persistence

    private let defaults: UserDefaults

    private enum Key {
        static let homepage = "soul.homepageURL"
        static let newTab = "soul.newTabBehavior"
        static let engine = "soul.searchEngine"
        static let customEngine = "soul.customSearchTemplate"
        static let theme = "soul.theme"
        static let sidebarOnLaunch = "soul.showSidebarOnLaunch"
        static let sidebarPosition = "soul.sidebarPosition"
        static let autoPiP = "soul.autoPiP"
        static let gradientTheme = "soul.gradientTheme"
        static let enableAdBlocker = "soul.enableAdBlocker"
        static let adBlockExceptions = "soul.adBlockExceptions"
        static let developerModeEnabled = "soul.developerModeEnabled"
        static let showBookmarkBar = "soul.showBookmarkBar"
        static let closedTabHistoryLimit = "soul.closedTabHistoryLimit"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // Migrate the earlier bundled file:// home page to the internal scheme.
        let storedHome = defaults.string(forKey: Key.homepage)
        let resolvedHome: String
        if let storedHome, storedHome.contains("home.html") {
            resolvedHome = BrowserSettings.defaultHomepageURL
            defaults.set(resolvedHome, forKey: Key.homepage)
        } else {
            resolvedHome = storedHome ?? BrowserSettings.defaultHomepageURL
        }
        homepageURL = resolvedHome
        newTabBehavior = NewTabBehavior(rawValue: defaults.string(forKey: Key.newTab) ?? "")
            ?? .homepage
        searchEngine = SearchEngine(rawValue: defaults.string(forKey: Key.engine) ?? "")
            ?? .google
        customSearchTemplate = defaults.string(forKey: Key.customEngine)
            ?? "https://www.example.com/search?q={query}"
        theme = ThemePreference(rawValue: defaults.string(forKey: Key.theme) ?? "")
            ?? .system
        // Default the sidebar on (matches the Soul default chrome).
        showSidebarOnLaunch = defaults.object(forKey: Key.sidebarOnLaunch) as? Bool ?? true
        // Default the sidebar to the right to preserve the existing layout.
        sidebarPosition = SidebarPosition(rawValue: defaults.string(forKey: Key.sidebarPosition) ?? "")
            ?? .right
        gradientTheme = defaults.data(forKey: Key.gradientTheme)
            .flatMap { try? JSONDecoder().decode(GradientTheme.self, from: $0) }
            ?? .none
        autoPiP = defaults.object(forKey: Key.autoPiP) as? Bool ?? true
        enableAdBlocker = defaults.object(forKey: Key.enableAdBlocker) as? Bool ?? true
        if let exceptionsArray = defaults.stringArray(forKey: Key.adBlockExceptions) {
            adBlockExceptions = Set(exceptionsArray)
        } else {
            adBlockExceptions = []
        }
        developerModeEnabled = defaults.object(forKey: Key.developerModeEnabled) as? Bool ?? false
        showBookmarkBar = defaults.object(forKey: Key.showBookmarkBar) as? Bool ?? true
        closedTabHistoryLimit = defaults.object(forKey: Key.closedTabHistoryLimit) as? Int ?? 25

        // Apply the persisted auto-PiP default to the engine on startup.
        SoulBrowserView.setAutoPiPEnabled(autoPiP)
        SoulBrowserView.setAdBlockerEnabled(enableAdBlocker)
        SoulBrowserView.setAdBlockExceptions(Array(adBlockExceptions))
        SoulBrowserView.setHTTPSOnlyEnabled(true)
    }
}

// MARK: - Option enums

enum SidebarPosition: String, CaseIterable, Identifiable {
    case left, right
    var id: String { rawValue }

    var label: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        }
    }

    var symbol: String {
        switch self {
        case .left: return "sidebar.left"
        case .right: return "sidebar.right"
        }
    }

    var edge: Edge {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }
}

enum ThemePreference: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var symbol: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }

    /// nil = follow the system appearance.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum NewTabBehavior: String, CaseIterable, Identifiable {
    case homepage, blank
    var id: String { rawValue }

    var label: String {
        switch self {
        case .homepage: return "Open homepage"
        case .blank: return "Open a blank page"
        }
    }
}

enum SearchEngine: String, CaseIterable, Identifiable {
    case google, duckduckgo, bing, brave, custom
    var id: String { rawValue }

    var label: String {
        switch self {
        case .google: return "Google"
        case .duckduckgo: return "DuckDuckGo"
        case .bing: return "Bing"
        case .brave: return "Brave"
        case .custom: return "Custom…"
        }
    }

    /// `{query}` is replaced with the percent-encoded search terms.
    var queryTemplate: String {
        switch self {
        case .google: return "https://www.google.com/search?q={query}"
        case .duckduckgo: return "https://duckduckgo.com/?q={query}"
        case .bing: return "https://www.bing.com/search?q={query}"
        case .brave: return "https://search.brave.com/search?q={query}"
        case .custom: return ""
        }
    }
}
