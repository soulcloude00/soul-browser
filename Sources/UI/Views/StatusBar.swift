import SwiftUI

/// A slim status bar that appears at the bottom of the web content card.
/// Shows the active tab's URL, zoom level, and a security indicator.
struct StatusBar: View {
    let tab: BrowserTab?
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 10) {
            if let tab = tab, !tab.urlString.isEmpty, tab.urlString != "about:blank" {
                securityIndicator(for: tab)

                Text(tab.urlString)
                    .font(Typography.mono(Typography.small))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else {
                Text("Ready")
                    .font(Typography.mono(Typography.small))
                    .foregroundStyle(p.mutedForeground.color.opacity(0.6))
            }

            Spacer(minLength: 0)

            if let tab = tab, tab.zoomPercent != 100 {
                Text("\(tab.zoomPercent)%")
                    .font(Typography.mono(Typography.small))
                    .foregroundStyle(p.mutedForeground.color)
                    .help("Zoom level")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(height: 22)
        .background(p.sidebar.color.opacity(0.85))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(p.border.color.opacity(0.5))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func securityIndicator(for tab: BrowserTab) -> some View {
        switch tab.urlScheme {
        case "https":
            Icon(name: "lock.fill", size: 10, weight: .medium)
                .foregroundStyle(Color.green.opacity(0.8))
                .help("Secure connection")
        case "http":
            Icon(name: "exclamationmark.triangle.fill", size: 10, weight: .medium)
                .foregroundStyle(Color.orange.opacity(0.8))
                .help("Insecure connection")
        case "soul":
            Icon(name: "house.fill", size: 10, weight: .medium)
                .foregroundStyle(p.primary.color.opacity(0.8))
                .help("Internal page")
        default:
            EmptyView()
        }
    }
}
