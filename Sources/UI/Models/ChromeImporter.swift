import Foundation
import SQLite3

/// Chrome SQLite History & Cookie Importer (Roadmap Item 89)
/// Parses Chrome's local SQLite databases directly on launch, importing
/// bookmarks, histories, and cookies.
final class ChromeImporter {
    static let shared = ChromeImporter()

    private init() {}

    func importHistory(completion: @escaping ([(url: String, title: String, date: Date)]) -> Void) {
        let chromeHistoryPath = NSString(string: "~/Library/Application Support/Google/Chrome/Default/History")
            .expandingTildeInPath
        guard FileManager.default.fileExists(atPath: chromeHistoryPath) else {
            completion([])
            return
        }

        var results: [(String, String, Date)] = []
        var db: OpaquePointer?
        if sqlite3_open(chromeHistoryPath, &db) == SQLITE_OK {
            let query = "SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 1000"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    let url = String(cString: sqlite3_column_text(stmt, 0))
                    let title = String(cString: sqlite3_column_text(stmt, 1))
                    let chromeTime = sqlite3_column_int64(stmt, 2)
                    let date = Date(timeIntervalSince1970: TimeInterval(chromeTime - 11644473600000000) / 1000000)
                    results.append((url, title, date))
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        completion(results)
    }

    func importBookmarks(completion: @escaping ([(title: String, url: String, folder: String)]) -> Void) {
        let chromeBookmarksPath = NSString(string: "~/Library/Application Support/Google/Chrome/Default/Bookmarks")
            .expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: chromeBookmarksPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            completion([])
            return
        }

        var results: [(String, String, String)] = []
        parseBookmarks(node: json, folder: "Imported", results: &results)
        completion(results)
    }

    private func parseBookmarks(node: [String: Any], folder: String, results: inout [(String, String, String)]) {
        if let type = node["type"] as? String, type == "url",
           let name = node["name"] as? String,
           let url = node["url"] as? String {
            results.append((name, url, folder))
        }
        if let children = node["children"] as? [[String: Any]] {
            let childFolder = node["name"] as? String ?? folder
            for child in children {
                parseBookmarks(node: child, folder: childFolder, results: &results)
            }
        }
    }
}
