import SwiftUI
import AppKit

/// A Spotlight-style command palette to manage Chrome extensions.
/// Like the LauncherOverlay, this floats above the web content using an NSViewRepresentable
/// so it can take keyboard focus without being swallowed by the CEF browser.
struct ExtensionManagerOverlay: NSViewRepresentable {
    @ObservedObject var store: BrowserStore
    var palette: ThemePalette
    var scheme: ColorScheme

    func makeNSView(context: Context) -> ExtensionManagerContainerView {
        let view = ExtensionManagerContainerView()
        view.update(store: store, palette: palette, scheme: scheme)
        return view
    }

    func updateNSView(_ nsView: ExtensionManagerContainerView, context: Context) {
        nsView.update(store: store, palette: palette, scheme: scheme)
    }
}

final class ExtensionManagerContainerView: NSView {
    private var hosting: NSHostingView<AnyView>?
    private weak var store: BrowserStore?
    private var palette: ThemePalette = .light
    private var scheme: ColorScheme = .light
    private var visible = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        let host = NSHostingView(rootView: AnyView(EmptyView()))
        host.frame = bounds
        host.autoresizingMask = [.width, .height]
        addSubview(host)
        hosting = host
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isFlipped: Bool { true }

    func update(store: BrowserStore, palette: ThemePalette, scheme: ColorScheme) {
        self.store = store
        self.palette = palette
        self.scheme = scheme
        rebuild()

        let nowVisible = store.extensionManagerVisible
        if nowVisible != visible {
            visible = nowVisible
            hosting?.isHidden = !nowVisible
            if nowVisible {
                DispatchQueue.main.async { [weak self] in
                    guard let self, let host = self.hosting else { return }
                    self.window?.makeFirstResponder(host)
                }
            }
        }
    }

    private func rebuild() {
        guard let store else { return }
        hosting?.rootView = AnyView(
            Group {
                if store.extensionManagerVisible {
                    ExtensionManagerView(store: store, scheme: scheme)
                        .environment(\.palette, palette)
                        .frame(width: max(bounds.width, 1),
                               height: max(bounds.height, 1),
                               alignment: .top)
                }
            }
        )
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard store?.extensionManagerVisible == true else { return nil }
        return super.hitTest(point)
    }

    override func layout() {
        super.layout()
        hosting?.frame = bounds
        if visible { rebuild() }
    }
}

private struct ExtensionManagerView: View {
    @ObservedObject var store: BrowserStore
    var scheme: ColorScheme
    @Environment(\.palette) private var p
    @ObservedObject private var extensions = ExtensionStore.shared

    @State private var query = ""
    @State private var highlighted = 0
    @FocusState private var fieldFocused: Bool

    private var items: [BrowserExtension] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            return extensions.extensions
        } else {
            return extensions.extensions.filter {
                $0.name.lowercased().contains(q) || $0.detail.lowercased().contains(q)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { store.dismissExtensionManager() }

            card
                .frame(maxWidth: 620)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            highlighted = 0
            DispatchQueue.main.async { fieldFocused = true }
        }
        .onChange(of: query) { _, _ in highlighted = 0 }
        .onChange(of: items.count) { _, newCount in
            if highlighted >= newCount {
                highlighted = max(0, newCount - 1)
            }
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            header

            Divider()
                .overlay(p.border.color.opacity(0.45))
                .padding(.horizontal, 14)
            
            results
            
            Divider()
                .overlay(p.border.color.opacity(0.45))
            
            footer
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .fill(p.popover.color)
                .shadow(color: .black.opacity(scheme == .dark ? 0.48 : 0.22), radius: 30, y: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.popover, style: .continuous)
                .strokeBorder(p.border.color.opacity(0.5), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: Radius.popover, style: .continuous))
        .onTapGesture {}
        .onKeyPress(.downArrow) { move(1); return .handled }
        .onKeyPress(.upArrow) { move(-1); return .handled }
        .onKeyPress(.escape) { store.dismissExtensionManager(); return .handled }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Icon(name: "puzzlepiece.extension", size: 17, weight: .regular)
                .foregroundStyle(p.primary.color)

            ZStack(alignment: .leading) {
                if query.isEmpty {
                    Text("Search extensions…")
                        .font(Typography.ui(15))
                        .foregroundStyle(p.mutedForeground.color.opacity(0.7))
                }
                TextField("", text: $query)
                    .textFieldStyle(.plain)
                    .font(Typography.ui(15))
                    .foregroundStyle(p.foreground.color)
                    .focused($fieldFocused)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }

    private var results: some View {
        ScrollView {
            if items.isEmpty {
                VStack(spacing: 8) {
                    Icon(name: "puzzlepiece.extension", size: 32)
                        .foregroundStyle(p.mutedForeground.color.opacity(0.5))
                    Text("No extensions found")
                        .font(Typography.ui(14, weight: .medium))
                        .foregroundStyle(p.mutedForeground.color)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 1) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { idx, ext in
                        ExtensionManagerRow(ext: ext, isHighlighted: idx == highlighted, store: extensions)
                            .onHover { if $0 { highlighted = idx } }
                            .onTapGesture {
                                extensions.setEnabled(ext, !ext.enabled)
                            }
                    }
                }
                .padding(6)
            }
        }
        .frame(maxHeight: 5 * 46 + 4 * 1 + 12) // Matches LauncherMetrics max results height
        .scrollIndicators(.never)
    }
    
    private var footer: some View {
        HStack {
            Text("Manage your Chrome extensions and content scripts.")
                .font(Typography.ui(11, weight: .medium))
                .foregroundStyle(p.mutedForeground.color)
            Spacer()
            Button {
                extensions.presentImportPanel()
            } label: {
                HStack(spacing: 4) {
                    Icon(name: "plus", size: 11, weight: .bold)
                    Text("Add Extension")
                        .font(Typography.ui(11, weight: .medium))
                }
                .foregroundStyle(p.foreground.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(p.input.color.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 42)
    }

    private func move(_ delta: Int) {
        guard !items.isEmpty else { return }
        highlighted = (highlighted + delta + items.count) % items.count
    }
}

private struct ExtensionManagerRow: View {
    let ext: BrowserExtension
    let isHighlighted: Bool
    @ObservedObject var store: ExtensionStore
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 10) {
            ExtensionIconView(ext: ext, size: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(ext.name)
                        .font(Typography.ui(13, weight: .medium))
                        .foregroundStyle(p.foreground.color)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if !ext.version.isEmpty {
                        Text("v\(ext.version)")
                            .font(Typography.ui(11))
                            .foregroundStyle(p.mutedForeground.color)
                    }
                }
                
                if !ext.detail.isEmpty {
                    Text(ext.detail)
                        .font(Typography.ui(11))
                        .foregroundStyle(p.mutedForeground.color)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer(minLength: 12)

            Toggle("", isOn: Binding(
                get: { ext.enabled },
                set: { store.setEnabled(ext, $0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .tint(p.primary.color)
            .controlSize(.small)
            
            Button {
                store.remove(ext)
            } label: {
                Icon(name: "trash", size: 13, weight: .regular)
                    .foregroundStyle(p.mutedForeground.color)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help("Remove extension")
        }
        .padding(.horizontal, 10)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHighlighted ? p.accent.color.opacity(0.12) : .clear)
        )
        .contentShape(Rectangle())
    }
}
