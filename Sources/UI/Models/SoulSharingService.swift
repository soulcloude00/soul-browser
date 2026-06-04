import AppKit

/// Native macOS Sharesheet & Services Menu Integration (Roadmap Item 6)
/// Bridges the active URL and selected content directly to Apple's native
/// NSSharingServicePicker so users can send web links, screenshots, or
/// local AI summaries to Messages, Mail, AirDrop, or Notes in a single click.
final class SoulSharingService {
    static let shared = SoulSharingService()

    private init() {}

    /// Share a URL from a given source view (e.g., the toolbar share button).
    func share(url: URL, from view: NSView) {
        let picker = NSSharingServicePicker(items: [url])
        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
    }

    /// Share arbitrary text (e.g., selected page content or an AI summary).
    func share(text: String, from view: NSView) {
        let picker = NSSharingServicePicker(items: [text])
        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
    }

    /// Share both a URL and descriptive text together.
    func share(url: URL, text: String, from view: NSView) {
        let picker = NSSharingServicePicker(items: [url, text])
        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
    }

    /// Share an NSImage (e.g., a page screenshot).
    func share(image: NSImage, from view: NSView) {
        let picker = NSSharingServicePicker(items: [image])
        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
    }

    /// Return the list of available sharing services for a URL (for custom UI).
    func availableServices(for url: URL) -> [NSSharingService] {
        return NSSharingService.sharingServices(forItems: [url])
    }
}
