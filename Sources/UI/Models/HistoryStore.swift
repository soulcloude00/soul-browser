import SwiftUI
import SQLite3
import os.log

/// One visited page.
struct HistoryEntry: Identifiable, Codable {
    var id: UUID
    var url: String
    var title: String
    var lastVisited: Date
    var visitCount: Int
}

@objc public class HistoryAPI: NSObject {
    @objc public static func searchHistoryJSON(_ query: String) -> String {
        let results = HistoryStore.shared.suggestions(for: query, limit: 10)
        let dictArray = results.map { entry -> [String: Any] in
            return [
                "id": entry.id.uuidString,
                "url": entry.url,
                "title": entry.title,
                "lastVisited": entry.lastVisited.timeIntervalSince1970 * 1000
            ]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dictArray),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
}

/// Persistent browsing history using SQLite.
final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    // We no longer keep all entries in memory. This is fetched dynamically.
    // For SwiftUI views that need the full history, they can query it.
    @Published private(set) var entries: [HistoryEntry] = []

    private var db: OpaquePointer?
    private let dbURL: URL

    /// Serial queue for all database mutation operations.
    private let dbQueue = DispatchQueue(label: "com.soul.history.db", qos: .utility)
    /// Debounced work item so reloadEntries only fires after writes settle.
    private var reloadWorkItem: DispatchWorkItem?

    init() {
        let dir = HistoryStore.supportDirectory()
        dbURL = dir.appendingPathComponent("history.sqlite")
        
        openDatabase()
        createTable()
        migrateFromJSONIfNeeded(dir: dir)
        
        // Load initial state for SwiftUI
        reloadEntries()
    }
    
    private func openDatabase() {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            SoulLogger.error("Failed to open history database at path: \(dbURL.path)", category: SoulLogger.database)
            db = nil
        }
    }
    
    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS history(
            id TEXT PRIMARY KEY,
            url TEXT UNIQUE,
            title TEXT,
            last_visited REAL,
            visit_count INTEGER
        );
        CREATE INDEX IF NOT EXISTS idx_history_url ON history(url);
        CREATE INDEX IF NOT EXISTS idx_history_title ON history(title);
        CREATE INDEX IF NOT EXISTS idx_history_last_visited ON history(last_visited DESC);
        """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) != SQLITE_DONE {
                SoulLogger.error("Failed to create history table", category: SoulLogger.database)
            }
        }
        sqlite3_finalize(createTableStatement)
    }

    private func migrateFromJSONIfNeeded(dir: URL) {
        let jsonURL = dir.appendingPathComponent("history.json")
        if FileManager.default.fileExists(atPath: jsonURL.path) {
            if let data = try? Data(contentsOf: jsonURL),
               let oldEntries = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
                
                sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
                for entry in oldEntries {
                    insertOrUpdate(entry)
                }
                sqlite3_exec(db, "COMMIT", nil, nil, nil)
            }
            try? FileManager.default.removeItem(at: jsonURL)
        }
    }
    
    private func reloadEntries() {
        // Fetch top 100 for the SwiftUI history view if needed
        let queryStatementString = "SELECT id, url, title, last_visited, visit_count FROM history ORDER BY last_visited DESC LIMIT 100;"
        var queryStatement: OpaquePointer?
        
        var loaded: [HistoryEntry] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let idString = String(cString: sqlite3_column_text(queryStatement, 0))
                let url = String(cString: sqlite3_column_text(queryStatement, 1))
                let title = String(cString: sqlite3_column_text(queryStatement, 2))
                let lastVisited = Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 3))
                let visitCount = Int(sqlite3_column_int(queryStatement, 4))
                
                if let uuid = UUID(uuidString: idString) {
                    loaded.append(HistoryEntry(id: uuid, url: url, title: title, lastVisited: lastVisited, visitCount: visitCount))
                }
            }
        }
        sqlite3_finalize(queryStatement)
        
        DispatchQueue.main.async {
            self.entries = loaded
        }
    }

    /// Record a visit on a background queue so navigation never stalls.
    func record(url: String, title: String) {
        guard isRecordable(url) else { return }
        dbQueue.async { [weak self] in
            self?.insertRecord(url: url, title: title)
            self?.scheduleReload()
        }
    }

    private func insertRecord(url: String, title: String) {
        let now = Date().timeIntervalSince1970
        let uuid = UUID().uuidString

        let insertString = """
        INSERT INTO history (id, url, title, last_visited, visit_count)
        VALUES (?, ?, ?, ?, 1)
        ON CONFLICT(url) DO UPDATE SET
            last_visited = excluded.last_visited,
            title = CASE WHEN excluded.title != '' THEN excluded.title ELSE history.title END,
            visit_count = history.visit_count + 1;
        """

        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (uuid as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (url as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 4, now)

            if sqlite3_step(insertStatement) != SQLITE_DONE {
                SoulLogger.error("Failed to insert history row for URL: \(url)", category: SoulLogger.database)
            }
        }
        sqlite3_finalize(insertStatement)

        // Notify extensions (approximate the entry)
        let entry = HistoryEntry(id: UUID(uuidString: uuid) ?? UUID(), url: url, title: title, lastVisited: Date(), visitCount: 1)
        DispatchQueue.main.async {
            SoulBrowserView.dispatchExtensionEvent("history.onVisited",
                                                     args: [self.extensionHistoryItem(entry)],
                                                     forExtensionID: nil)
        }
    }

    /// Debounce reloadEntries so rapid writes (e.g. batch migration) coalesce into one UI refresh.
    private func scheduleReload() {
        reloadWorkItem?.cancel()
        reloadWorkItem = DispatchWorkItem { [weak self] in
            self?.reloadEntries()
        }
        dbQueue.asyncAfter(deadline: .now() + 1.0, execute: reloadWorkItem!)
    }

    /// Update the title for the most recent entry of a URL on the background queue.
    func updateTitle(_ title: String, for url: String) {
        guard !title.isEmpty else { return }
        dbQueue.async { [weak self] in
            self?.performTitleUpdate(title, for: url)
            self?.scheduleReload()
        }
    }

    private func performTitleUpdate(_ title: String, for url: String) {
        let updateString = "UPDATE history SET title = ? WHERE url = ?;"
        var updateStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (url as NSString).utf8String, -1, nil)
            sqlite3_step(updateStatement)
        }
        sqlite3_finalize(updateStatement)
    }

    private func insertOrUpdate(_ entry: HistoryEntry) {
        let insertString = """
        INSERT INTO history (id, url, title, last_visited, visit_count)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(url) DO UPDATE SET
            last_visited = MAX(history.last_visited, excluded.last_visited),
            title = CASE WHEN excluded.title != '' THEN excluded.title ELSE history.title END,
            visit_count = history.visit_count + excluded.visit_count;
        """
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (entry.id.uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (entry.url as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (entry.title as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 4, entry.lastVisited.timeIntervalSince1970)
            sqlite3_bind_int(insertStatement, 5, Int32(entry.visitCount))
            sqlite3_step(insertStatement)
        }
        sqlite3_finalize(insertStatement)
    }

    /// Best prefix/substring matches for omnibox autocomplete, most-visited and
    /// most-recent first.
    func suggestions(for query: String, limit: Int = 6) -> [HistoryEntry] {
        let q = query.lowercased()
        guard !q.isEmpty else { return [] }
        
        let searchString = "%\\\(q)%"
        let queryString = """
        SELECT id, url, title, last_visited, visit_count FROM history
        WHERE lower(url) LIKE ? OR lower(title) LIKE ?
        ORDER BY visit_count DESC, last_visited DESC
        LIMIT ?;
        """
        
        var queryStatement: OpaquePointer?
        var results: [HistoryEntry] = []
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (searchString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (searchString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 3, Int32(limit))
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let idString = String(cString: sqlite3_column_text(queryStatement, 0))
                let url = String(cString: sqlite3_column_text(queryStatement, 1))
                let title = String(cString: sqlite3_column_text(queryStatement, 2))
                let lastVisited = Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 3))
                let visitCount = Int(sqlite3_column_int(queryStatement, 4))
                
                if let uuid = UUID(uuidString: idString) {
                    results.append(HistoryEntry(id: uuid, url: url, title: title, lastVisited: lastVisited, visitCount: visitCount))
                }
            }
        }
        sqlite3_finalize(queryStatement)
        return results
    }

    func clear() {
        sqlite3_exec(db, "DELETE FROM history", nil, nil, nil)
        reloadEntries()
        dispatchHistoryRemoved(allHistory: true, urls: [])
    }

    func remove(_ entry: HistoryEntry) {
        let deleteString = "DELETE FROM history WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (entry.id.uuidString as NSString).utf8String, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                reloadEntries()
                dispatchHistoryRemoved(allHistory: false, urls: [entry.url])
            }
        }
        sqlite3_finalize(deleteStatement)
    }

    func handleExtensionHistory(method: String, args: NSDictionary) -> NSDictionary {
        switch method {
        case "history.search":
            let query = args["query"] as? NSDictionary ?? [:]
            let result = searchHistory(query: query).map(extensionHistoryItem)
            return ["result": result]

        case "history.getVisits":
            let details = args["details"] as? NSDictionary ?? [:]
            guard let url = details["url"] as? String, !url.isEmpty else {
                return ["error": "history.getVisits requires a url."]
            }
            // Just return one fake visit for now since we collapsed visits into one row
            let visits: [NSDictionary] = [] 
            return ["result": visits]

        case "history.addUrl":
            let details = args["details"] as? NSDictionary ?? [:]
            guard let url = details["url"] as? String, !url.isEmpty else {
                return ["error": "history.addUrl requires a url."]
            }
            record(url: url, title: details["title"] as? String ?? url)
            return ["result": NSNull()]

        case "history.deleteUrl":
            let details = args["details"] as? NSDictionary ?? [:]
            guard let url = details["url"] as? String, !url.isEmpty else {
                return ["error": "history.deleteUrl requires a url."]
            }
            let deleteString = "DELETE FROM history WHERE url = ?;"
            var deleteStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(deleteStatement, 1, (url as NSString).utf8String, -1, nil)
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    reloadEntries()
                    dispatchHistoryRemoved(allHistory: false, urls: [url])
                }
            }
            sqlite3_finalize(deleteStatement)
            return ["result": NSNull()]

        case "history.deleteRange":
            let range = args["range"] as? NSDictionary ?? [:]
            let startTime = ((range["startTime"] as? NSNumber)?.doubleValue ?? 0) / 1000.0
            let endTime = ((range["endTime"] as? NSNumber)?.doubleValue ?? Date().timeIntervalSince1970 * 1000) / 1000.0
            
            let deleteString = "DELETE FROM history WHERE last_visited >= ? AND last_visited <= ?;"
            var deleteStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_double(deleteStatement, 1, startTime)
                sqlite3_bind_double(deleteStatement, 2, endTime)
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    reloadEntries()
                    dispatchHistoryRemoved(allHistory: false, urls: []) // We don't have the exact URLs here without querying first
                }
            }
            sqlite3_finalize(deleteStatement)
            return ["result": NSNull()]

        case "history.deleteAll":
            clear()
            return ["result": NSNull()]

        case "topSites.get":
            let queryString = "SELECT url, title FROM history ORDER BY visit_count DESC, last_visited DESC LIMIT 25;"
            var queryStatement: OpaquePointer?
            var result: [NSDictionary] = []
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let url = String(cString: sqlite3_column_text(queryStatement, 0))
                    let title = String(cString: sqlite3_column_text(queryStatement, 1))
                    result.append(["url": url, "title": title])
                }
            }
            sqlite3_finalize(queryStatement)
            return ["result": result]

        default:
            return ["error": "Unsupported history method: \\(method)"]
        }
    }

    // MARK: Recordability

    private func isRecordable(_ url: String) -> Bool {
        guard !url.isEmpty, url != "about:blank" else { return false }
        let lower = url.lowercased()
        return !lower.hasPrefix("about:") && !lower.hasPrefix("chrome:")
            && !lower.hasPrefix("devtools:") && !lower.hasPrefix("data:")
            && !lower.hasPrefix("soul:")
    }

    // MARK: Persistence

    private static func supportDirectory() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent("SoulBrowser", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func searchHistory(query: NSDictionary) -> [HistoryEntry] {
        let text = (query["text"] as? String ?? "").lowercased()
        let startTime = ((query["startTime"] as? NSNumber)?.doubleValue ?? 0) / 1000.0
        let endTime = ((query["endTime"] as? NSNumber)?.doubleValue ?? Date().timeIntervalSince1970 * 1000) / 1000.0
        let maxResults = max(0, (query["maxResults"] as? NSNumber)?.intValue ?? 100)
        
        let searchString = "%\\\(text)%"
        let queryString = """
        SELECT id, url, title, last_visited, visit_count FROM history
        WHERE last_visited >= ? AND last_visited <= ?
        AND (lower(url) LIKE ? OR lower(title) LIKE ?)
        ORDER BY last_visited DESC
        LIMIT ?;
        """
        
        var queryStatement: OpaquePointer?
        var results: [HistoryEntry] = []
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(queryStatement, 1, startTime)
            sqlite3_bind_double(queryStatement, 2, endTime)
            sqlite3_bind_text(queryStatement, 3, (searchString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 4, (searchString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 5, Int32(maxResults))
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let idString = String(cString: sqlite3_column_text(queryStatement, 0))
                let url = String(cString: sqlite3_column_text(queryStatement, 1))
                let title = String(cString: sqlite3_column_text(queryStatement, 2))
                let lastVisited = Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 3))
                let visitCount = Int(sqlite3_column_int(queryStatement, 4))
                
                if let uuid = UUID(uuidString: idString) {
                    results.append(HistoryEntry(id: uuid, url: url, title: title, lastVisited: lastVisited, visitCount: visitCount))
                }
            }
        }
        sqlite3_finalize(queryStatement)
        return results
    }

    private func extensionHistoryItem(_ entry: HistoryEntry) -> NSDictionary {
        [
            "id": entry.id.uuidString,
            "url": entry.url,
            "title": entry.title,
            "lastVisitTime": entry.lastVisited.timeIntervalSince1970 * 1000,
            "visitCount": entry.visitCount,
            "typedCount": 0
        ]
    }

    private func dispatchHistoryRemoved(allHistory: Bool, urls: [String]) {
        guard allHistory || !urls.isEmpty else { return }
        SoulBrowserView.dispatchExtensionEvent("history.onVisitRemoved",
                                                 args: [[
                                                    "allHistory": allHistory,
                                                    "urls": Array(Set(urls))
                                                 ]],
                                                 forExtensionID: nil)
    }
}
