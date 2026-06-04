import SwiftUI

/// RSS Reader side panel — browse subscribed feeds and open articles in new tabs.
struct RSSReaderPanel: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject private var reader = PodcastRSSReader.shared
    @Environment(\.palette) private var p
    @State private var newFeedURL = ""
    @State private var selectedFeedID: RSSFeed.ID?

    var body: some View {
        HStack(spacing: 0) {
            feedSidebar
            Divider().opacity(0.3)
            articleList
        }
        .frame(width: 380)
        .background(p.background.color)
    }

    // MARK: — Feed sidebar

    private var feedSidebar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Feeds")
                    .font(Typography.ui(14, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Spacer()
                Button {
                    reader.refreshAll()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(p.accent.color)
                }
                .buttonStyle(.plain)
                .help("Refresh All")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            HStack(spacing: 6) {
                TextField("Feed URL", text: $newFeedURL)
                    .textFieldStyle(.plain)
                    .font(Typography.ui(12))
                    .padding(6)
                    .background(p.input.color.opacity(0.5))
                    .cornerRadius(Radius.md)

                Button {
                    guard !newFeedURL.isEmpty else { return }
                    reader.addFeed(url: newFeedURL)
                    newFeedURL = ""
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(p.accent.color)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)

            if reader.feeds.isEmpty {
                Spacer()
                Text("No feeds")
                    .font(Typography.ui(Typography.small))
                    .foregroundStyle(p.mutedForeground.color)
                Spacer()
            } else {
                List(reader.feeds) { feed in
                    FeedRow(
                        feed: feed,
                        isSelected: selectedFeedID == feed.id,
                        p: p
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFeedID = feed.id
                        reader.refresh(feed: feed)
                    }
                    .contextMenu {
                        Button {
                            reader.removeFeed(id: feed.id)
                            if selectedFeedID == feed.id {
                                selectedFeedID = nil
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(width: 140)
    }

    // MARK: — Article list

    private var articleList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Articles")
                    .font(Typography.ui(14, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Spacer()
                if reader.isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.7)
                }
                Button {
                    store.rssReaderVisible = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(p.mutedForeground.color)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            let articles = selectedFeedID.flatMap { reader.feedItems[$0] } ?? []

            if articles.isEmpty {
                Spacer()
                Text(selectedFeedID == nil ? "Select a feed" : "No articles")
                    .font(Typography.ui(Typography.small))
                    .foregroundStyle(p.mutedForeground.color)
                Spacer()
            } else {
                List(articles) { item in
                    ArticleRow(item: item, p: p)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard !item.link.isEmpty else { return }
                            store.newTab(url: item.link, select: true)
                        }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: — Row views

private struct FeedRow: View {
    let feed: RSSFeed
    let isSelected: Bool
    let p: ThemePalette

    var body: some View {
        HStack(spacing: 6) {
            FaviconImage(urlString: feed.url, size: 16)
            Text(feed.title)
                .font(Typography.ui(11, weight: .medium))
                .foregroundStyle(isSelected ? p.accent.color : p.foreground.color)
                .lineLimit(2)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(isSelected ? p.accent.color.opacity(0.12) : Color.clear)
        .cornerRadius(Radius.md)
    }
}

private struct ArticleRow: View {
    let item: RSSItem
    let p: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(Typography.ui(12, weight: .medium))
                .foregroundStyle(p.foreground.color)
                .lineLimit(2)
            if !item.description.isEmpty {
                Text(item.description)
                    .font(Typography.ui(10))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineLimit(2)
            }
            HStack {
                if item.audioURL != nil {
                    Image(systemName: "headphones")
                        .font(.system(size: 9))
                        .foregroundStyle(p.accent.color)
                }
                Spacer()
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(p.card.color.opacity(0.3))
        .cornerRadius(Radius.md)
    }
}

private struct FaviconImage: View {
    let urlString: String
    let size: CGFloat

    var body: some View {
        if let url = URL(string: urlString),
           let host = url.host,
           let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=32") {
            AsyncImage(url: faviconURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    placeholder
                }
            }
            .frame(width: size, height: size)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Image(systemName: "globe")
            .font(.system(size: size * 0.75))
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
    }
}
