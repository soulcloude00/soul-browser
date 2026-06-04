import SwiftUI

/// Reader Mode Typography Customizer (Roadmap Item 85)
/// Provide control knobs inside Reader Mode for line height, column width,
/// font size, and background tint themes.
final class ReaderModeTypography: ObservableObject {
    static let shared = ReaderModeTypography()

    @Published var fontSize: CGFloat = 18
    @Published var lineHeight: CGFloat = 1.6
    @Published var columnWidth: CGFloat = 680
    @Published var backgroundTint: Color = .white

    private init() {}

    func applyStylesScript() -> String {
        """
        (function() {
            var style = document.getElementById('soul-reader-typography');
            if (!style) {
                style = document.createElement('style');
                style.id = 'soul-reader-typography';
                document.head.appendChild(style);
            }
            style.textContent = `
                #soul-reader-mode {
                    font-size: \(fontSize)px !important;
                    line-height: \(lineHeight) !important;
                    max-width: \(columnWidth)px !important;
                    margin: 0 auto !important;
                    padding: 40px !important;
                }
            `;
        })();
        """
    }

    func apply(to tab: BrowserTab) {
        tab.browserView.evaluateJavaScript(applyStylesScript()) { _, _ in }
    }
}
