import Foundation

/// Offline Podcast & RSS Reader Sidebar (Roadmap Item 106)
/// Parse feed structures locally and present a gorgeous SwiftUI feed reader
/// list inside the library panel.
struct RSSFeed: Identifiable, Codable {
    let id = UUID()
    var title: String
    var url: String
    var lastUpdated: Date?
}

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let link: String
    let description: String
    let pubDate: Date?
    let audioURL: String?
}

final class PodcastRSSReader: ObservableObject {
    static let shared = PodcastRSSReader()

    @Published var feeds: [RSSFeed] = []
    @Published var items: [RSSItem] = []
    @Published var feedItems: [RSSFeed.ID: [RSSItem]] = [:]
    @Published var isRefreshing = false

    private init() {
        loadFeeds()
    }

    func addFeed(url: String) {
        guard URL(string: url) != nil else { return }
        let feed = RSSFeed(title: url, url: url)
        feeds.append(feed)
        saveFeeds()
        refresh(feed: feed)
    }

    func removeFeed(id: RSSFeed.ID) {
        feeds.removeAll { $0.id == id }
        saveFeeds()
    }

    func refresh(feed: RSSFeed) {
        isRefreshing = true
        guard let url = URL(string: feed.url) else { isRefreshing = false; return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            defer { DispatchQueue.main.async { self?.isRefreshing = false } }
            guard let data else { return }
            let parser = XMLParser(data: data)
            let delegate = RSSParserDelegate()
            parser.delegate = delegate
            parser.parse()
            DispatchQueue.main.async {
                self?.feedItems[feed.id] = delegate.items
                self?.items = delegate.items
                let channelTitle = delegate.channelTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                if !channelTitle.isEmpty {
                    if let idx = self?.feeds.firstIndex(where: { $0.id == feed.id }) {
                        self?.feeds[idx].title = channelTitle
                        self?.saveFeeds()
                    }
                }
            }
        }.resume()
    }

    func refreshAll() {
        for feed in feeds {
            refresh(feed: feed)
        }
    }

    private func saveFeeds() {
        let fm = FileManager.default
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/rss_feeds.json")
        guard let url, let data = try? JSONEncoder().encode(feeds) else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func loadFeeds() {
        let fm = FileManager.default
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/rss_feeds.json")
        guard let url, let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([RSSFeed].self, from: data) else { return }
        feeds = decoded
    }
}

private class RSSParserDelegate: NSObject, XMLParserDelegate {
    var items: [RSSItem] = []
    var channelTitle: String = ""
    private var currentItem: [String: String] = [:]
    private var currentElement = ""
    private var isInsideItem = false

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "item" || elementName == "entry" {
            isInsideItem = true
            currentItem = [:]
        }
        if elementName == "enclosure", let url = attributeDict["url"] {
            currentItem["audioURL"] = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInsideItem {
            currentItem[currentElement] = (currentItem[currentElement] ?? "") + string
        } else if currentElement == "title" {
            channelTitle += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" || elementName == "entry" {
            isInsideItem = false
            let item = RSSItem(
                title: currentItem["title"] ?? "Untitled",
                link: currentItem["link"] ?? currentItem["id"] ?? "",
                description: currentItem["description"] ?? currentItem["summary"] ?? "",
                pubDate: nil,
                audioURL: currentItem["audioURL"]
            )
            items.append(item)
        }
    }
}
