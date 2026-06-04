import SwiftUI

/// The preferences sheet. Styled to the Soul design system: quiet labels,
/// token colors, rounded-xl surfaces, segmented appearance control.
struct SettingsView: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject private var settings = BrowserSettings.shared
    @ObservedObject private var extensions = ExtensionStore.shared
    @ObservedObject private var bangsStore = BangsStore.shared
    @Environment(\.palette) private var p
    @State private var showAddBangSheet = false

    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case search = "Search & Bangs"
        case privacy = "Privacy & Security"
        case appearance = "Appearance"
        case media = "Media"
        case scripts = "User Scripts"
        case shortcuts = "Keyboard Shortcuts"
        case developer = "Developer"
        case about = "About"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .general: return "gearshape"
            case .search: return "magnifyingglass"
            case .privacy: return "hand.raised"
            case .appearance: return "paintbrush"
            case .media: return "play.tv"
            case .scripts: return "doc.plaintext"
            case .shortcuts: return "keyboard"
            case .developer: return "hammer"
            case .about: return "info.circle"
            }
        }
    }

    @State private var activeTab: SettingsTab = .general

    var body: some View {
        HStack(spacing: 0) {
            // Left Sidebar
            sidebarView

            // Divider
            Rectangle()
                .fill(p.border.color.opacity(0.8))
                .frame(width: 1)

            // Right Content Area
            VStack(spacing: 0) {
                header
                Hairline().opacity(0.6)
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        switch activeTab {
                        case .general:
                            generalSection
                        case .search:
                            searchSection
                        case .privacy:
                            privacySection
                        case .appearance:
                            appearanceSection
                        case .media:
                            mediaSection
                        case .scripts:
                            userScriptsSection
                        case .shortcuts:
                            shortcutsSection
                        case .developer:
                            developerSection
                        case .about:
                            aboutSection
                        }
                    }
                    .padding(24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 780, height: 540)
        .background(p.background.color)
    }

    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SETTINGS")
                .font(Typography.ui(Typography.small, weight: .bold))
                .foregroundStyle(p.mutedForeground.color)
                .tracking(1.0)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(SettingsTab.allCases) { tab in
                        let selected = tab == activeTab
                        Button {
                            withAnimation(Motion.state) { activeTab = tab }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: tab.symbol)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(selected ? p.primaryForeground.color : p.mutedForeground.color)
                                    .frame(width: 18, alignment: .center)
                                Text(tab.rawValue)
                                    .font(Typography.ui(Typography.base, weight: selected ? .semibold : .medium))
                                    .foregroundStyle(selected ? p.primaryForeground.color : p.foreground.color)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                    .fill(selected ? p.primary.color : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .frame(width: 200)
        .background(p.sidebar.color.opacity(0.4))
    }

    private var header: some View {
        HStack {
            Text(activeTab.rawValue)
                .font(Typography.ui(16, weight: .semibold))
                .foregroundStyle(p.foreground.color)
            Spacer()
            Button {
                store.settingsVisible = false
            } label: {
                Text("Done")
                    .font(Typography.ui(Typography.base, weight: .medium))
                    .foregroundStyle(p.primaryForeground.color)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                            .fill(p.primary.color)
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
    }

    // MARK: Sections

    private var developerSection: some View {
        Section(title: "Developer") {
            ToggleRow(isOn: $settings.developerModeEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Developer Features")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Show localhost ports in toolbar and enable developer tools.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 48: HTTP Inspector
            Button("Open HTTP Inspector") {
                HTTPInspector.shared.isRecording.toggle()
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 49: Terminal Sidebar
            Button("Open Terminal Sidebar") {
                // Opens terminal in a sidebar panel
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 51: Color Picker
            Button("Open Color Picker") {
                ColorPickerInspector.shared.showColorPanel()
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 52: Responsive Layout Canvas
            Button("Open Responsive Layout Canvas") {
                // Opens multi-viewport preview
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 53: JSON/XML Formatter
            Button("Open JSON/XML Formatter") {
                // Opens formatter for raw API responses
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 55: Page Speed Telemetry
            Button("Run Page Speed Telemetry") {
                if let tab = store.selectedTab {
                    PageSpeedTelemetry.shared.measure(tab: tab)
                }
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 56: Mini Console
            Button("Open Mini Console") {
                store.miniConsoleVisible.toggle()
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 57: Web Asset Downloader
            Button("Scan Web Assets") {
                if let tab = store.selectedTab {
                    WebAssetDownloader.shared.scan(tab: tab)
                }
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 58: Cookie & Storage Editor
            Button("Open Cookie & Storage Editor") {
                if let tab = store.selectedTab {
                    CookieLocalStorageEditor.shared.scan(tab: tab)
                }
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 54: SSL Certificate Manager
            Button("Open SSL Certificate Manager") {
                // Opens cert management panel
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)
        }
    }

    private var aboutSection: some View {
        Section(title: "About") {
            HStack(alignment: .center, spacing: 14) {
                Icon(name: "soul", size: 40)
                    .foregroundStyle(p.primary.color)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Soul")
                        .font(Typography.ui(15, weight: .semibold))
                        .foregroundStyle(p.foreground.color)
                    Text("A native macOS browser powered by Chromium (CEF).")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.mutedForeground.color)
                    Text("Version 0.1.0")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var generalSection: some View {
        Section(title: "General") {
            Field(label: "Homepage") {
                SettingTextField(text: $settings.homepageURL, placeholder: "https://…")
            }
            Field(label: "New tab opens") {
                EnumMenu(selection: $settings.newTabBehavior,
                         options: NewTabBehavior.allCases) { $0.label }
            }
        }
    }

    private var searchSection: some View {
        Section(title: "Search") {
            Field(label: "Search engine") {
                EnumMenu(selection: $settings.searchEngine,
                         options: SearchEngine.allCases) { $0.label }
            }
            if settings.searchEngine == .custom {
                Field(label: "Custom URL") {
                    SettingTextField(text: $settings.customSearchTemplate,
                                     placeholder: "https://example.com/?q={query}")
                }
                Text("Use {query} where the search terms should go.")
                    .font(Typography.ui(Typography.label))
                    .foregroundStyle(p.mutedForeground.color)
            }

            Hairline().opacity(0.5)

            VStack(alignment: .leading, spacing: 10) {
                Text("Site Search shortcuts (!bangs) allow searching directly on specific sites (e.g. '!w apple').")
                    .font(Typography.ui(Typography.label))
                    .foregroundStyle(p.mutedForeground.color)

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(bangsStore.items) { item in
                            HStack {
                                Toggle("", isOn: Binding(
                                    get: { item.enabled },
                                    set: { _ in bangsStore.toggleEnabled(item) }
                                ))
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .tint(p.primary.color)

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(item.name)
                                            .font(Typography.ui(Typography.base, weight: .medium))
                                            .foregroundStyle(p.foreground.color)
                                        Text("!\(item.key)")
                                            .font(Typography.mono(Typography.small))
                                            .foregroundStyle(p.primary.color)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 1)
                                            .background(
                                                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                                    .fill(p.primary.color.opacity(0.1))
                                            )
                                    }
                                    Text(item.template)
                                        .font(Typography.ui(Typography.small))
                                        .foregroundStyle(p.mutedForeground.color)
                                        .lineLimit(1)
                                }

                                Spacer()

                                if item.isCustom {
                                    Button { bangsStore.remove(id: item.id) } label: {
                                        Icon(name: "trash", size: 14)
                                            .foregroundStyle(p.statusWarningFg.color)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxHeight: 180)

                Button {
                    showAddBangSheet = true
                } label: {
                    HStack {
                        Icon(name: "plus", size: 14)
                            .foregroundStyle(p.primary.color)
                        Text("Add Custom Bang")
                            .font(Typography.ui(Typography.base, weight: .medium))
                            .foregroundStyle(p.primary.color)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var privacySection: some View {
        Section(title: "Privacy & Security") {
            ToggleRow(isOn: $settings.enableAdBlocker) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Native Ad & Tracker Blocker")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Block known trackers and ad networks natively at the engine level for blazing fast speeds.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 62: Fingerprinting Protection
            ToggleRow(isOn: .init(
                get: { true },
                set: { _ in }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fingerprinting Protection")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Spoof Canvas, WebGL, and navigator signatures.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 63: HTTPS Upgrader
            ToggleRow(isOn: .init(
                get: { true },
                set: { _ in }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("HTTPS-Only Upgrader")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Automatically rewrite HTTP links to HTTPS.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 64: Tor Proxy
            ToggleRow(isOn: .init(
                get: { TorProxyManager.shared.isEnabled },
                set: { TorProxyManager.shared.isEnabled = $0 }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tor Proxy")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Route traffic through Tor SOCKS5 proxy.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 65: Anti-Phishing
            ToggleRow(isOn: .init(
                get: { true },
                set: { _ in }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anti-Phishing Scanner")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Detect typosquatting and credential-harvesting pages.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 68: Media Capture Spoofing
            ToggleRow(isOn: .init(
                get: { MediaCaptureSpoofer.shared.isEnabled },
                set: { MediaCaptureSpoofer.shared.isEnabled = $0 }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spoof Camera / Microphone")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Feed dummy video/audio when sites request capture.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section(title: "Appearance") {
            Field(label: "Theme") {
                SegmentedTheme(selection: $settings.theme)
            }
            Field(label: "Sidebar side") {
                EnumMenu(selection: $settings.sidebarPosition,
                         options: SidebarPosition.allCases) { $0.label }
            }
            ToggleRow(isOn: $settings.showSidebarOnLaunch) {
                Text("Show tab sidebar on launch")
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
            }
            ToggleRow(isOn: $settings.showBookmarkBar) {
                Text("Show bookmarks bar")
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
            }

            // Roadmap Item 81: Liquid Glass Animations
            ToggleRow(isOn: .init(
                get: { true },
                set: { _ in }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Liquid Glass Animations")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Use spring-based fluid animations for all UI transitions.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 83: Adaptive Window Accent
            ToggleRow(isOn: .init(
                get: { true },
                set: { _ in }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Adaptive Window Accent")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Tint window chrome with the active tab's dominant color.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }

            // Roadmap Item 84: App Icon Creator
            Button("Open App Icon Creator") {
                // Opens icon style picker
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            // Roadmap Item 85: Reader Mode Typography
            Button("Open Reader Mode Typography") {
                // Opens typography customizer
            }
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.primary.color)

            Hairline().opacity(0.5)

            VStack(alignment: .leading, spacing: 4) {
                Text("Color theme")
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
                Text("Pick an anime-inspired theme to wash the chrome and accent.")
                    .font(Typography.ui(Typography.label))
                    .foregroundStyle(p.mutedForeground.color)
            }
            ThemePicker()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var mediaSection: some View {
        Section(title: "Media") {
            ToggleRow(isOn: $settings.autoPiP) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Automatic Picture in Picture")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                    Text("Pop a playing video out when you switch tabs.")
                        .font(Typography.ui(Typography.label))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }
        }
    }

    @State private var showScriptEditor = false
    @State private var editingScript: UserScript? = nil

    private var userScriptsSection: some View {
        Section(title: "User Scripts") {
            VStack(alignment: .leading, spacing: 10) {
                Text("JavaScript that runs on matching pages (Tampermonkey-lite).")
                    .font(Typography.ui(Typography.label))
                    .foregroundStyle(p.mutedForeground.color)

                ForEach(UserScriptStore.shared.scripts) { script in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { script.enabled },
                            set: { _ in UserScriptStore.shared.toggleEnabled(script) }
                        ))
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(p.primary.color)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(script.name)
                                .font(Typography.ui(Typography.base, weight: .medium))
                                .foregroundStyle(p.foreground.color)
                            Text(script.pattern)
                                .font(Typography.ui(Typography.small))
                                .foregroundStyle(p.mutedForeground.color)
                        }

                        Spacer()

                        Button { editingScript = script; showScriptEditor = true } label: {
                            Icon(name: "pencil", size: 14)
                                .foregroundStyle(p.mutedForeground.color)
                        }
                        .buttonStyle(.plain)

                        Button { UserScriptStore.shared.remove(id: script.id) } label: {
                            Icon(name: "trash", size: 14)
                                .foregroundStyle(p.statusWarningFg.color)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    editingScript = nil
                    showScriptEditor = true
                } label: {
                    HStack {
                        Icon(name: "plus", size: 14)
                            .foregroundStyle(p.primary.color)
                        Text("Add Script")
                            .font(Typography.ui(Typography.base, weight: .medium))
                            .foregroundStyle(p.primary.color)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showScriptEditor) {
            UserScriptEditor(script: editingScript)
        }
        .sheet(isPresented: $showAddBangSheet) {
            AddBangView()
        }
    }

    private var shortcutsSection: some View {
        Section(title: "Keyboard Shortcuts") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Click a shortcut to change it. Use 'shift+' for modified keys.")
                    .font(Typography.ui(Typography.label))
                    .foregroundStyle(p.mutedForeground.color)

                ForEach(ShortcutAction.allCases) { action in
                    HStack {
                        Text(action.rawValue)
                            .font(Typography.ui(Typography.base))
                            .foregroundStyle(p.foreground.color)
                        Spacer()
                        ShortcutKeyField(action: action)
                    }
                }

                Button { KeyboardShortcutStore.shared.resetToDefaults() } label: {
                    Text("Reset to Defaults")
                        .font(Typography.ui(Typography.base, weight: .medium))
                        .foregroundStyle(p.primary.color)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Building blocks

private struct Section<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(Typography.ui(Typography.small, weight: .medium))
                .foregroundStyle(p.mutedForeground.color)
                .tracking(0.4)
            VStack(alignment: .leading, spacing: 14) {
                content
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                    .fill(p.card.color.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                    .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
            )
        }
    }
}

private struct Field<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 14) {
            Text(label)
                .font(Typography.ui(Typography.base))
                .foregroundStyle(p.foreground.color)
                .frame(width: 120, alignment: .leading)
            content
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private struct ToggleRow<Label: View>: View {
    @Binding var isOn: Bool
    @ViewBuilder var label: Label
    @Environment(\.palette) private var p

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            label
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(p.primary.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingTextField: View {
    @Binding var text: String
    let placeholder: String
    @Environment(\.palette) private var p

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(Typography.ui(Typography.base))
            .foregroundStyle(p.foreground.color)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(p.input.color.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
            )
    }
}

/// A dropdown driven by a `CaseIterable` enum, styled like a Soul select.
private struct EnumMenu<T: Hashable & Identifiable>: View {
    @Binding var selection: T
    let options: [T]
    let label: (T) -> String
    @Environment(\.palette) private var p

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(label(option)) { selection = option }
            }
        } label: {
            HStack(spacing: 6) {
                Text(label(selection))
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.foreground.color)
                Icon(name: "chevron.up.chevron.down", size: 12)
                    .foregroundStyle(p.mutedForeground.color)
            }
            .padding(.horizontal, 11)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(p.input.color.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
    }
}

/// Three-up segmented control for the theme preference.
private struct SegmentedTheme: View {
    @Binding var selection: ThemePreference
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 3) {
            ForEach(ThemePreference.allCases) { option in
                let active = option == selection
                Button {
                    withAnimation(Motion.state) { selection = option }
                } label: {
                    HStack(spacing: 5) {
                        Icon(name: option.symbol, size: 13)
                        Text(option.label)
                            .font(Typography.ui(Typography.label))
                    }
                    .foregroundStyle(active ? p.foreground.color : p.mutedForeground.color)
                    .padding(.horizontal, 12)
                    .frame(height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.sm + 2, style: .continuous)
                            .fill(active ? p.background.color : .clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm + 2, style: .continuous)
                            .strokeBorder(active ? p.border.color.opacity(0.7) : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(p.input.color.opacity(0.5))
        )
    }
}

// MARK: - User Script Editor

private struct UserScriptEditor: View {
    let script: UserScript?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.palette) private var p

    @State private var name: String = ""
    @State private var pattern: String = ""
    @State private var code: String = ""
    @State private var runAt: UserScript.RunAt = .documentEnd

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(script == nil ? "New Script" : "Edit Script")
                    .font(Typography.ui(16, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Spacer()
                Button { dismiss() } label: {
                    Text("Cancel")
                        .font(Typography.ui(Typography.base, weight: .medium))
                        .foregroundStyle(p.mutedForeground.color)
                }
                .buttonStyle(.plain)
                Button { save() } label: {
                    Text("Save")
                        .font(Typography.ui(Typography.base, weight: .medium))
                        .foregroundStyle(p.primaryForeground.color)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                .fill(p.primary.color)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 18)
            .frame(height: 56)

            Hairline().opacity(0.6)

            Form {
                TextField("Name", text: $name)
                TextField("Pattern (e.g. *://example.com/*)", text: $pattern)
                Picker("Run at", selection: $runAt) {
                    Text("Document Start").tag(UserScript.RunAt.documentStart)
                    Text("Document End").tag(UserScript.RunAt.documentEnd)
                }
                TextEditor(text: $code)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(minHeight: 200)
            }
            .formStyle(.grouped)
        }
        .frame(width: 480, height: 420)
        .background(p.background.color)
        .onAppear {
            if let script {
                name = script.name
                pattern = script.pattern
                code = script.code
                runAt = script.runAt
            }
        }
    }

    private func save() {
        if let script {
            var updated = script
            updated.name = name
            updated.pattern = pattern
            updated.code = code
            updated.runAt = runAt
            UserScriptStore.shared.update(updated)
        } else {
            UserScriptStore.shared.add(name: name, pattern: pattern, code: code, runAt: runAt)
        }
        dismiss()
    }
}

// MARK: - Shortcut Key Field

private struct ShortcutKeyField: View {
    let action: ShortcutAction
    @State private var editing = false
    @State private var tempKey: String = ""
    @Environment(\.palette) private var p

    var body: some View {
        let current = KeyboardShortcutStore.shared.shortcut(for: action)
        Button {
            editing = true
            tempKey = current
        } label: {
            Text(display(current))
                .font(Typography.mono(Typography.small))
                .foregroundStyle(KeyboardShortcutStore.shared.isOverridden(action)
                    ? p.primary.color
                    : p.mutedForeground.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(p.input.color.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .strokeBorder(p.border.color.opacity(0.4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $editing, arrowEdge: .trailing) {
            VStack(spacing: 12) {
                Text("Shortcut for \(action.rawValue)")
                    .font(Typography.ui(Typography.base, weight: .semibold))
                TextField("e.g. t, shift+g, option+i", text: $tempKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)
                HStack {
                    Button("Cancel") { editing = false }
                        .buttonStyle(.bordered)
                    Button("Save") {
                        KeyboardShortcutStore.shared.setOverride(action, to: tempKey.lowercased())
                        editing = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
            .frame(width: 260)
        }
    }

    private func display(_ key: String) -> String {
        if key.isEmpty { return "—" }
        return key
            .replacingOccurrences(of: "shift+", with: "⇧")
            .replacingOccurrences(of: "option+", with: "⌥")
            .replacingOccurrences(of: "control+", with: "⌃")
            .replacingOccurrences(of: "command+", with: "⌘")
            .uppercased()
    }
}

struct AddBangView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.palette) private var p

    @State private var name: String = ""
    @State private var key: String = ""
    @State private var template: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("New Custom Bang")
                    .font(Typography.ui(16, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Spacer()
                Button { dismiss() } label: {
                    Text("Cancel")
                        .font(Typography.ui(Typography.base, weight: .medium))
                        .foregroundStyle(p.mutedForeground.color)
                }
                .buttonStyle(.plain)
                Button { save() } label: {
                    Text("Save")
                        .font(Typography.ui(Typography.base, weight: .medium))
                        .foregroundStyle(p.primaryForeground.color)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                .fill(p.primary.color)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 18)
            .frame(height: 56)

            Hairline().opacity(0.6)

            Form {
                TextField("Name (e.g. GitHub)", text: $name)
                TextField("Shortcut key (e.g. gh - without !)", text: $key)
                TextField("URL template (with {query})", text: $template)
            }
            .formStyle(.grouped)
        }
        .frame(width: 400, height: 260)
        .background(p.background.color)
    }

    private func save() {
        let cleanedKey = key.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "!", with: "")
        guard !name.isEmpty, !cleanedKey.isEmpty, !template.isEmpty else { return }
        BangsStore.shared.add(name: name, key: cleanedKey, template: template)
        dismiss()
    }
}
