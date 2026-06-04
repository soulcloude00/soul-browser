import Foundation
import Combine

struct DevServer: Identifiable, Equatable {
    var id: Int { port }
    let port: Int
    let command: String
    let pid: String
    
    var urlString: String {
        "http://localhost:\(port)"
    }
}

class LocalhostScanner: ObservableObject {
    @Published var activeServers: [DevServer] = []
    @Published var isScanning = false
    
    // Common development server command names to whitelist
    private let whitelistedCommands: Set<String> = [
        "node", "bun", "deno", "python", "python3", "ruby", "go", "php", "docker", "java", "ruby", "rustc", "cargo"
    ]
    
    // Web development ports that are always whitelisted regardless of command
    private let whitelistedPorts: Set<Int> = [
        3000, 3001, 3002, 4000, 4200, 5000, 5001, 5173, 5174, 8000, 8080, 8081, 8888, 9000, 9292
    ]
    
    init() {
        // Initial scan
        scan()
    }
    
    func scan() {
        guard !isScanning else { return }
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let servers = self?.runLsof() ?? []
            DispatchQueue.main.async {
                self?.activeServers = servers
                self?.isScanning = false
            }
        }
    }
    
    private func runLsof() -> [DevServer] {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "lsof -iTCP -sTCP:LISTEN -n -P"]
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return parseLsofOutput(output)
        } catch {
            print("Failed to run lsof: \(error)")
            return []
        }
    }
    
    private func parseLsofOutput(_ output: String) -> [DevServer] {
        let lines = output.components(separatedBy: .newlines)
        var servers: [DevServer] = []
        var seenPorts: Set<Int> = []
        
        // Skip header line
        for line in lines.dropFirst() {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 9 else { continue }
            
            let command = String(parts[0]).lowercased()
            let pid = String(parts[1])
            let nodeString = String(parts[8]) // e.g. "*:3000" or "127.0.0.1:5173"
            
            // Parse port
            guard let portString = nodeString.components(separatedBy: ":").last,
                  let port = Int(portString) else {
                continue
            }
            
            // Filter: Ignore duplicates (multiple listeners for IPv4/IPv6)
            if seenPorts.contains(port) {
                continue
            }
            
            // Smart Filter: Only include typical web dev tools or known ports
            let isKnownPort = whitelistedPorts.contains(port)
            let isKnownCommand = whitelistedCommands.contains(where: { command.contains($0) })
            
            if isKnownPort || isKnownCommand {
                // Ensure it's listening locally (either *, localhost, or 127.0.0.1/::1)
                if nodeString.contains("*") || nodeString.contains("localhost") || nodeString.contains("127.0.0.1") || nodeString.contains("[::1]") {
                    servers.append(DevServer(port: port, command: String(parts[0]), pid: pid))
                    seenPorts.insert(port)
                }
            }
        }
        
        return servers.sorted { $0.port < $1.port }
    }
}
