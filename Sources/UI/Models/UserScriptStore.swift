import SwiftUI

/// A user-managed script that runs on matching URLs.
struct UserScript: Identifiable, Codable {
    var id = UUID()
    var name: String
    var pattern: String
    var code: String
    var enabled: Bool
    var runAt: RunAt = .documentStart

    enum RunAt: String, Codable, CaseIterable {
        case documentStart = "document_start"
        case documentEnd = "document_end"
    }
}

/// Manages custom user scripts (Tampermonkey-lite). Scripts are stored as JSON
/// in Application Support and injected into matching pages via CEF.
final class UserScriptStore: ObservableObject {
    static let shared = UserScriptStore()

    @Published var scripts: [UserScript] = []

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent("SoulBrowser", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("user_scripts.json")
        load()
    }

    // MARK: CRUD

    func add(name: String, pattern: String, code: String, runAt: UserScript.RunAt = .documentEnd) {
        let script = UserScript(name: name, pattern: pattern, code: code, enabled: true, runAt: runAt)
        scripts.append(script)
        save()
    }

    func remove(id: UserScript.ID) {
        scripts.removeAll { $0.id == id }
        save()
    }

    func update(_ script: UserScript) {
        if let idx = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[idx] = script
            save()
        }
    }

    func toggleEnabled(_ script: UserScript) {
        if let idx = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[idx].enabled.toggle()
            save()
        }
    }

    // MARK: Matching

    /// Returns all enabled scripts whose pattern matches the given URL.
    func scripts(for url: String, at runAt: UserScript.RunAt) -> [UserScript] {
        scripts.filter { script in
            script.enabled && script.runAt == runAt && matches(url: url, pattern: script.pattern)
        }
    }

    /// Simple wildcard matching: * matches any sequence, ? matches one char.
    private func matches(url: String, pattern: String) -> Bool {
        let regex = pattern
            .replacingOccurrences(of: ".", with: "\\.")
            .replacingOccurrences(of: "*", with: ".*")
            .replacingOccurrences(of: "?", with: ".")
        guard let re = try? NSRegularExpression(pattern: "^" + regex + "$", options: .caseInsensitive) else {
            return false
        }
        let range = NSRange(url.startIndex..., in: url)
        return re.firstMatch(in: url, options: [], range: range) != nil
    }

    // MARK: Persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([UserScript].self, from: data)
        else { return }
        scripts = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(scripts) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
