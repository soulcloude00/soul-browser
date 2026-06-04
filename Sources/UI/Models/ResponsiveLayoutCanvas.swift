import SwiftUI

/// Responsive Layout Canvas (Developer View) (Roadmap Item 52)
/// Embeds a multi-iframe container displaying the active web page in various
/// preset screen sizes (iPhone, iPad, Mac, etc.) simultaneously.
struct ResponsiveLayoutCanvas: View {
    let url: String

    let presets: [(name: String, width: CGFloat, height: CGFloat)] = [
        ("iPhone SE", 375, 667),
        ("iPhone 14", 390, 844),
        ("iPad Mini", 768, 1024),
        ("MacBook Air", 1280, 832),
        ("Desktop", 1440, 900)
    ]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(Array(presets.enumerated()), id: \.offset) { _, preset in
                    VStack {
                        Text(preset.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        WebContainerView(store: BrowserStore(), activeTab: BrowserTab(url: url))
                            .frame(width: preset.width, height: preset.height)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding()
        }
    }
}
