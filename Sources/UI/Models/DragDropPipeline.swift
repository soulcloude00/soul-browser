import AppKit

/// AppKit Services Drag & Drop Pipeline (Roadmap Item 12)
/// Register custom pasteboard types inside the Sidebar and Web Views so
/// users can drag files, images, or snippets directly from Finder into the
/// browser sidebar to instantly trigger imports, uploads, or AI analysis.
final class DragDropPipeline: NSObject, NSDraggingDestination {
    static let shared = DragDropPipeline()

    private override init() {
        super.init()
    }

    func registerDragTypes(for view: NSView) {
        view.registerForDraggedTypes([
            .fileURL,
            .string,
            .png,
            .tiff,
            NSPasteboard.PasteboardType("public.url")
        ])
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard

        // Handle file drops
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            for url in urls {
                SoulLogger.log("DragDrop: received file \(url.lastPathComponent)")
                handleFileDrop(url)
            }
            return true
        }

        // Handle string/text drops
        if let string = pasteboard.string(forType: .string) {
            SoulLogger.log("DragDrop: received text snippet")
            handleTextDrop(string)
            return true
        }

        return false
    }

    private func handleFileDrop(_ url: URL) {
        // In production: trigger AI analysis, upload, or import based on file type
        NotificationCenter.default.post(
            name: .soulFileDropped,
            object: nil,
            userInfo: ["url": url]
        )
    }

    private func handleTextDrop(_ text: String) {
        // In production: add to notes, analyze with AI, or navigate if URL
        if let url = URL(string: text), url.scheme != nil {
            NotificationCenter.default.post(
                name: .soulOpenURL,
                object: nil,
                userInfo: ["url": text]
            )
        } else {
            SoulRoot.appendToScratchpad(text)
        }
    }
}

extension Notification.Name {
    static let soulFileDropped = Notification.Name("soulFileDropped")
    static let soulOpenURL = Notification.Name("soulOpenURL")
}
