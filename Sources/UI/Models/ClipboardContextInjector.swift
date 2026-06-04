import AppKit

/// Intelligent Clipboard Context Injector (Roadmap Item 15)
/// Monitors the macOS clipboard via NSPasteboard and shows an option inside
/// the AI Panel to "Analyze copied content" if paste content changes.
final class ClipboardContextInjector: ObservableObject {
    static let shared = ClipboardContextInjector()

    @Published var hasNewContent = false
    @Published var currentContent: String = ""

    private var lastChangeCount = NSPasteboard.general.changeCount
    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        if let string = pb.string(forType: .string), !string.isEmpty {
            currentContent = string
            hasNewContent = true
            SoulLogger.log("Clipboard changed: \(string.prefix(50))...")
        }
    }

    func acknowledge() {
        hasNewContent = false
    }
}
