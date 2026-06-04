import Foundation

/// Web App Native Wrapper (SSB - Single Site Browser Creator) (Roadmap Item 102)
/// Lets users right-click a tab and choose "Create Web App". This creates an
/// isolated, minimal dock application frame.
final class WebAppWrapper {
    static let shared = WebAppWrapper()

    private init() {}

    func createWebApp(from tab: BrowserTab, completion: @escaping (Bool) -> Void) {
        let url = tab.urlString
        let title = tab.title

        let fm = FileManager.default
        let appsDir = fm.urls(for: .applicationDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulWebApps", isDirectory: true)
        guard let appsDir else { completion(false); return }
        try? fm.createDirectory(at: appsDir, withIntermediateDirectories: true)

        let appName = title.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_")
        let appBundle = appsDir.appendingPathComponent("\(appName).app")

        // Create minimal app bundle structure
        let contents = appBundle.appendingPathComponent("Contents")
        let macOS = contents.appendingPathComponent("MacOS")
        let resources = contents.appendingPathComponent("Resources")
        try? fm.createDirectory(at: macOS, withIntermediateDirectories: true)
        try? fm.createDirectory(at: resources, withIntermediateDirectories: true)

        // Write Info.plist
        let plist: [String: Any] = [
            "CFBundleExecutable": appName,
            "CFBundleIdentifier": "com.soul.webapp.\(appName)",
            "CFBundleName": title,
            "CFBundlePackageType": "APPL",
            "CFBundleShortVersionString": "1.0",
            "LSMinimumSystemVersion": "14.0",
            "NSPrincipalClass": "NSApplication",
            "SoulWebAppURL": url
        ]
        let plistURL = contents.appendingPathComponent("Info.plist")
        if let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) {
            try? data.write(to: plistURL)
        }

        SoulLogger.log("WebAppWrapper: created app at \(appBundle.path)")
        completion(true)
    }
}
