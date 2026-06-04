import Foundation

/// Built-in HTTP Request and Response Inspector (Roadmap Item 48)
/// Intercepts network requests inside CEF and feeds them to a native sidebar
/// drawer displaying headers, payloads, and response times.
struct HTTPRequestEntry: Identifiable {
    let id = UUID()
    let url: String
    let method: String
    let statusCode: Int
    let requestHeaders: [String: String]
    let responseHeaders: [String: String]
    let requestBody: String?
    let responseBody: String?
    let startTime: Date
    let endTime: Date?

    var durationMs: Int? {
        guard let end = endTime else { return nil }
        return Int(end.timeIntervalSince(startTime) * 1000)
    }
}

final class HTTPInspector: ObservableObject {
    static let shared = HTTPInspector()

    @Published var entries: [HTTPRequestEntry] = []
    @Published var isRecording = true
    @Published var filterText = ""

    private init() {}

    func recordRequest(url: String, method: String, headers: [String: String], body: String?) {
        guard isRecording else { return }
        let entry = HTTPRequestEntry(
            url: url,
            method: method,
            statusCode: 0,
            requestHeaders: headers,
            responseHeaders: [:],
            requestBody: body,
            responseBody: nil,
            startTime: Date(),
            endTime: nil
        )
        DispatchQueue.main.async {
            self.entries.append(entry)
            if self.entries.count > 500 { self.entries.removeFirst() }
        }
    }

    func recordResponse(id: UUID, statusCode: Int, headers: [String: String], body: String?) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        let old = entries[idx]
        entries[idx] = HTTPRequestEntry(
            url: old.url,
            method: old.method,
            statusCode: statusCode,
            requestHeaders: old.requestHeaders,
            responseHeaders: headers,
            requestBody: old.requestBody,
            responseBody: body,
            startTime: old.startTime,
            endTime: Date()
        )
    }

    func clear() { entries.removeAll() }

    var filteredEntries: [HTTPRequestEntry] {
        if filterText.isEmpty { return entries }
        return entries.filter {
            $0.url.localizedCaseInsensitiveContains(filterText) ||
            $0.method.localizedCaseInsensitiveContains(filterText)
        }
    }
}
