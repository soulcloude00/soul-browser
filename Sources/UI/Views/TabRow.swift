import SwiftUI

/// A single vertical tab row: a selected tab is a translucent white fill lifted
/// by a soft shadow (no border), at rest it is transparent, hover is a quiet
/// overlay. Close button reveals on hover.
///
/// Selection uses a plain `.onTapGesture` rather than a `Button` or a
/// `DragGesture`-based press effect on purpose: the sidebar attaches `.onDrag`
/// to this row, and a `DragGesture(minimumDistance:)` (or, on some macOS
/// versions, a `Button`) claims the pointer first and stops SwiftUI's `.onDrag`
/// from ever starting a drag session — which is what broke sidebar
/// drag-and-drop. A tap gesture coexists cleanly with `.onDrag`.
struct TabRow: View {
    @ObservedObject var tab: BrowserTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    var depth: Int = 0
    var hasChildren: Bool = false
    var media: MediaController? = nil

    @Environment(\.palette) private var p
    @Environment(\.colorScheme) private var scheme
    @State private var hovering = false

    private var isAudible: Bool {
        guard let media, tab.hasRealized else { return false }
        return media.isMediaAudible(browserId: Int(tab.browserView.browserIdentifier))
    }

    private var isMuted: Bool {
        guard let media, tab.hasRealized else { return false }
        return media.isMediaMuted(browserId: Int(tab.browserView.browserIdentifier))
    }

    var body: some View {
        HStack(spacing: 8) {
            if hasChildren {
                Button(action: { 
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        tab.isCollapsed.toggle() 
                    }
                }) {
                    Image(systemName: tab.isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(p.mutedForeground.color.opacity(0.8))
                        .frame(width: 14, height: 14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else if depth > 0 {
                Spacer().frame(width: 14)
            }

            Favicon(icon: tab.faviconURL, page: tab.urlString,
                    isLoading: tab.isLoading, size: 15,
                    active: isSelected || hovering)

            if tab.isSuspended {
                Text("💤")
                    .font(.system(size: 9))
                    .opacity(0.6)
            }

            if tab.splitTabID != nil {
                Image(systemName: "rectangle.split.2x1")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(isSelected ? p.sidebarForeground.color : p.mutedForeground.color)
                    .opacity(0.8)
            }

            Text(tab.title)
                .font(Typography.ui(Typography.base))
                .foregroundStyle(isSelected ? p.sidebarForeground.color
                                            : p.sidebarForeground.color.opacity(0.78))
                .opacity(tab.isSuspended ? 0.6 : 1.0)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 0)

            if isAudible || isMuted {
                Button {
                    if let media, tab.hasRealized {
                        media.toggleMuteForTab(browserId: Int(tab.browserView.browserIdentifier))
                    }
                } label: {
                    Icon(name: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                         size: 11, weight: .medium)
                        .foregroundStyle(isMuted ? p.mutedForeground.color : p.primary.color)
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(isMuted ? "Unmute tab" : "Mute tab")
            }

            if hovering || isSelected {
                Button(action: onClose) {
                    Icon(name: "xmark", size: 11, weight: .bold)
                        .foregroundStyle(p.mutedForeground.color)
                        .frame(width: 18, height: 18)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(hovering ? p.sidebarForeground.color.opacity(0.10) : .clear)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Close tab")
            }
        }
        .padding(.horizontal, 9)
        .padding(.leading, CGFloat(depth * 12))
        .frame(height: 34)
        .background(
            RoundedRectangle(cornerRadius: TabSurface.radius, style: .continuous)
                .fill(backgroundFill)
                .shadow(color: isSelected ? TabSurface.shadow(scheme) : .clear,
                        radius: isSelected ? TabSurface.shadowRadius : 0,
                        x: 0, y: isSelected ? TabSurface.shadowY : 0)
        )
        .overlay(alignment: .leading) {
            if isSelected {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(tab.dominantColor.opacity(0.8))
                    .frame(width: 3, height: 18)
                    .padding(.leading, 2)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay(alignment: .leading) {
            if depth > 0 {
                TreeGuidelines(depth: depth)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .onHover { hovering = $0 }
        .scaleEffect(hovering && !isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: hovering)
        .animation(Motion.state, value: isSelected)
    }

    private var backgroundFill: Color {
        if isSelected { return TabSurface.selectedFill(scheme) }
        if hovering { return TabSurface.hoverFill(scheme) }
        return .clear
    }
}

struct TreeGuidelines: View {
    let depth: Int
    @Environment(\.palette) private var p
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<depth, id: \.self) { d in
                Spacer()
                    .frame(width: 12)
                Rectangle()
                    .fill(p.sidebarForeground.color.opacity(0.15))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 12)
    }
}

