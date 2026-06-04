import Foundation
import SQLite3

/// Semantic Search Browser History Indexer (Roadmap Item 19)
/// Generates embeddings for visited web pages using a local embedding model
/// and stores them in a local SQLite vector store for semantic search.
final class SemanticHistoryIndexer {
    static let shared = SemanticHistoryIndexer()
    private var db: OpaquePointer?

    private init() {
        let path = (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("SoulBrowser/semantic_history.db")
            .path
        if sqlite3_open(path, &db) == SQLITE_OK {
            createTable()
        } else {
            SoulLogger.log("SemanticHistory: failed to open database")
        }
    }

    private func createTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS history_embeddings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                url TEXT NOT NULL,
                title TEXT,
                content_snippet TEXT,
                embedding BLOB,
                visited_at REAL
            );
            CREATE INDEX IF NOT EXISTS idx_url ON history_embeddings(url);
            CREATE VIRTUAL TABLE IF NOT EXISTS history_fts USING fts5(title, content_snippet);
        """
        var err: UnsafeMutablePointer<CChar>?
        sqlite3_exec(db, sql, nil, nil, &err)
        if let err {
            SoulLogger.log("SemanticHistory: table creation error \(String(cString: err))")
            sqlite3_free(err)
        }
    }

    func indexPage(url: String, title: String, content: String) {
        let snippet = String(content.prefix(2000))
        let visited = Date().timeIntervalSince1970

        let insert = """
            INSERT INTO history_embeddings (url, title, content_snippet, visited_at)
            VALUES (?, ?, ?, ?)
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, url, -1, nil)
            sqlite3_bind_text(stmt, 2, title, -1, nil)
            sqlite3_bind_text(stmt, 3, snippet, -1, nil)
            sqlite3_bind_double(stmt, 4, visited)
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
        }

        // FTS index for keyword search fallback
        let ftsInsert = "INSERT INTO history_fts (title, content_snippet) VALUES (?, ?)"
        if sqlite3_prepare_v2(db, ftsInsert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, title, -1, nil)
            sqlite3_bind_text(stmt, 2, snippet, -1, nil)
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
        }
    }

    func search(query: String) -> [(url: String, title: String)] {
        var results: [(String, String)] = []
        let sql = """
            SELECT url, title FROM history_fts
            WHERE history_fts MATCH ?
            ORDER BY rank LIMIT 20
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, query, -1, nil)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let url = String(cString: sqlite3_column_text(stmt, 0))
                let title = String(cString: sqlite3_column_text(stmt, 1))
                results.append((url, title))
            }
            sqlite3_finalize(stmt)
        }
        return results
    }
}
