import Foundation
import SQLite3
import Accelerate

/// Semantic Search Browser History Indexer (Roadmap Item 19)
/// Generates embeddings for visited web pages using a local embedding model
/// and stores them in a local SQLite vector store for semantic search.
final class SemanticHistoryIndexer {
    static let shared = SemanticHistoryIndexer()
    private var db: OpaquePointer?

    struct HistoryVector {
        let url: String
        let title: String
        let embedding: [Float]
    }

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
                url TEXT UNIQUE NOT NULL,
                title TEXT,
                content_snippet TEXT,
                embedding BLOB,
                visited_at REAL
            );
            CREATE INDEX IF NOT EXISTS idx_url ON history_embeddings(url);
        """
        var err: UnsafeMutablePointer<CChar>?
        sqlite3_exec(db, sql, nil, nil, &err)
        if let err {
            SoulLogger.log("SemanticHistory: table creation error \(String(cString: err))")
            sqlite3_free(err)
        }
    }

    /// Asynchronously generates an embedding using the active local LLM.
    private func generateEmbedding(text: String, completion: @escaping ([Float]?) -> Void) {
        guard let endpoint = LLMConfigurator.shared.endpoints.first(where: \.isOnline) else {
            completion(nil)
            return
        }
        
        let isOllama = endpoint.type == .ollama
        let path = isOllama ? "/api/embeddings" : "/v1/embeddings"
        guard let url = URL(string: "\(endpoint.url)\(path)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let modelName = endpoint.models.first ?? (isOllama ? "nomic-embed-text" : "text-embedding-nomic")
        
        let body: [String: Any]
        if isOllama {
            body = ["model": modelName, "prompt": text]
        } else {
            body = ["model": modelName, "input": text]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if isOllama {
                    if let embedding = json["embedding"] as? [Double] {
                        completion(embedding.map { Float($0) })
                        return
                    }
                } else {
                    if let dataArray = json["data"] as? [[String: Any]],
                       let first = dataArray.first,
                       let embedding = first["embedding"] as? [Double] {
                        completion(embedding.map { Float($0) })
                        return
                    }
                }
            }
            completion(nil)
        }.resume()
    }

    func indexPage(url: String, title: String, content: String) {
        let snippet = String(content.prefix(2000))
        let textToEmbed = "\(title)\\n\(snippet)"
        
        generateEmbedding(text: textToEmbed) { [weak self] embedding in
            guard let self = self, let embedding = embedding else { return }
            
            let visited = Date().timeIntervalSince1970
            let data = Data(buffer: UnsafeBufferPointer(start: embedding, count: embedding.count))
            
            let insert = """
                INSERT INTO history_embeddings (url, title, content_snippet, embedding, visited_at)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(url) DO UPDATE SET
                    title = excluded.title,
                    content_snippet = excluded.content_snippet,
                    embedding = excluded.embedding,
                    visited_at = excluded.visited_at
            """
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, insert, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (url as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, (title as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 3, (snippet as NSString).utf8String, -1, nil)
                
                data.withUnsafeBytes { rawBuffer in
                    if let baseAddress = rawBuffer.baseAddress {
                        sqlite3_bind_blob(stmt, 4, baseAddress, Int32(data.count), nil)
                    }
                }
                
                sqlite3_bind_double(stmt, 5, visited)
                sqlite3_step(stmt)
                sqlite3_finalize(stmt)
            }
        }
    }

    /// Fetches all stored embeddings to run cosine similarity.
    private func fetchAllVectors() -> [HistoryVector] {
        var results: [HistoryVector] = []
        let sql = "SELECT url, title, embedding FROM history_embeddings WHERE embedding IS NOT NULL"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let url = String(cString: sqlite3_column_text(stmt, 0))
                let title = String(cString: sqlite3_column_text(stmt, 1))
                
                let blobCount = sqlite3_column_bytes(stmt, 2)
                if blobCount > 0 {
                    let blobPointer = sqlite3_column_blob(stmt, 2)
                    let floatCount = Int(blobCount) / MemoryLayout<Float>.stride
                    let floatBuffer = UnsafeBufferPointer<Float>(
                        start: blobPointer?.bindMemory(to: Float.self, capacity: floatCount),
                        count: floatCount
                    )
                    let embedding = Array(floatBuffer)
                    results.append(HistoryVector(url: url, title: title, embedding: embedding))
                }
            }
            sqlite3_finalize(stmt)
        }
        return results
    }

    /// Performs a semantic search for the query and returns the top matches asynchronously.
    func search(query: String, completion: @escaping ([(url: String, title: String)]) -> Void) {
        generateEmbedding(text: query) { [weak self] queryEmbedding in
            guard let self = self, let queryEmbedding = queryEmbedding else {
                completion([])
                return
            }
            
            // Perform vector search in background thread
            DispatchQueue.global(qos: .userInitiated).async {
                let vectors = self.fetchAllVectors()
                var scoredResults: [(url: String, title: String, score: Float)] = []
                
                for vector in vectors {
                    if vector.embedding.count == queryEmbedding.count {
                        let score = self.cosineSimilarity(a: queryEmbedding, b: vector.embedding)
                        scoredResults.append((vector.url, vector.title, score))
                    }
                }
                
                // Sort by highest cosine similarity
                scoredResults.sort { $0.score > $1.score }
                
                let top10 = Array(scoredResults.prefix(10)).map { ($0.url, $0.title) }
                
                DispatchQueue.main.async {
                    completion(top10)
                }
            }
        }
    }
    
    // MARK: - Math Helpers
    
    private func cosineSimilarity(a: [Float], b: [Float]) -> Float {
        var dotProduct: Float = 0
        vDSP_dotpr(a, 1, b, 1, &dotProduct, vDSP_Length(a.count))
        
        var magA: Float = 0
        vDSP_svesq(a, 1, &magA, vDSP_Length(a.count))
        
        var magB: Float = 0
        vDSP_svesq(b, 1, &magB, vDSP_Length(b.count))
        
        let denom = sqrt(magA) * sqrt(magB)
        if denom == 0 { return 0 }
        return dotProduct / denom
    }
}
