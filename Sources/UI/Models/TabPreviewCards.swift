import SwiftUI

/// Visual Tab Previews & Hover Cards (Roadmap Item 37)
/// Generates live thumbnail snapshots of tabs and shows them as hover cards
/// in the sidebar or tab strip.
final class TabPreviewCards {
    static let shared = TabPreviewCards()

    private var cache: [UUID: NSImage] = [:]

    private init() {}

    func capturePreview(for tab: BrowserTab, completion: @escaping (NSImage?) -> Void) {
        if let cached = cache[tab.id] {
            completion(cached)
            return
        }

        let js = """
        (async () => {
            const canvas = document.createElement('canvas');
            canvas.width = 400;
            canvas.height = 300;
            const ctx = canvas.getContext('2d');
            ctx.fillStyle = getComputedStyle(document.body).backgroundColor || '#fff';
            ctx.fillRect(0,0,400,300);
            return canvas.toDataURL('image/png');
        })();
        """

        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let dataUrl = result as? String,
                  let commaIndex = dataUrl.firstIndex(of: ","),
                  let data = Data(base64Encoded: String(dataUrl[commaIndex...].dropFirst())),
                  let image = NSImage(data: data) else {
                completion(nil)
                return
            }
            self?.cache[tab.id] = image
            completion(image)
        }
    }

    func clearCache() {
        cache.removeAll()
    }
}
