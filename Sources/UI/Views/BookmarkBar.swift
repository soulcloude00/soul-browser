import SwiftUI

/// A persistent bookmarks bar below the toolbar, showing favorite sites as
/// clickable chips. Appears only when the setting is enabled and bookmarks exist.
struct BookmarkBar: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject var bookmarks: BookmarkStore
    @Environment(\.palette) private var p

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(bookmarks.bookmarks) { bookmark in
                    BookmarkChip(bookmark: bookmark) {
                        if let url = URL(string: bookmark.url) {
                            store.navigate(bookmark.url)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 32)
        .background(p.sidebar.color.opacity(0.5))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(p.border.color.opacity(0.3))
                .frame(height: 1)
        }
    }
}

private struct BookmarkChip: View {
    let bookmark: Bookmark
    let action: () -> Void
    @Environment(\.palette) private var p
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                FaviconView(url: bookmark.url, size: 14)
                Text(bookmark.title)
                    .font(Typography.ui(Typography.small, weight: .medium))
                    .foregroundStyle(p.foreground.color)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(hovering ? p.foreground.color.opacity(0.08) : p.card.color.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(p.border.color.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(Motion.state, value: hovering)
    }
}

/// Renders a cached favicon or falls back to a site-letter placeholder.
private struct FaviconView: View {
    let url: String
    let size: CGFloat
    @Environment(\.palette) private var p

    private var faviconURL: URL? {
        guard let host = URL(string: url)?.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
    }

    private var letter: String {
        guard let host = URL(string: url)?.host else { return "?" }
        let name = host.replacingOccurrences(of: "www.", with: "")
        return String(name.prefix(1)).uppercased()
    }

    var body: some View {
        Group {
            if let faviconURL {
                AsyncImage(url: faviconURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else {
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
    }

    private var fallback: some View {
        ZStack {
            Circle().fill(p.primary.color.opacity(0.15))
            Text(letter)
                .font(.system(size: size * 0.6, weight: .bold))
                .foregroundStyle(p.primary.color)
        }
    }
}
