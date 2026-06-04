import Foundation

/// Tab Tree Hierarchy & Vertical Tabs (Roadmap Item 40)
/// Manages parent-child relationships between tabs for tree-style sidebar
/// organization.
final class TabTreeManager {
    static let shared = TabTreeManager()
    
    private init() {}
    
    func toggleCollapse(tab: BrowserTab, in store: BrowserStore) {
        tab.isCollapsed.toggle()
        // Collapse/expand all children recursively
        updateChildrenCollapse(tab: tab, collapsed: tab.isCollapsed, in: store)
    }
    
    private func updateChildrenCollapse(tab: BrowserTab, collapsed: Bool, in store: BrowserStore) {
        for child in store.tabs where child.parentTabID == tab.id {
            child.isCollapsed = collapsed
            updateChildrenCollapse(tab: child, collapsed: collapsed, in: store)
        }
    }
    
    func indentLevel(for tab: BrowserTab, in store: BrowserStore) -> Int {
        var level = 0
        var current = tab
        while let parentID = current.parentTabID,
              let parent = store.tabs.first(where: { $0.id == parentID }) {
            level += 1
            current = parent
        }
        return level
    }
}
