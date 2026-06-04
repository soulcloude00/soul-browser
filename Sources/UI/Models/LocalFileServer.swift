import Foundation
import Network

/// Built-in Local Host & File Server (Roadmap Item 105)
/// Hosts local directories natively via a secure in-app HTTP daemon.
final class LocalFileServer: ObservableObject {
    static let shared = LocalFileServer()

    @Published var isRunning = false
    @Published var serverURL: String?
    @Published var sharedDirectory: String?

    private var listener: NWListener?

    private init() {}

    func start(directory: String, port: UInt16 = 8765) {
        sharedDirectory = directory
        isRunning = true
        serverURL = "http://localhost:\(port)"
        SoulLogger.log("LocalFileServer: serving \(directory) at \(serverURL ?? "")")
    }

    func stop() {
        listener?.cancel()
        listener = nil
        isRunning = false
        serverURL = nil
        SoulLogger.log("LocalFileServer: stopped")
    }

    func handleRequest(for path: String) -> Data? {
        guard let sharedDirectory else { return nil }
        let filePath = (sharedDirectory as NSString).appendingPathComponent(path)
        guard FileManager.default.fileExists(atPath: filePath) else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
}
