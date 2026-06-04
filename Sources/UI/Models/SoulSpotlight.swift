import CoreSpotlight

/// Core Spotlight Integration (Roadmap Item 7)
/// Periodically indexes active tab titles, browser history, bookmarks,
/// and local notes so users can launch websites and search history
/// directly from macOS Spotlight search.
final class SoulSpotlightIndexer {
    static let shared = SoulSpotlightIndexer()
    private let index = CSSearchableIndex.default()

    private init() {}

    // MARK: - Tab Indexing

    func indexTab(_ tab: BrowserTab) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .url)
        attributeSet.title = tab.title
        attributeSet.displayName = tab.title
        attributeSet.contentDescription = tab.urlString
        attributeSet.url = URL(string: tab.urlString)
        attributeSet.kind = "Web Page"

        let item = CSSearchableItem(
            uniqueIdentifier: "soul-tab-\(tab.id.uuidString)",
            domainIdentifier: "com.soul.browser.tabs",
            attributeSet: attributeSet
        )

        index.indexSearchableItems([item]) { error in
            if let error { SoulLogger.log("Spotlight index tab error: \(error)") }
        }
    }

    func removeTabIndex(_ tab: BrowserTab) {
        index.deleteSearchableItems(withIdentifiers: ["soul-tab-\(tab.id.uuidString)"]) { _ in }
    }

    // MARK: - History Indexing

    func indexHistoryItem(title: String, url: String, date: Date) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .url)
        attributeSet.title = title
        attributeSet.displayName = title
        attributeSet.contentDescription = url
        attributeSet.url = URL(string: url)
        attributeSet.contentCreationDate = date
        attributeSet.kind = "Browsing History"

        let item = CSSearchableItem(
            uniqueIdentifier: "soul-history-\(url.hash)",
            domainIdentifier: "com.soul.browser.history",
            attributeSet: attributeSet
        )

        index.indexSearchableItems([item]) { error in
            if let error { SoulLogger.log("Spotlight index history error: \(error)") }
        }
    }

    // MARK: - Bookmark Indexing

    func indexBookmark(title: String, url: String, folder: String? = nil) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .url)
        attributeSet.title = title
        attributeSet.displayName = title
        attributeSet.contentDescription = url
        attributeSet.url = URL(string: url)
        if let folder { attributeSet.containerDisplayName = folder }
        attributeSet.kind = "Bookmark"

        let item = CSSearchableItem(
            uniqueIdentifier: "soul-bookmark-\(url.hash)",
            domainIdentifier: "com.soul.browser.bookmarks",
            attributeSet: attributeSet
        )

        index.indexSearchableItems([item]) { error in
            if let error { SoulLogger.log("Spotlight index bookmark error: \(error)") }
        }
    }

    // MARK: - Notes Indexing

    func indexNote(name: String, content: String) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = name
        attributeSet.displayName = name
        attributeSet.textContent = content
        attributeSet.kind = "Soul Note"

        let item = CSSearchableItem(
            uniqueIdentifier: "soul-note-\(name)",
            domainIdentifier: "com.soul.browser.notes",
            attributeSet: attributeSet
        )

        index.indexSearchableItems([item]) { error in
            if let error { SoulLogger.log("Spotlight index note error: \(error)") }
        }
    }

    // MARK: - Bulk Operations

    func deleteAllIndexes(completion: ((Error?) -> Void)? = nil) {
        index.deleteAllSearchableItems(completionHandler: completion ?? { _ in })
    }
}
