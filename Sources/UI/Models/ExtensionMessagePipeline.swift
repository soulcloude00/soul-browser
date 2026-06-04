import Foundation

/// Port & Message Pipeline Optimization (Roadmap Item 74)
/// Optimizes the IPC channel transferring messages between AppKit/Swift and
/// CEF helper extension service workers for zero lag or latency.
final class ExtensionMessagePipeline {
    static let shared = ExtensionMessagePipeline()

    private var messageQueue: [(extensionID: String, message: [String: Any])] = []
    private let batchSize = 10
    private let flushInterval: TimeInterval = 0.016 // ~60fps

    private init() {
        Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            self?.flush()
        }
    }

    func enqueue(extensionID: String, message: [String: Any]) {
        messageQueue.append((extensionID, message))
        if messageQueue.count >= batchSize {
            flush()
        }
    }

    private func flush() {
        guard !messageQueue.isEmpty else { return }
        let batch = messageQueue
        messageQueue.removeAll()
        for (extensionID, message) in batch {
            SoulBrowserView.dispatchExtensionMessage(message, forExtensionID: extensionID)
        }
    }
}
