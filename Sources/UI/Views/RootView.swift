import SwiftUI

/// The complete browser chrome: web content, optional AI panel, and the
/// user-positioned vertical tab sidebar (right by default).
struct RootView: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject private var settings = BrowserSettings.shared
    @ObservedObject private var onboarding = OnboardingTour.shared
    @Environment(\.colorScheme) private var systemScheme

    private var gradientTheme: GradientTheme { settings.gradientTheme }

    private var scheme: ColorScheme {
        GradientEngine.effectiveScheme(
            for: gradientTheme,
            base: settings.theme.colorScheme ?? systemScheme
        )
    }

    private var palette: ThemePalette {
        ThemePalette.forScheme(scheme).applying(theme: gradientTheme, scheme: scheme)
    }

    var body: some View {
        let activeTab = store.selectedTab ?? store.tabs.first
        mainContent(activeTab: activeTab)
            .overlay(alignment: .topLeading) {
                ExtensionBackgroundRunners()
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .overlay {
                if store.sessionResumption.detectedCrash {
                    SessionRestoreOverlay(store: store)
                        .ignoresSafeArea()
                }
            }
            .overlay {
                if !onboarding.hasCompletedOnboarding {
                    OnboardingView(tour: onboarding)
                        .ignoresSafeArea()
                }
            }
            .environment(\.palette, palette)
            .preferredColorScheme(scheme)
            .background { chromeBackground(activeTab: activeTab) }
            .ignoresSafeArea()
            .animation(Motion.reveal, value: store.aiPanelVisible)
            .animation(Motion.reveal, value: store.notesPanelVisible)
            .animation(Motion.reveal, value: store.rssReaderVisible)
            .animation(Motion.snappy, value: store.sidebarVisible)
            .animation(Motion.snappy, value: settings.sidebarPosition)
            .sheet(isPresented: $store.settingsVisible) {
                SettingsView(store: store)
                    .environment(\.palette, palette)
                    .preferredColorScheme(scheme)
            }
    }

    @ViewBuilder
    private func mainContent(activeTab: BrowserTab?) -> some View {
        HStack(spacing: 0) {
            if store.sidebarVisible && !store.isFocusMode, settings.sidebarPosition == .left {
                Sidebar(store: store)
                    .transition(.move(edge: settings.sidebarPosition.edge))
            }

            webContentColumn(activeTab: activeTab)

            // AI panel.
            if store.aiPanelVisible {
                AIPanel(store: store)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }

            // Quick notes panel.
            if store.notesPanelVisible {
                NotesPanel(store: store)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }

            // Cookie & Storage Editor panel.
            if store.cookieEditorVisible {
                CookieEditorPanel(store: store)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }

            // RSS Reader panel.
            if store.rssReaderVisible {
                RSSReaderPanel(store: store)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }

            if store.extensionSidePanelURL != nil {
                ExtensionSidePanel(store: store)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            if store.sidebarVisible && !store.isFocusMode, settings.sidebarPosition == .right {
                Sidebar(store: store)
                    .transition(.move(edge: settings.sidebarPosition.edge))
            }
        }
        // Hover-to-peek sidebar
        .overlay {
            SidebarPeekOverlay(store: store, palette: palette, scheme: scheme,
                               enabled: !store.sidebarVisible,
                               sidebarPosition: settings.sidebarPosition)
                .ignoresSafeArea()
        }
        // New-tab launcher
        .overlay {
            LauncherOverlay(store: store, palette: palette, scheme: scheme)
                .ignoresSafeArea()
        }
        // Extension manager
        .overlay {
            ExtensionManagerOverlay(store: store, palette: palette, scheme: scheme)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func webContentColumn(activeTab: BrowserTab?) -> some View {
        VStack(spacing: 0) {
            WebTopStrip(tab: activeTab)
                .frame(height: store.isFocusMode ? 0 : 4)
                .opacity(store.isFocusMode ? 0 : 1)
                .clipped()
            if settings.showBookmarkBar, !store.isFocusMode {
                BookmarkBar(store: store, bookmarks: BookmarkStore.shared)
            }
            webCard(activeTab: activeTab)
                .offset(y: store.topChromeRevealed ? TopChromeContainerView.revealHeight : 0)
                .animation(Motion.snappy, value: store.topChromeRevealed)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            TopChromeOverlay(store: store, sidebarPosition: settings.sidebarPosition)
                .frame(height: 60)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func chromeBackground(activeTab: BrowserTab?) -> some View {
        ZStack {
            VisualEffectBackground(material: .sidebar)
            if let tab = activeTab {
                LinearGradient(
                    colors: [
                        tab.dominantColor.opacity(0.4),
                        tab.dominantColor.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .animation(.easeInOut(duration: 0.6), value: tab.dominantColor)
            }
            if gradientTheme.isEmpty {
                palette.sidebar.color.opacity(0.55)
            } else {
                GradientEngine.chromeView(for: gradientTheme, scheme: scheme)
                    .opacity(gradientTheme.opacity)
                if gradientTheme.texture > 0 {
                    GrainOverlay(amount: gradientTheme.texture)
                }
            }
        }
        .ignoresSafeArea()
    }

    /// The browser, wrapped in a floating rounded card with a hairline border
    /// and a soft drop shadow, inset from the window edges so the chrome reads
    /// as a frame around the content (à la Arc).
    @ViewBuilder
    private func webCard(activeTab: BrowserTab?) -> some View {
        ZStack {
            // Card surface + shadow live on a real SwiftUI shape so the shadow
            // hugs the rounded corners (a clipped NSView can't cast one itself).
            RoundedRectangle(cornerRadius: Radius.window, style: .continuous)
                .fill(palette.card.color)
                .shadow(color: .black.opacity(scheme == .dark ? 0.40 : 0.10),
                        radius: 8, x: 0, y: 2)

            if let activeTab {
                ActiveWebContent(store: store,
                                 tab: activeTab,
                                 cornerRadius: Radius.window)
            }
        }
        .overlay(alignment: .topTrailing) {
            if store.findBarVisible, let tab = activeTab {
                FindBar(store: store, tab: tab)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if store.miniConsoleVisible, let tab = activeTab {
                MiniConsoleView(tab: tab, store: store)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.window, style: .continuous))
            }
        }
        .overlay(alignment: .bottom) {
            StatusBar(tab: activeTab)
        }
        .overlay(
            RoundedRectangle(cornerRadius: Radius.window, style: .continuous)
                .strokeBorder(palette.border.color.opacity(0.7), lineWidth: 1)
        )
        .padding(.top, 4)
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .padding(.bottom, 8)
    }
}

private struct ActiveWebContent: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject var tab: BrowserTab
    let cornerRadius: CGFloat

    var body: some View {
        if tab.isMatrixMode {
            MatrixContainerView(store: store, tab: tab, cornerRadius: cornerRadius)
        } else {
            WebContainerView(store: store, activeTab: tab, cornerRadius: cornerRadius)
        }

        if tab.didFail {
            ErrorOverlay(tab: tab)
        }
    }
}

private struct MatrixContainerView: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject var tab: BrowserTab
    let cornerRadius: CGFloat
    @Environment(\.palette) private var p

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                // Primary Browser (Desktop)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Desktop")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(p.mutedForeground.color)
                    WebContainerView(store: store, activeTab: tab, cornerRadius: cornerRadius)
                        .frame(minWidth: 1024)
                }

                // Tablet Browser
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tablet")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(p.mutedForeground.color)
                    SingleWebView(browserView: tab.tabletBrowserView)
                        .frame(width: 768)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(p.border.color.opacity(0.3), lineWidth: 1)
                        )
                }

                // Mobile Browser
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mobile")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(p.mutedForeground.color)
                    SingleWebView(browserView: tab.mobileBrowserView)
                        .frame(width: 375)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(p.border.color.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(24)
        }
        .background(p.background.color)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private struct GrainOverlay: View {
    let amount: Double

    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

private struct ExtensionBackgroundRunners: View {
    @ObservedObject private var extensions = ExtensionStore.shared

    var body: some View {
        ExtensionBackgroundRunnerHost(runners: extensions.backgroundRunners)
    }
}

private struct ExtensionBackgroundRunnerHost: NSViewRepresentable {
    let runners: [ExtensionStore.BackgroundRunner]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        view.wantsLayer = true
        view.alphaValue = 0.01
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.sync(runners: runners, in: nsView)
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.closeAll()
    }

    final class Coordinator {
        private struct RunnerView {
            let url: String
            let view: SoulBrowserView
        }

        private var views: [String: RunnerView] = [:]

        func sync(runners: [ExtensionStore.BackgroundRunner], in container: NSView) {
            let wanted = Set(runners.map(\.id))
            for id in Array(views.keys) where !wanted.contains(id) {
                views[id]?.view.closeBrowser()
                views[id]?.view.removeFromSuperview()
                views.removeValue(forKey: id)
            }

            for runner in runners {
                if let existing = views[runner.id] {
                    if existing.url != runner.url {
                        existing.view.loadURL(runner.url)
                        views[runner.id] = RunnerView(url: runner.url, view: existing.view)
                    }
                    continue
                }

                let view = SoulBrowserView(url: runner.url)
                view.frame = NSRect(x: 0, y: 0, width: 1, height: 1)
                view.autoresizingMask = []
                container.addSubview(view)
                views[runner.id] = RunnerView(url: runner.url, view: view)
            }
        }

        func closeAll() {
            for runner in views.values {
                runner.view.closeBrowser()
                runner.view.removeFromSuperview()
            }
            views.removeAll()
        }
    }
}

private struct ExtensionSidePanel: View {
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Icon(name: "sidebar.trailing", size: 15, weight: .regular)
                    .foregroundStyle(p.primary.color)
                Text(store.extensionSidePanelTitle ?? "Extension")
                    .font(Typography.ui(15, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                    .lineLimit(1)
                Spacer()
                IconButton(systemName: "xmark", size: 28) {
                    store.closeExtensionSidePanel()
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)

            Hairline().opacity(0.6)

            if let url = store.extensionSidePanelURL {
                ExtensionSidePanelBrowser(url: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 360)
        .background {
            ZStack {
                VisualEffectBackground(material: .menu)
                p.background.color.opacity(0.45)
            }
            .ignoresSafeArea()
        }
    }
}

private struct ExtensionSidePanelBrowser: NSViewRepresentable {
    let url: String

    func makeNSView(context: Context) -> SoulBrowserView {
        let view = SoulBrowserView(url: url)
        view.setWebWindowVisible(true)
        return view
    }

    func updateNSView(_ view: SoulBrowserView, context: Context) {
        if view.currentURL != url {
            view.loadURL(url)
        }
        view.setWebWindowVisible(true)
    }

    static func dismantleNSView(_ view: SoulBrowserView, coordinator: ()) {
        view.closeBrowser()
    }
}

/// A lightweight failed-load overlay (e.g. no network / bad host).
private struct ErrorOverlay: View {
    @ObservedObject var tab: BrowserTab
    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 12) {
            Icon(name: "wifi.exclamationmark", size: 40, weight: .light)
                .foregroundStyle(p.mutedForeground.color)
            Text("This page couldn't load")
                .font(Typography.ui(15, weight: .medium))
                .foregroundStyle(p.foreground.color)
            Text(tab.urlString)
                .font(Typography.mono(12))
                .foregroundStyle(p.mutedForeground.color)
                .lineLimit(1)
                .truncationMode(.middle)
            Button {
                tab.reload()
            } label: {
                Text("Reload")
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.primaryForeground.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                            .fill(p.primary.color)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(28)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .fill(p.card.color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
        )
    }
}
