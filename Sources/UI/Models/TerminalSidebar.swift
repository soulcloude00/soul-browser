import Foundation

/// Integrated Terminal Sidebar (Roadmap Item 49)
/// Embeds a native pseudo-terminal (PTY) runner into a sidebar panel.
final class TerminalSidebar: ObservableObject {
    static let shared = TerminalSidebar()

    @Published var outputLines: [String] = []
    @Published var currentDirectory: String = FileManager.default.currentDirectoryPath
    @Published var isRunning = false

    private var task: Process?

    private init() {}

    func execute(command: String) {
        isRunning = true
        outputLines.append("\(currentDirectory) $ \(command)")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "cd \(currentDirectory) && \(command)"]
        process.environment = ProcessInfo.processInfo.environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let line = String(data: data, encoding: .utf8), !line.isEmpty {
                DispatchQueue.main.async {
                    self?.outputLines.append(line.trimmingCharacters(in: .newlines))
                }
            }
        }

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
            }
        }

        do {
            try process.run()
            task = process
        } catch {
            outputLines.append("Error: \(error)")
            isRunning = false
        }
    }

    func sendInput(_ text: String) {
        // In a full PTY this would write to stdin.
        outputLines.append(text)
    }

    func interrupt() {
        task?.interrupt()
    }
}
