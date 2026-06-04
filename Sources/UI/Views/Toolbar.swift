import SwiftUI

/// A fixed hairline strip atop the web content: its 4pt height plus the card's
/// 4pt top padding makes the top gap match the 8pt inset on the card's other
/// edges. Acts as the window drag area and shows the page-load progress bar. The
/// revealed titlebar (traffic lights + a slim bar) is handled separately by
/// `TopChromeOverlay`, which floats over the page rather than resizing it.
struct WebTopStrip: View {
    var tab: BrowserTab?

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 4)
        .background {
            // Empty background — the unified chrome surface is set on the root.
            Color.clear
        }
        .overlay(alignment: .bottom) {
            // No hairline here — the floating card's border frames the content.
            if let tab, tab.isLoading {
                LoadingBar()
                    .transition(.opacity)
                    .animation(Motion.state, value: tab.isLoading)
            }
        }
    }
}

/// A slim indeterminate progress bar shown while a page loads. A primary-tinted
/// segment sweeps left→right; respects reduced-motion by holding still.
struct LoadingBar: View {
    @Environment(\.palette) private var p
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let segment = max(120, w * 0.28)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [p.primary.color.opacity(0), p.primary.color, p.primary.color.opacity(0)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: segment, height: 2.5)
                .offset(x: reduceMotion ? (w - segment) / 2 : phase * (w + segment) - segment)
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        }
        .frame(height: 2.5)
    }
}

/// The address/search field. Shows the page URL when idle; full editable text
/// when focused.
struct Omnibox: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject var tab: BrowserTab
    @ObservedObject private var extensions = ExtensionStore.shared

    @Environment(\.palette) private var p
    @ObservedObject private var settings = BrowserSettings.shared
    @FocusState private var focused: Bool
    @State private var editText: String = ""
    @State private var suggestions: [HistoryEntry] = []
    @State private var highlighted: Int? = nil

    private var showSuggestions: Bool {
        focused && !editText.isEmpty && !suggestions.isEmpty
            && editText != tab.displayURL
    }

    var body: some View {
        omniboxContent
            .padding(.horizontal, 11)
            .frame(height: 30)
            .background(omniboxBackground)
            .overlay(omniboxBorder)
        // Autocomplete dropdown, floated just below the field.
        .overlay(alignment: .topLeading) {
            if showSuggestions {
                OmniboxSuggestionsList(
                    suggestions: suggestions,
                    highlighted: highlighted,
                    onPick: { commit($0.url) }
                )
                .offset(y: 36)
                .transition(.opacity)
            }
        }
        .animation(Motion.state, value: focused)
        .onAppear { editText = tab.displayURL }
        .onChange(of: focused) { _, now in
            if now {
                DispatchQueue.main.async { selectAll() }
                refreshSuggestions()
            } else {
                // Snap back to the canonical URL when focus leaves.
                editText = tab.displayURL
                suggestions = []
            }
        }
        .onChange(of: editText) { _, _ in
            highlighted = nil
            refreshSuggestions()
        }
        .onChange(of: tab.urlString) { _, _ in
            if !focused { editText = tab.displayURL }
        }
        .onChange(of: tab.id) { _, _ in
            editText = tab.displayURL
        }
        .onReceive(NotificationCenter.default.publisher(for: .soulFocusOmnibox)) { _ in
            focused = true
        }
    }

    private var omniboxContent: some View {
        HStack(spacing: 7) {
            Icon(name: secureGlyph, size: 13, weight: .regular)
                .foregroundStyle(secureColor)

            ZStack(alignment: .leading) {
                if editText.isEmpty {
                    Text("Search or enter address")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.mutedForeground.color.opacity(0.7))
                }
                TextField("", text: $editText)
                    .textFieldStyle(.plain)
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
                    .lineLimit(1)
                    .focused($focused)
                    .onSubmit(submit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let id = ExtensionStore.webStoreExtensionID(from: tab.urlString), !focused {
                AddExtensionButton(installing: extensions.installingIDs.contains(id)) {
                    extensions.beginWebStoreInstall(extensionID: id)
                }
            }

            if !focused {
                if settings.developerModeEnabled {
                    MatrixModeButton(tab: tab)
                    LocalhostMenu(tab: tab, store: store)
                }
                PageActionsMenu(tab: tab, store: store)
                ExtensionToolbarItems(store: store)
            }

            if tab.isLoading {
                ProgressView().controlSize(.small).scaleEffect(0.55)
            }
        }
    }

    private var omniboxBackground: some View {
        Group {
            if focused {
                RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                    .fill(p.background.color)
            } else {
                Color.clear.liquidGlass(cornerRadius: Radius.button)
            }
        }
    }

    private var omniboxBorder: some View {
        RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
            .strokeBorder(focused ? p.ring.color.opacity(0.55) : p.border.color.opacity(0.35),
                          lineWidth: focused ? 1.5 : 1)
    }

    private func refreshSuggestions() {
        guard focused, editText != tab.displayURL else { suggestions = []; return }
        suggestions = HistoryStore.shared.suggestions(for: editText, limit: 6)
    }

    private var secureGlyph: String {
        switch tab.urlScheme {
        case "https": return "lock.fill"
        case "http": return "exclamationmark.triangle"
        default: return "magnifyingglass"
        }
    }

    private var secureColor: Color {
        switch tab.urlScheme {
        case "https": return p.mutedForeground.color
        case "http": return p.statusWarningFg.color
        default: return p.mutedForeground.color
        }
    }

    private func submit() {
        // A highlighted suggestion wins; otherwise treat the text as URL/search.
        if let i = highlighted, suggestions.indices.contains(i) {
            commit(suggestions[i].url)
            return
        }
        let text = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        store.navigate(text)
        suggestions = []
        focused = false
    }

    /// Navigate straight to a chosen suggestion URL.
    private func commit(_ url: String) {
        store.navigate(url)
        editText = url
        suggestions = []
        focused = false
    }

    private func selectAll() {
        if let editor = NSApp.keyWindow?.firstResponder as? NSTextView {
            editor.selectAll(nil)
        }
    }
}

struct PrivacyShieldButton: View {
    @ObservedObject var tab: BrowserTab
    @State private var showDashboard = false
    @Environment(\.palette) private var p
    @ObservedObject private var settings = BrowserSettings.shared

    private var isException: Bool {
        guard let host = URL(string: tab.urlString)?.host?.lowercased() else { return false }
        return settings.adBlockExceptions.contains(host)
    }

    var body: some View {
        Button {
            showDashboard.toggle()
        } label: {
            HStack(spacing: 4) {
                Icon(name: "shield.fill", size: 13, weight: .regular)
                if !tab.blockedTrackers.isEmpty && !isException {
                    Text("\(tab.blockedTrackers.count)")
                        .font(Typography.ui(Typography.small, weight: .bold))
                }
            }
            .foregroundStyle(isException ? p.mutedForeground.color : p.statusWarningFg.color)
            .padding(.horizontal, 6)
            .frame(height: 22)
            .background(
                Capsule().fill(isException ? p.mutedForeground.color.opacity(0.1) : p.statusWarningFg.color.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showDashboard, arrowEdge: .bottom) {
            PrivacyDashboardPopover(tab: tab)
        }
    }
}

/// The "Add to Soul" pill shown inside the omnibox on a Chrome Web Store
/// detail page. Tapping it downloads and installs the extension into Soul.
private struct AddExtensionButton: View {
    let installing: Bool
    let action: () -> Void
    @Environment(\.palette) private var p

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if installing {
                    ProgressView().controlSize(.small).scaleEffect(0.5)
                        .frame(width: 11, height: 11)
                } else {
                    Icon(name: "puzzlepiece.extension.fill", size: 11, weight: .semibold)
                }
                Text(installing ? "Adding…" : "Add to Soul")
                    .font(Typography.ui(Typography.small, weight: .medium))
            }
            .foregroundStyle(p.primaryForeground.color)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(
                Capsule().fill(p.primary.color.opacity(installing ? 0.6 : 1))
            )
        }
        .buttonStyle(.plain)
        .disabled(installing)
        .help("Install this extension in Soul")
    }
}

/// The omnibox autocomplete dropdown: history matches for what's been typed.
private struct OmniboxSuggestionsList: View {
    let suggestions: [HistoryEntry]
    let highlighted: Int?
    let onPick: (HistoryEntry) -> Void

    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 1) {
            ForEach(Array(suggestions.enumerated()), id: \.element.id) { idx, entry in
                SuggestionRow(entry: entry, isHighlighted: idx == highlighted) {
                    onPick(entry)
                }
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .fill(p.popover.color)
                .shadow(color: .black.opacity(0.22), radius: 16, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
        )
    }
}

private struct SuggestionRow: View {
    let entry: HistoryEntry
    let isHighlighted: Bool
    let action: () -> Void

    @Environment(\.palette) private var p
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Icon(name: "clock.arrow.circlepath", size: 14, weight: .regular)
                    .foregroundStyle(p.mutedForeground.color)
                    .frame(width: 16)
                Text(entry.title.isEmpty ? entry.url : entry.title)
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(prettyHost)
                    .font(Typography.ui(Typography.small))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineLimit(1)
            }
            .padding(.horizontal, 9)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(isHighlighted || hovering ? p.accent.color.opacity(0.7) : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }

    private var prettyHost: String {
        URL(string: entry.url)?.host ?? ""
    }
}

/// Removed — was swallowing all mouseDown events across the entire web content
/// column because `.ignoresSafeArea()` on the background made it fill the full
/// parent bounds. Native `movableByWindowBackground = YES` on the window
/// provides the same drag-from-toolbar behaviour without blocking clicks.

/// A button that toggles the Responsive Device Matrix.
private struct MatrixModeButton: View {
    @ObservedObject var tab: BrowserTab
    @Environment(\.palette) private var p
    @State private var isHovering = false

    var body: some View {
        Button(action: {
            tab.isMatrixMode.toggle()
            if tab.isMatrixMode {
                tab.tabletBrowserView.loadURL(tab.displayURL)
                tab.mobileBrowserView.loadURL(tab.displayURL)
            }
        }) {
            Icon(name: "ipad.and.iphone", size: 14, weight: .medium)
                .foregroundStyle(tab.isMatrixMode ? p.primary.color : p.mutedForeground.color)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tab.isMatrixMode ? p.primary.color.opacity(0.15) : (isHovering ? p.foreground.color.opacity(0.08) : .clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help("Toggle Responsive Device Matrix")
    }
}

/// A button that toggles Article Reader Mode.
struct ReaderModeButton: View {
    @ObservedObject var tab: BrowserTab
    @Environment(\.palette) private var p
    @State private var isHovering = false

    var body: some View {
        Button(action: {
            tab.toggleReaderMode()
        }) {
            Icon(name: tab.isReaderMode ? "book.fill" : "book", size: 14, weight: .semibold)
                .foregroundStyle(tab.isReaderMode ? p.primary.color : p.mutedForeground.color)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tab.isReaderMode ? p.primary.color.opacity(0.15) : (isHovering ? p.foreground.color.opacity(0.08) : .clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help("Toggle Reader Mode")
    }
}

/// A button that triggers AI summarization of the current page.
struct AISummarizeButton: View {
    @ObservedObject var tab: BrowserTab
    @Environment(\.palette) private var p
    @State private var isHovering = false
    @State private var isSummarizing = false
    @State private var summaryText: String?
    @State private var showPopover = false

    var body: some View {
        Button(action: summarize) {
            Icon(name: "sparkles", size: 14, weight: .semibold)
                .foregroundStyle(isSummarizing ? p.accent.color : p.mutedForeground.color)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isHovering ? p.foreground.color.opacity(0.08) : .clear)
                )
                .overlay {
                    if isSummarizing {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help("AI Summarize Page")
        .popover(isPresented: $showPopover, arrowEdge: .bottom) {
            if let summary = summaryText {
                AISummaryPopover(text: summary, palette: p)
            }
        }
    }

    private func summarize() {
        guard !isSummarizing else { return }
        isSummarizing = true
        let js = "document.body.innerText.substring(0, 8000)"
        tab.browserView.evaluateJavaScript(js) { result, _ in
            let text = (result as? String) ?? ""
            ReaderModeAI.shared.summarize(html: text) { summary in
                DispatchQueue.main.async {
                    self.isSummarizing = false
                    self.summaryText = summary
                    self.showPopover = true
                }
            }
        }
    }
}

private struct AISummaryPopover: View {
    let text: String
    let palette: ThemePalette

    var body: some View {
        ScrollView {
            Text(text)
                .font(Typography.ui(Typography.base))
                .foregroundStyle(palette.foreground.color)
                .padding(16)
                .frame(width: 320, alignment: .leading)
        }
        .frame(maxHeight: 300)
        .background(palette.popover.color)
    }
}

/// A button that bookmarks the current page.
struct BookmarkButton: View {
    @ObservedObject var tab: BrowserTab
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p
    @State private var isHovering = false

    private var isBookmarked: Bool {
        BookmarkStore.shared.bookmarks.contains(where: { $0.url == tab.urlString })
    }

    var body: some View {
        Button(action: {
            store.bookmarkCurrentPage()
        }) {
            Icon(name: isBookmarked ? "star.fill" : "star", size: 14, weight: .semibold)
                .foregroundStyle(isBookmarked ? p.primary.color : (isHovering ? p.foreground.color : p.mutedForeground.color))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isBookmarked ? p.primary.color.opacity(0.15) : (isHovering ? p.foreground.color.opacity(0.08) : .clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help(isBookmarked ? "Page is bookmarked" : "Add Bookmark")
    }
}

/// A single "⋯" menu that bundles page-level actions so the omnibox stays
/// spacious and the URL remains readable.
private struct PageActionsMenu: View {
    @ObservedObject var tab: BrowserTab
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p
    @State private var isHovering = false
    @State private var showMenu = false

    private var isBookmarked: Bool {
        BookmarkStore.shared.bookmarks.contains(where: { $0.url == tab.urlString })
    }

    var body: some View {
        Button {
            showMenu.toggle()
        } label: {
            Icon(name: "ellipsis", size: 14, weight: .semibold)
                .foregroundStyle(isHovering ? p.foreground.color : p.mutedForeground.color)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isHovering ? p.foreground.color.opacity(0.08) : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help("Page actions")
        .popover(isPresented: $showMenu, arrowEdge: .bottom) {
            PageActionsPopover(tab: tab, store: store, isBookmarked: isBookmarked)
        }
    }
}

private struct PageActionsPopover: View {
    @ObservedObject var tab: BrowserTab
    @ObservedObject var store: BrowserStore
    let isBookmarked: Bool
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = BrowserSettings.shared

    private var isException: Bool {
        guard let host = URL(string: tab.urlString)?.host?.lowercased() else { return false }
        return settings.adBlockExceptions.contains(host)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ActionRow(
                icon: isBookmarked ? "star.fill" : "star",
                label: isBookmarked ? "Bookmarked" : "Add Bookmark",
                isActive: isBookmarked
            ) {
                store.bookmarkCurrentPage()
                dismiss()
            }

            ActionRow(
                icon: tab.isReaderMode ? "book.fill" : "book",
                label: "Reader Mode",
                isActive: tab.isReaderMode
            ) {
                tab.toggleReaderMode()
                dismiss()
            }

            Divider().padding(.horizontal, 8)

            ActionRow(
                icon: "shield.fill",
                label: isException ? "Shield (exception)" : (tab.blockedTrackers.isEmpty ? "No trackers blocked" : "\(tab.blockedTrackers.count) trackers blocked"),
                tint: isException ? p.mutedForeground.color : p.statusWarningFg.color
            ) {
                dismiss()
            }
        }
        .padding(.vertical, 6)
        .frame(width: 200)
        .background(p.popover.color)
        .clipShape(RoundedRectangle(cornerRadius: Radius.popover, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
        )
    }
}

private struct ActionRow: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    var tint: Color? = nil
    let action: () -> Void
    @Environment(\.palette) private var p
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Icon(name: icon, size: 14, weight: .semibold)
                    .foregroundStyle(tint ?? (isActive ? p.primary.color : p.foreground.color))
                Text(label)
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(hovering ? p.accent.color.opacity(0.5) : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
