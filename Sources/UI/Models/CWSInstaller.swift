import Foundation
import AppKit

/// Chrome Web Store extension installer.
/// Downloads a .crx by extension ID, strips the CRX header, extracts the ZIP
/// payload, moves it into Soul's managed Extensions directory, and registers
/// it via ExtensionStore.
final class CWSInstaller {
    static let shared = CWSInstaller()

    private init() {}

    enum InstallError: Error, LocalizedError {
        case alreadyInstalled(id: String)
        case network(String)
        case invalidCRX
        case extractionFailed(String)
        case missingManifest

        var errorDescription: String? {
            switch self {
            case .alreadyInstalled(let id):
                return "Extension \\(id) is already installed."
            case .network(let msg):
                return "Download failed: \\(msg)"
            case .invalidCRX:
                return "The downloaded file is not a valid CRX archive."
            case .extractionFailed(let msg):
                return "Failed to extract extension: \\(msg)"
            case .missingManifest:
                return "No manifest.json found in the extracted extension."
            }
        }
    }

    /// Begin installing an extension from the Chrome Web Store by its ID.
    /// Installation runs on a background Task; success / failure are broadcast
    /// via NotificationCenter so the UI can show alerts.
    func install(extensionID id: String) {
        guard !ExtensionStore.shared.extensions.contains(where: { $0.id == id }) else {
            postFailure(InstallError.alreadyInstalled(id: id))
            return
        }
        guard !ExtensionStore.shared.installingIDs.contains(id) else { return }

        Task {
            do {
                try await performInstall(extensionID: id)
            } catch {
                postFailure(error)
            }
        }
    }

    // MARK: - Pipeline

    private func performInstall(extensionID id: String) async throws {
        ExtensionStore.shared.setInstalling(id, true)
        defer { ExtensionStore.shared.setInstalling(id, false) }

        let data = try await downloadCRX(extensionID: id)
        let extracted = try extractCRX(data, extensionID: id)

        let fm = FileManager.default
        let dest = ExtensionStore.managedDirectory().appendingPathComponent(id, isDirectory: true)
        if fm.fileExists(atPath: dest.path) {
            try fm.removeItem(at: dest)
        }
        try fm.moveItem(at: extracted, to: dest)

        let ext = try ExtensionStore.shared.addExtension(fromPath: dest.path)

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .soulExtensionInstallSuccess,
                object: nil,
                userInfo: ["name": ext.name, "id": ext.id]
            )
        }
    }

    private func downloadCRX(extensionID id: String) async throws -> Data {
        let urlString =
            "https://clients2.google.com/service/update2/crx"
            + "?response=redirect&prodversion=119&acceptformat=crx3"
            + "&x=id%3D\(id)%26installsource%3Dondemand%26uc"

        guard let url = URL(string: urlString) else {
            throw InstallError.network("Invalid request URL.")
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            + "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw InstallError.network("The store returned HTTP \\(http.statusCode).")
        }
        guard !data.isEmpty else {
            throw InstallError.network("The store returned an empty response.")
        }
        return data
    }

    /// Locate the ZIP magic `PK\x03\x04` inside CRX data, write the ZIP payload
    /// to a temporary file, unzip it, and return the path to the extracted root.
    private func extractCRX(_ data: Data, extensionID: String) throws -> URL {
        let bytes = [UInt8](data)
        let zipMagic: [UInt8] = [0x50, 0x4B, 0x03, 0x04]

        var zipStart = -1
        for i in 0..<(bytes.count - 3) {
            if bytes[i] == zipMagic[0],
               bytes[i + 1] == zipMagic[1],
               bytes[i + 2] == zipMagic[2],
               bytes[i + 3] == zipMagic[3] {
                zipStart = i
                break
            }
        }
        guard zipStart >= 0 else {
            throw InstallError.invalidCRX
        }

        let zipData = Data(bytes[zipStart...])
        let fm = FileManager.default
        let tmpDir = fm.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fm.createDirectory(at: tmpDir, withIntermediateDirectories: true)

        let tmpZip = tmpDir.appendingPathComponent("payload.zip")
        try zipData.write(to: tmpZip)

        let extractDir = tmpDir.appendingPathComponent("extracted", isDirectory: true)
        try fm.createDirectory(at: extractDir, withIntermediateDirectories: true)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        task.arguments = ["-o", "-q", tmpZip.path, "-d", extractDir.path]
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        try task.run()
        task.waitUntilExit()

        if task.terminationStatus > 1 {
            throw InstallError.extractionFailed(
                "unzip exited with status \\(task.terminationStatus)"
            )
        }

        // The unzip may have dumped files directly into extractDir or into a
        // single subdirectory. Return whichever path contains manifest.json.
        if fm.fileExists(atPath: extractDir.appendingPathComponent("manifest.json").path) {
            return extractDir
        }
        let contents = try fm.contentsOfDirectory(at: extractDir, includingPropertiesForKeys: nil)
        for item in contents {
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: item.path, isDirectory: &isDir),
               isDir.boolValue,
               fm.fileExists(atPath: item.appendingPathComponent("manifest.json").path) {
                return item
            }
        }

        throw InstallError.missingManifest
    }

    // MARK: - Feedback

    private func postFailure(_ error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .soulExtensionInstallFailed,
                object: nil,
                userInfo: ["error": error.localizedDescription]
            )
        }
    }
}
