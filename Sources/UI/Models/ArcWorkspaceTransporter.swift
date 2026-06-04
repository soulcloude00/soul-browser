import Foundation

/// Arc Workspace Transporter (Roadmap Item 91)
/// Detects Arc's plist databases and translates structured spaces into native
/// Soul workspaces.
final class ArcWorkspaceTransporter {
    static let shared = ArcWorkspaceTransporter()

    private init() {}

    func detectArcData(completion: @escaping ([ArcSpace]) -> Void) {
        let arcPath = NSString(string: "~/Library/Application Support/Arc/StorableSpaces.json")
            .expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: arcPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            completion([])
            return
        }

        let spaces = json.compactMap { dict -> ArcSpace? in
            guard let title = dict["title"] as? String else { return nil }
            let tabs = (dict["tabs"] as? [[String: Any]])?.compactMap { tabDict -> ArcTab? in
                guard let url = tabDict["url"] as? String else { return nil }
                return ArcTab(url: url, title: tabDict["title"] as? String ?? "")
            } ?? []
            return ArcSpace(title: title, tabs: tabs)
        }
        completion(spaces)
    }

    func importToSoul(spaces: [ArcSpace], store: BrowserStore) {
        for space in spaces {
            let workspace = Workspace(id: space.title.lowercased().replacingOccurrences(of: " ", with: "-"),
                                      name: space.title,
                                      icon: "🚀")
            if !store.availableWorkspaces.contains(where: { $0.id == workspace.id }) {
                store.availableWorkspaces.append(workspace)
            }
            for tab in space.tabs {
                _ = store.newTab(url: tab.url, select: false)
            }
        }
    }
}

struct ArcSpace {
    let title: String
    let tabs: [ArcTab]
}

struct ArcTab {
    let url: String
    let title: String
}
