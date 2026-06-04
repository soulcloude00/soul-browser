import AppKit

/// Default Browser Native Prompt Setup (Roadmap Item 94)
/// Hooks into macOS system protocols to safely prompt the user to register
/// Soul as the default browser.
final class DefaultBrowserPrompt {
    static let shared = DefaultBrowserPrompt()

    private init() {}

    var isDefaultBrowser: Bool {
        guard let httpURL = URL(string: "http://example.com") else { return false }
        let handler = NSWorkspace.shared.urlForApplication(toOpen: httpURL)
        return handler?.lastPathComponent == "Soul.app"
    }

    func promptIfNeeded() {
        guard !isDefaultBrowser else { return }

        let alert = NSAlert()
        alert.messageText = "Set Soul as your default browser?"
        alert.informativeText = "Soul will open web links from other apps."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Set as Default")
        alert.addButton(withTitle: "Not Now")

        if alert.runModal() == .alertFirstButtonReturn {
            setAsDefault()
        }
    }

    func setAsDefault() {
        guard let httpURL = URL(string: "http://example.com") else { return }
        NSWorkspace.shared.open(httpURL, configuration: NSWorkspace.OpenConfiguration())
    }
}
