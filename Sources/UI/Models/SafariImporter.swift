import Foundation

/// Safari Import Helper (Roadmap Item 90)
/// Reads Apple Safari's local configuration plists and Bookmarks databases
/// safely inside the user profile.
final class SafariImporter {
    static let shared = SafariImporter()

    private init() {}

    func importBookmarks(completion: @escaping ([(title: String, url: String, folder: String)]) -> Void) {
        let safariBookmarksPath = NSString(string: "~/Library/Safari/Bookmarks.plist")
            .expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: safariBookmarksPath)),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            completion([])
            return
        }

        var results: [(String, String, String)] = []
        parseSafariBookmarks(node: plist, folder: "Imported from Safari", results: &results)
        completion(results)
    }

    func importReadingList(completion: @escaping ([(title: String, url: String, date: Date)]) -> Void) {
        let readingListPath = NSString(string: "~/Library/Safari/ReadingList.db")
            .expandingTildeInPath
        guard FileManager.default.fileExists(atPath: readingListPath) else {
            completion([])
            return
        }
        // In production: query SQLite reading list database.
        completion([])
    }

    private func parseSafariBookmarks(node: [String: Any], folder: String, results: inout [(String, String, String)]) {
        if let children = node["Children"] as? [[String: Any]] {
            let childFolder = node["Title"] as? String ?? folder
            for child in children {
                if let urlString = child["URLString"] as? String,
                   let title = child["URIDictionary"] as? [String: Any],
                   let name = title["title"] as? String {
                    results.append((name, urlString, childFolder))
                } else {
                    parseSafariBookmarks(node: child, folder: childFolder, results: &results)
                }
            }
        }
    }
}
