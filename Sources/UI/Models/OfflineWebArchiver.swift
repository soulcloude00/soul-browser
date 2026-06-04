import Foundation

/// Offline Web Reader & Archiver (Roadmap Item 100)
/// Compiles page resources, HTML, and media files into a singular, highly
/// optimized offline web archive file.
final class OfflineWebArchiver {
    static let shared = OfflineWebArchiver()

    private init() {}

    func archivePage(from tab: BrowserTab, completion: @escaping (URL?) -> Void) {
        let js = """
        (async function() {
            const html = document.documentElement.outerHTML;
            const resources = Array.from(document.querySelectorAll('img, video, audio, link[rel="stylesheet"], script[src]'))
                .map(el => el.src || el.href)
                .filter(Boolean);
            return { html, url: location.href, title: document.title, resources };
        })();
        """

        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let dict = result as? [String: Any],
                  let html = dict["html"] as? String,
                  let url = dict["url"] as? String,
                  let title = dict["title"] as? String else {
                completion(nil)
                return
            }
            self?.saveArchive(html: html, url: url, title: title, completion: completion)
        }
    }

    private func saveArchive(html: String, url: String, title: String, completion: @escaping (URL?) -> Void) {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/Archives", isDirectory: true)
        guard let base else { completion(nil); return }
        try? fm.createDirectory(at: base, withIntermediateDirectories: true)

        let safeTitle = title.replacingOccurrences(of: "/", with: "_").prefix(50)
        let fileURL = base.appendingPathComponent("\(safeTitle).mht")

        let mhtContent = """
        Content-Type: multipart/related; boundary=soul-archive-boundary

        --soul-archive-boundary
        Content-Type: text/html
        Content-Location: \(url)

        \(html)
        --soul-archive-boundary--
        """

        do {
            try mhtContent.write(to: fileURL, atomically: true, encoding: .utf8)
            completion(fileURL)
        } catch {
            SoulLogger.log("OfflineWebArchiver: save failed \(error)")
            completion(nil)
        }
    }
}
