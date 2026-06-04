import Foundation

struct Workspace: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var icon: String
    var colorHex: String?
}

extension Workspace {
    static let personal = Workspace(id: "personal", name: "Personal", icon: "✦", colorHex: "#5b21b6")
    static let work = Workspace(id: "work", name: "Work", icon: "💼", colorHex: "#7c3aed")
}
