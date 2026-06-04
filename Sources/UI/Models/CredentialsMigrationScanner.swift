import Foundation

/// Web Credentials Migration Scanner (Roadmap Item 95)
/// Read exported password CSV structures and safely import them directly into
/// Apple's Keychain Services.
struct CredentialEntry: Identifiable {
    let id = UUID()
    let url: String
    let username: String
    let password: String
}

final class CredentialsMigrationScanner: ObservableObject {
    static let shared = CredentialsMigrationScanner()

    @Published var foundCredentials: [CredentialEntry] = []
    @Published var isScanning = false

    private init() {}

    func importFromCSV(path: String) {
        isScanning = true
        defer { isScanning = false }

        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        let lines = content.components(separatedBy: .newlines).dropFirst() // skip header

        for line in lines {
            let columns = parseCSVLine(line)
            guard columns.count >= 3 else { continue }
            let entry = CredentialEntry(url: columns[0], username: columns[1], password: columns[2])
            foundCredentials.append(entry)
            SoulKeychain.shared.saveInternetPassword(
                account: entry.username,
                password: entry.password,
                server: entry.url
            )
        }
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }
}
