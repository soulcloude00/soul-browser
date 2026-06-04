import AppKit

/// Spatial Screen Capture Tool (Roadmap Item 98)
/// Captures parts of the browser window or full pages, feeding them directly
/// to the local AI or clipboard.
final class SpatialScreenCapture {
    static let shared = SpatialScreenCapture()

    private init() {}

    func captureWindow() -> NSImage? {
        guard let window = NSApp.mainWindow,
              let contentView = window.contentView else { return nil }
        let rect = contentView.bounds
        guard let bitmap = contentView.bitmapImageRepForCachingDisplay(in: rect) else { return nil }
        contentView.cacheDisplay(in: rect, to: bitmap)
        let image = NSImage(size: rect.size)
        image.addRepresentation(bitmap)
        return image
    }

    func captureFullPage(from tab: BrowserTab, completion: @escaping (NSImage?) -> Void) {
        tab.browserView.evaluateJavaScript("document.documentElement.scrollHeight") { result, _ in
            guard result != nil else {
                completion(nil)
                return
            }
            // In production: use CEF DevTools captureFullSizeScreenshot or scroll-stitch.
            completion(self.captureWindow())
        }
    }

    func copyToClipboard(image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
}
