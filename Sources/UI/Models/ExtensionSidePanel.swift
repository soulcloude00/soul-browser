import SwiftUI

/// Extension Side-Panel API Integration (Roadmap Item 73)
/// Exposes the extension `sidePanel` API to load custom tool panes directly
/// into Soul's native right sidebar.
struct ExtensionSidePanelView: View {
    let url: String
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button("Close") {
                    NotificationCenter.default.post(name: .soulCloseExtensionSidePanel, object: nil)
                }
            }
            .padding()
            WebContainerView(store: BrowserStore(), activeTab: BrowserTab(url: url))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

extension Notification.Name {
    static let soulCloseExtensionSidePanel = Notification.Name("soulCloseExtensionSidePanel")
}
